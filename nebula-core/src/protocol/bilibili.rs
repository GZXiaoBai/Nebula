//! Bilibili 登录模块
//!
//! 支持扫码登录获取 Cookie，用于下载高码率视频

use crate::error::{NebulaError, Result};
use aes_gcm::{
    aead::{Aead, KeyInit},
    Aes256Gcm, Nonce,
};
use rand::RngCore;
use serde::{Deserialize, Serialize};
use std::path::PathBuf;
use tokio::fs;
use tracing::{debug, info, warn};

/// B站登录 API 基础 URL
const BILIBILI_PASSPORT_URL: &str = "https://passport.bilibili.com";

/// Cookie 文件名
const COOKIE_FILENAME: &str = "bilibili_cookies.enc";

/// 加密密钥文件名
const KEY_FILENAME: &str = "bilibili_key.bin";

/// 二维码生成响应
#[derive(Debug, Deserialize)]
pub struct QrCodeGenerateResponse {
    pub code: i32,
    pub message: String,
    pub data: Option<QrCodeData>,
}

/// 二维码数据
#[derive(Debug, Deserialize)]
pub struct QrCodeData {
    /// 二维码 URL (用于展示)
    pub url: String,
    /// 二维码 key (用于轮询状态)
    pub qrcode_key: String,
}

/// 扫码轮询响应
#[derive(Debug, Deserialize)]
pub struct QrCodePollResponse {
    pub code: i32,
    pub message: String,
    pub data: Option<QrCodePollData>,
}

/// 扫码轮询数据
#[derive(Debug, Deserialize)]
pub struct QrCodePollData {
    /// 登录 URL (包含 cookie 参数)
    pub url: String,
    /// 刷新 token
    pub refresh_token: String,
    /// 时间戳
    pub timestamp: i64,
    /// 状态码: 0-成功, 86038-已过期, 86090-待扫描, 86101-已扫描待确认
    pub code: i32,
    /// 状态消息
    pub message: String,
}

/// 登录状态
#[derive(Debug, Clone, PartialEq)]
pub enum LoginStatus {
    /// 等待扫描
    WaitingScan,
    /// 已扫描待确认
    WaitingConfirm,
    /// 登录成功
    Success,
    /// 二维码已过期
    Expired,
    /// 登录失败
    Failed(String),
}

/// Cookie 信息 (加密存储)
#[derive(Debug, Serialize, Deserialize)]
pub struct BilibiliCookie {
    /// SESSDATA
    pub sessdata: String,
    /// bili_jct
    pub bili_jct: String,
    /// DedeUserID
    pub dede_user_id: String,
    /// 创建时间
    pub created_at: i64,
}

/// Bilibili 登录管理器
pub struct BilibiliAuth {
    /// 数据目录
    data_dir: PathBuf,
    /// HTTP 客户端
    client: reqwest::Client,
}

impl BilibiliAuth {
    /// 创建新的 Bilibili 认证管理器
    pub fn new(data_dir: PathBuf) -> Self {
        let client = reqwest::Client::builder()
            .user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
            .build()
            .unwrap_or_default();

        Self { data_dir, client }
    }

    /// 生成登录二维码
    pub async fn generate_qrcode(&self) -> Result<QrCodeData> {
        let url = format!(
            "{}/x/passport-login/web/qrcode/generate",
            BILIBILI_PASSPORT_URL
        );

        let response: QrCodeGenerateResponse = self
            .client
            .get(&url)
            .send()
            .await
            .map_err(|e| NebulaError::Internal(format!("请求二维码失败: {}", e)))?
            .json()
            .await
            .map_err(|e| NebulaError::Internal(format!("解析响应失败: {}", e)))?;

        if response.code != 0 {
            return Err(NebulaError::Internal(format!(
                "生成二维码失败: {}",
                response.message
            )));
        }

        response
            .data
            .ok_or_else(|| NebulaError::Internal("二维码数据为空".to_string()))
    }

