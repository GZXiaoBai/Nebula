//! 配置管理模块
//!
//! 定义下载管理器和各协议的配置选项。

use serde::{Deserialize, Serialize};
use std::path::PathBuf;

/// 下载管理器主配置
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ManagerConfig {
    /// 默认下载保存目录
    pub download_dir: PathBuf,

    /// 最大并发下载任务数
    pub max_concurrent_tasks: usize,

    /// HTTP 协议配置
    pub http: HttpConfig,

    /// BitTorrent 协议配置
    pub torrent: TorrentConfig,

    /// 自动重试配置
    pub retry: RetryConfig,
}

impl Default for ManagerConfig {
    fn default() -> Self {
        // 默认下载目录：用户的 Downloads 文件夹
        let download_dir = dirs::download_dir().unwrap_or_else(|| PathBuf::from("./downloads"));

        Self {
            download_dir,
            max_concurrent_tasks: 5,
            http: HttpConfig::default(),
            torrent: TorrentConfig::default(),
            retry: RetryConfig::default(),
        }
    }
}

/// HTTP/HTTPS 下载配置
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HttpConfig {
    /// 单文件最大并发连接数（分块下载）
    pub max_connections_per_file: usize,

    /// 连接超时时间（秒）
    pub connect_timeout_secs: u64,

    /// 读取超时时间（秒）
    pub read_timeout_secs: u64,

    /// 分块大小（字节），用于多线程下载
    /// 默认 4MB
    pub chunk_size: u64,

    /// User-Agent 字符串
    pub user_agent: String,

    /// 代理设置（可选）
    /// 格式: "http://proxy:port" 或 "socks5://proxy:port"
    pub proxy: Option<String>,
}

impl Default for HttpConfig {
    fn default() -> Self {
        Self {
            max_connections_per_file: 8,
            connect_timeout_secs: 30,
            read_timeout_secs: 60,
            chunk_size: 4 * 1024 * 1024, // 4MB
            user_agent: format!(
                "Nebula/{} (https://github.com/user/nebula)",
                env!("CARGO_PKG_VERSION")
            ),
            proxy: None,
        }
    }
}

/// BitTorrent 配置
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TorrentConfig {
    /// 监听端口（用于接收 Peer 连接）
    /// 如果为 None，则使用随机端口
    pub listen_port: Option<u16>,

    /// 是否启用 DHT
    pub enable_dht: bool,

    /// 是否启用 UPnP 端口映射
    pub enable_upnp: bool,

    /// 是否启用 Peer Exchange (PEX)
    pub enable_pex: bool,

    /// 最大上传速度（字节/秒）
    /// None 表示不限制
    pub max_upload_speed: Option<u64>,

    /// 最大下载速度（字节/秒）
    /// None 表示不限制
    pub max_download_speed: Option<u64>,

    /// 最大连接 Peer 数
    pub max_peers: usize,

    /// 目标分享率（达到后停止做种）
    /// 例如 2.0 表示上传量达到下载量的 2 倍后停止
    pub seed_ratio_limit: Option<f64>,

    /// 额外的 Tracker 列表
    pub extra_trackers: Vec<String>,

    /// 是否启用顺序下载（边下边播需要）
    pub sequential_download: bool,
}

impl Default for TorrentConfig {
    fn default() -> Self {
        Self {
            listen_port: None, // 随机端口
            enable_dht: true,
            enable_upnp: true,
            enable_pex: true,
            max_upload_speed: None,
            max_download_speed: None,
            max_peers: 100,
            seed_ratio_limit: Some(2.0),
            extra_trackers: vec![],
            sequential_download: true, // 默认开启，支持边下边播
        }
    }
}

/// 自动重试配置
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RetryConfig {
    /// 最大重试次数
    pub max_retries: usize,

    /// 重试间隔基数（秒）
    /// 实际间隔会使用指数退避算法
    pub base_delay_secs: u64,

    /// 最大重试间隔（秒）
    pub max_delay_secs: u64,
}

impl Default for RetryConfig {
    fn default() -> Self {
        Self {
            max_retries: 5,
            base_delay_secs: 2,
            max_delay_secs: 60,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_default_config() {
        let config = ManagerConfig::default();
        assert_eq!(config.max_concurrent_tasks, 5);
        assert_eq!(config.http.max_connections_per_file, 8);
        assert!(config.torrent.enable_dht);
    }

    #[test]
    fn test_config_serialization() {
        let config = ManagerConfig::default();
        let json = serde_json::to_string(&config).unwrap();
        let parsed: ManagerConfig = serde_json::from_str(&json).unwrap();
        assert_eq!(parsed.max_concurrent_tasks, config.max_concurrent_tasks);
    }
}
