//! Tracker 列表管理模块
//!
//! 从远程获取最新的 BitTorrent Tracker 列表以提高下载速度

use crate::error::Result;
use std::path::PathBuf;
use tokio::fs;
use tracing::{debug, info, warn};

/// 远程 Tracker 列表 URL
const TRACKER_LIST_URLS: &[&str] = &[
    "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_best.txt",
    "https://cf.trackerslist.com/best.txt",
];

/// 默认内置 Tracker（当远程获取失败时使用）
const FALLBACK_TRACKERS: &[&str] = &[
    "udp://tracker.opentrackr.org:1337/announce",
    "udp://open.stealth.si:80/announce",
    "udp://tracker.torrent.eu.org:451/announce",
    "udp://exodus.desync.com:6969/announce",
    "udp://tracker.openbittorrent.com:6969/announce",
    "udp://open.demonii.com:1337/announce",
    "udp://tracker.moeking.me:6969/announce",
    "udp://explodie.org:6969/announce",
    "udp://tracker1.bt.moack.co.kr:80/announce",
    "udp://tracker.theoks.net:6969/announce",
];

/// Tracker 列表缓存文件名
const CACHE_FILENAME: &str = "trackers.txt";

/// 缓存有效期（7 天）
const CACHE_TTL_SECS: u64 = 7 * 24 * 60 * 60;

/// Tracker 管理器
pub struct TrackerManager {
    cache_dir: PathBuf,
}

impl TrackerManager {
    /// 创建新的 Tracker 管理器
    pub fn new(cache_dir: PathBuf) -> Self {
        Self { cache_dir }
    }

    /// 获取 Tracker 列表
    ///
    /// 优先从缓存读取，缓存过期或不存在时从远程获取
    pub async fn get_trackers(&self) -> Vec<String> {
        // 尝试读取缓存
        if let Some(trackers) = self.read_cache().await {
            debug!("使用缓存的 Tracker 列表 ({} 个)", trackers.len());
            return trackers;
        }

        // 缓存不存在或已过期，从远程获取
        match self.fetch_remote().await {
            Ok(trackers) => {
                info!("成功获取远程 Tracker 列表 ({} 个)", trackers.len());
                // 保存到缓存
                let _ = self.write_cache(&trackers).await;
                trackers
            }
            Err(e) => {
                warn!("获取远程 Tracker 失败: {}, 使用内置列表", e);
                FALLBACK_TRACKERS.iter().map(|s| s.to_string()).collect()
            }
        }
    }

    /// 强制刷新 Tracker 列表
    pub async fn refresh(&self) -> Result<Vec<String>> {
        let trackers = self.fetch_remote().await?;
        self.write_cache(&trackers).await?;
        Ok(trackers)
    }

    /// 读取缓存
    async fn read_cache(&self) -> Option<Vec<String>> {
        let cache_path = self.cache_dir.join(CACHE_FILENAME);

        // 检查缓存文件是否存在
        let metadata = fs::metadata(&cache_path).await.ok()?;

        // 检查缓存是否过期
        let modified = metadata.modified().ok()?;
        let elapsed = modified.elapsed().ok()?;
        if elapsed.as_secs() > CACHE_TTL_SECS {
            debug!("Tracker 缓存已过期");
            return None;
        }

        // 读取缓存内容
        let content = fs::read_to_string(&cache_path).await.ok()?;
        let trackers: Vec<String> = content
            .lines()
            .map(|s| s.trim())
            .filter(|s| !s.is_empty() && !s.starts_with('#'))
            .map(|s| s.to_string())
            .collect();

        if trackers.is_empty() {
            return None;
        }

        Some(trackers)
    }

    /// 写入缓存
    async fn write_cache(&self, trackers: &[String]) -> Result<()> {
        // 确保缓存目录存在
        fs::create_dir_all(&self.cache_dir).await?;

        let cache_path = self.cache_dir.join(CACHE_FILENAME);
        let content = trackers.join("\n");
        fs::write(&cache_path, content).await?;
        debug!("Tracker 列表已缓存到: {:?}", cache_path);
        Ok(())
    }

    /// 从远程获取 Tracker 列表
    async fn fetch_remote(&self) -> Result<Vec<String>> {
        let client = reqwest::Client::builder()
            .timeout(std::time::Duration::from_secs(10))
            .build()
            .map_err(|e| crate::error::NebulaError::Internal(e.to_string()))?;

        for url in TRACKER_LIST_URLS {
            debug!("尝试从 {} 获取 Tracker 列表", url);
            match client.get(*url).send().await {
                Ok(response) if response.status().is_success() => {
                    if let Ok(text) = response.text().await {
                        let trackers: Vec<String> = text
                            .lines()
                            .map(|s| s.trim())
                            .filter(|s| !s.is_empty() && (s.starts_with("udp://") || s.starts_with("http://") || s.starts_with("https://")))
                            .map(|s| s.to_string())
                            .collect();

                        if !trackers.is_empty() {
                            return Ok(trackers);
                        }
                    }
                }
                Ok(response) => {
                    debug!("请求 {} 失败: {}", url, response.status());
                }
                Err(e) => {
                    debug!("请求 {} 出错: {}", url, e);
                }
            }
        }

        Err(crate::error::NebulaError::Internal(
            "无法从任何 Tracker 源获取列表".to_string(),
        ))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_fallback_trackers() {
        let manager = TrackerManager::new(PathBuf::from("/tmp/test_trackers"));
        let trackers = manager.get_trackers().await;
        assert!(!trackers.is_empty());
    }
}