    /// 轮询扫码状态
    pub async fn poll_qrcode_status(&self, qrcode_key: &str) -> Result<LoginStatus> {
        let url = format!(
            "{}/x/passport-login/web/qrcode/poll?qrcode_key={}",
            BILIBILI_PASSPORT_URL, qrcode_key
        );

        let response = self
            .client
            .get(&url)
            .send()
            .await
            .map_err(|e| NebulaError::Internal(format!("轮询状态失败: {}", e)))?;

        // 获取 Set-Cookie 头
        let cookies: Vec<String> = response
            .cookies()
            .map(|c| format!("{}={}", c.name(), c.value()))
            .collect();

        let poll_data: QrCodePollResponse = response
            .json()
            .await
            .map_err(|e| NebulaError::Internal(format!("解析响应失败: {}", e)))?;

        if poll_data.code != 0 {
            return Err(NebulaError::Internal(format!(
                "轮询失败: {}",
                poll_data.message
            )));
        }

        let data = poll_data
            .data
            .ok_or_else(|| NebulaError::Internal("轮询数据为空".to_string()))?;

        match data.code {
            0 => {
                // 登录成功，从 cookies 提取信息
                if let Some(cookie) = self.parse_cookies(&cookies) {
                    self.save_cookie(&cookie).await?;
                    info!("B站登录成功");
                    Ok(LoginStatus::Success)
                } else {
                    // 尝试从 URL 解析 cookie
                    if let Some(cookie) = self.parse_url_cookies(&data.url) {
                        self.save_cookie(&cookie).await?;
                        info!("B站登录成功 (从 URL 解析)");
                        Ok(LoginStatus::Success)
                    } else {
                        Err(NebulaError::Internal("无法解析登录 Cookie".to_string()))
                    }
                }
            }
            86038 => Ok(LoginStatus::Expired),
            86090 => Ok(LoginStatus::WaitingScan),
            86101 => Ok(LoginStatus::WaitingConfirm),
            _ => Ok(LoginStatus::Failed(data.message)),
        }
    }

    /// 解析 Cookie 字符串
    fn parse_cookies(&self, cookies: &[String]) -> Option<BilibiliCookie> {
        let mut sessdata = None;
        let mut bili_jct = None;
        let mut dede_user_id = None;

        for cookie in cookies {
            if cookie.starts_with("SESSDATA=") {
                sessdata = Some(cookie.trim_start_matches("SESSDATA=").to_string());
            } else if cookie.starts_with("bili_jct=") {
                bili_jct = Some(cookie.trim_start_matches("bili_jct=").to_string());
            } else if cookie.starts_with("DedeUserID=") {
                dede_user_id = Some(cookie.trim_start_matches("DedeUserID=").to_string());
            }
        }

        match (sessdata, bili_jct, dede_user_id) {
            (Some(s), Some(b), Some(d)) => Some(BilibiliCookie {
                sessdata: s,
                bili_jct: b,
                dede_user_id: d,
                created_at: chrono::Utc::now().timestamp(),
            }),
            _ => None,
        }
    }

    /// 从登录 URL 解析 Cookie
    fn parse_url_cookies(&self, url: &str) -> Option<BilibiliCookie> {
        let url = url::Url::parse(url).ok()?;
        let params: std::collections::HashMap<_, _> = url.query_pairs().collect();

        let sessdata = params.get("SESSDATA")?.to_string();
        let bili_jct = params.get("bili_jct")?.to_string();
        let dede_user_id = params.get("DedeUserID")?.to_string();

        Some(BilibiliCookie {
            sessdata,
            bili_jct,
            dede_user_id,
            created_at: chrono::Utc::now().timestamp(),
        })
    }

    /// 加密并保存 Cookie
    async fn save_cookie(&self, cookie: &BilibiliCookie) -> Result<()> {
        fs::create_dir_all(&self.data_dir).await?;

        // 生成或加载密钥
        let key = self.get_or_create_key().await?;

        // 序列化 Cookie
        let plaintext = serde_json::to_vec(cookie)
            .map_err(|e| NebulaError::Internal(format!("序列化 Cookie 失败: {}", e)))?;

        // 生成随机 nonce
        let mut nonce_bytes = [0u8; 12];
        rand::rng().fill_bytes(&mut nonce_bytes);
        let nonce = Nonce::from_slice(&nonce_bytes);

        // 加密
        let cipher = Aes256Gcm::new_from_slice(&key)
            .map_err(|e| NebulaError::Internal(format!("创建加密器失败: {}", e)))?;

        let ciphertext = cipher
            .encrypt(nonce, plaintext.as_ref())
            .map_err(|e| NebulaError::Internal(format!("加密失败: {}", e)))?;

        // 保存 nonce + ciphertext
        let mut data = nonce_bytes.to_vec();
        data.extend(ciphertext);

        let cookie_path = self.data_dir.join(COOKIE_FILENAME);
        fs::write(&cookie_path, data).await?;

        debug!("Cookie 已加密保存到: {:?}", cookie_path);
        Ok(())
    }

    /// 加载并解密 Cookie
    pub async fn load_cookie(&self) -> Result<Option<BilibiliCookie>> {
        let cookie_path = self.data_dir.join(COOKIE_FILENAME);

        if !cookie_path.exists() {
            return Ok(None);
        }

        // 读取加密数据
        let data = fs::read(&cookie_path).await?;

        if data.len() < 12 {
            warn!("Cookie 文件格式错误");
            return Ok(None);
        }

        // 分离 nonce 和 ciphertext
        let nonce_bytes = &data[..12];
        let ciphertext = &data[12..];
        let nonce = Nonce::from_slice(nonce_bytes);

        // 加载密钥
        let key = self.get_or_create_key().await?;

        // 解密
        let cipher = Aes256Gcm::new_from_slice(&key)
            .map_err(|e| NebulaError::Internal(format!("创建解密器失败: {}", e)))?;

        let plaintext = cipher
            .decrypt(nonce, ciphertext)
            .map_err(|e| NebulaError::Internal(format!("解密失败: {}", e)))?;

        // 反序列化
        let cookie: BilibiliCookie = serde_json::from_slice(&plaintext)
            .map_err(|e| NebulaError::Internal(format!("反序列化失败: {}", e)))?;

        Ok(Some(cookie))
    }

    /// 获取或创建加密密钥
    async fn get_or_create_key(&self) -> Result<[u8; 32]> {
        let key_path = self.data_dir.join(KEY_FILENAME);

        if key_path.exists() {
            let key_data = fs::read(&key_path).await?;
            if key_data.len() == 32 {
                let mut key = [0u8; 32];
                key.copy_from_slice(&key_data);
                return Ok(key);
            }
        }

        // 生成新密钥
        let mut key = [0u8; 32];
        rand::rng().fill_bytes(&mut key);

        fs::write(&key_path, &key).await?;
        debug!("生成新的加密密钥");

        Ok(key)
    }

    /// 检查是否已登录
    pub async fn is_logged_in(&self) -> bool {
        self.load_cookie().await.ok().flatten().is_some()
    }

    /// 注销 (删除 Cookie)
    pub async fn logout(&self) -> Result<()> {
        let cookie_path = self.data_dir.join(COOKIE_FILENAME);
        if cookie_path.exists() {
            fs::remove_file(&cookie_path).await?;
            info!("已注销 B站账号");
        }
        Ok(())
    }

    /// 导出 Cookie 为 Netscape 格式 (用于 yt-dlp)
    pub async fn export_cookies_for_ytdlp(&self) -> Result<Option<PathBuf>> {
        let cookie = match self.load_cookie().await? {
            Some(c) => c,
            None => return Ok(None),
        };

        let cookie_file = self.data_dir.join("bilibili_cookies.txt");

        // Netscape cookie 格式
        let content = format!(
            "# Netscape HTTP Cookie File\n\
            .bilibili.com\tTRUE\t/\tFALSE\t0\tSESSDATA\t{}\n\
            .bilibili.com\tTRUE\t/\tFALSE\t0\tbili_jct\t{}\n\
            .bilibili.com\tTRUE\t/\tFALSE\t0\tDedeUserID\t{}\n",
            cookie.sessdata, cookie.bili_jct, cookie.dede_user_id
        );

        fs::write(&cookie_file, content).await?;
        debug!("Cookie 已导出到: {:?}", cookie_file);

        Ok(Some(cookie_file))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_auth_manager_creation() {
        let auth = BilibiliAuth::new(PathBuf::from("/tmp/test_bilibili"));
        assert!(!auth.is_logged_in().await);
    }
}
