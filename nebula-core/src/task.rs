//! 下载任务模块
//!
//! 定义下载任务的核心数据结构，包括任务 ID、状态、来源类型等。

use crate::event::Progress;
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use std::path::PathBuf;
use uuid::Uuid;

/// 任务唯一标识符
///
/// 使用 UUID v4 生成，确保全局唯一
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct TaskId(Uuid);

impl TaskId {
    /// 创建新的任务 ID
    pub fn new() -> Self {
        Self(Uuid::new_v4())
    }

    /// 从字符串解析任务 ID
    pub fn from_string(s: &str) -> Result<Self, uuid::Error> {
        Ok(Self(Uuid::parse_str(s)?))
    }

    /// 转换为字符串
    pub fn to_string(&self) -> String {
        self.0.to_string()
    }

    /// 获取短格式 ID（前 8 位）
    pub fn short(&self) -> String {
        self.0.to_string()[..8].to_string()
    }
}

impl Default for TaskId {
    fn default() -> Self {
        Self::new()
    }
}

impl std::fmt::Display for TaskId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}

/// 下载来源类型
///
/// 根据不同的来源类型，使用不同的下载协议处理
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum DownloadSource {
    /// HTTP/HTTPS 直链下载
    Http {
        /// 下载 URL
        url: String,
    },

    /// 磁力链接（BitTorrent）
    Magnet {
        /// 磁力链接 URI
        uri: String,
        /// 可选的显示名称（从 dn= 参数获取）
        display_name: Option<String>,
    },

    /// .torrent 文件（BitTorrent）
    Torrent {
        /// 种子文件路径
        path: PathBuf,
    },

    /// FTP 下载
    Ftp {
        /// FTP URL
        url: String,
    },

    /// 视频网站 (Bilibili, YouTube 等)
    Video {
        /// 视频页面 URL
        url: String,
        /// 选择的画质 ID
        format_id: Option<String>,
    },
}

impl DownloadSource {
    /// 从 URL 字符串自动识别来源类型
    ///
    /// 支持的格式：
    /// - `http://` 或 `https://` -> HTTP
    /// - `magnet:?` -> Magnet
    /// - `ftp://` -> FTP
    /// - 其他（假设为本地文件路径）-> Torrent
    pub fn detect(source: &str) -> Self {
        let source_lower = source.to_lowercase();

        if source_lower.starts_with("magnet:?") {
            // 解析磁力链接中的 dn (display name) 参数
            let display_name = source
                .split('&')
                .find(|s| s.starts_with("dn=") || s.starts_with("&dn="))
                .map(|s| {
                    s.trim_start_matches("dn=")
                        .trim_start_matches("&dn=")
                        .to_string()
                });

            Self::Magnet {
                uri: source.to_string(),
                display_name,
            }
        } else if Self::is_video_url(source) {
            // 视频网站检测必须在普通 HTTP 之前！
            Self::Video {
                url: source.to_string(),
                format_id: None,
            }
        } else if source_lower.starts_with("http://") || source_lower.starts_with("https://") {
            Self::Http {
                url: source.to_string(),
            }
        } else if source_lower.starts_with("ftp://") {
            Self::Ftp {
                url: source.to_string(),
            }
        } else {
            // 假设是本地 .torrent 文件路径
            Self::Torrent {
                path: PathBuf::from(source),
            }
        }
    }

    /// 检查 URL 是否为支持的视频网站
    fn is_video_url(url: &str) -> bool {
        let video_domains = [
            "youtube.com",
            "youtu.be",
            "bilibili.com",
            "b23.tv",
            "twitter.com",
            "x.com",
            "tiktok.com",
            "douyin.com",
            "vimeo.com",
            "dailymotion.com",
            "twitch.tv",
            "instagram.com",
            "facebook.com",
            "nicovideo.jp",
        ];

        video_domains.iter().any(|domain| url.contains(domain))
    }

    /// 获取来源的显示名称
    pub fn display_name(&self) -> String {
        match self {
            Self::Http { url } => {
                // 从 URL 中提取文件名
                url.rsplit('/')
                    .next()
                    .unwrap_or("未知文件")
                    .split('?')
                    .next()
                    .unwrap_or("未知文件")
                    .to_string()
            }
            Self::Magnet {
                display_name,
                uri: _,
            } => display_name.clone().unwrap_or_else(|| "磁力链接".to_string()),
            Self::Torrent { path } => path
                .file_name()
                .and_then(|n| n.to_str())
                .unwrap_or("种子文件")
                .to_string(),
            Self::Ftp { url } => url.rsplit('/').next().unwrap_or("FTP 文件").to_string(),
            Self::Video { url, .. } => {
                // 从视频 URL 提取标识
                if url.contains("bilibili.com") || url.contains("b23.tv") {
                    "Bilibili 视频".to_string()
                } else if url.contains("youtube.com") || url.contains("youtu.be") {
                    "YouTube 视频".to_string()
                } else {
                    "视频下载".to_string()
                }
            }
        }
    }

    /// 获取协议类型名称
    pub fn protocol_name(&self) -> &'static str {
        match self {
            Self::Http { .. } => "HTTP",
            Self::Magnet { .. } => "BitTorrent",
            Self::Torrent { .. } => "BitTorrent",
            Self::Ftp { .. } => "FTP",
            Self::Video { .. } => "Video",
        }
    }
}

/// 任务状态枚举
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum TaskStatus {
    /// 等待中（已添加但未开始）
    Pending,

    /// 正在获取元数据（仅磁力链接）
    FetchingMetadata,

    /// 下载中
    Downloading,

    /// 已暂停
    Paused,

    /// 已完成
    Completed,

    /// 正在做种（仅 BitTorrent）
    Seeding,

    /// 下载失败
    Failed {
        /// 错误信息
        error: String,
        /// 重试次数
        retry_count: usize,
    },

    /// 已取消
    Cancelled,
}

impl TaskStatus {
    /// 检查是否为活跃状态（正在下载或做种）
    pub fn is_active(&self) -> bool {
        matches!(
            self,
            TaskStatus::Downloading | TaskStatus::FetchingMetadata | TaskStatus::Seeding
        )
    }

    /// 检查是否可以暂停
    pub fn can_pause(&self) -> bool {
        matches!(
            self,
            TaskStatus::Downloading | TaskStatus::FetchingMetadata | TaskStatus::Pending
        )
    }

    /// 检查是否可以恢复
    pub fn can_resume(&self) -> bool {
        matches!(self, TaskStatus::Paused)
    }

    /// 检查是否已结束（完成、失败或取消）
    pub fn is_finished(&self) -> bool {
        matches!(
            self,
            TaskStatus::Completed | TaskStatus::Failed { .. } | TaskStatus::Cancelled
        )
    }

    /// 获取状态的中文描述
    pub fn description(&self) -> String {
        match self {
            TaskStatus::Pending => "等待中".to_string(),
            TaskStatus::FetchingMetadata => "获取元数据".to_string(),
            TaskStatus::Downloading => "下载中".to_string(),
            TaskStatus::Paused => "已暂停".to_string(),
            TaskStatus::Completed => "已完成".to_string(),
            TaskStatus::Seeding => "做种中".to_string(),
            TaskStatus::Failed { error, retry_count } => {
                format!("失败 (重试 {} 次): {}", retry_count, error)
            }
            TaskStatus::Cancelled => "已取消".to_string(),
        }
    }
}

impl std::fmt::Display for TaskStatus {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.description())
    }
}

/// 下载任务结构体
///
/// 代表一个独立的下载任务，包含所有相关信息
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DownloadTask {
    /// 任务唯一 ID
    pub id: TaskId,

    /// 任务名称（显示用）
    pub name: String,

    /// 下载来源
    pub source: DownloadSource,

    /// 保存路径（目录或完整文件路径）
    pub save_path: PathBuf,

    /// 当前状态
    pub status: TaskStatus,

    /// 下载进度
    pub progress: Progress,

    /// 创建时间
    pub created_at: DateTime<Utc>,

    /// 开始下载时间
    pub started_at: Option<DateTime<Utc>>,

    /// 完成时间
    pub completed_at: Option<DateTime<Utc>>,

    /// 任务优先级 (1-10，数字越大优先级越高)
    pub priority: u8,
}

impl DownloadTask {
    /// 创建新的下载任务
    pub fn new(source: DownloadSource, save_path: PathBuf) -> Self {
        let name = source.display_name();

        Self {
            id: TaskId::new(),
            name,
            source,
            save_path,
            status: TaskStatus::Pending,
            progress: Progress::default(),
            created_at: Utc::now(),
            started_at: None,
            completed_at: None,
            priority: 5, // 默认中等优先级
        }
    }

    /// 设置任务名称
    pub fn with_name(mut self, name: String) -> Self {
        self.name = name;
        self
    }

    /// 设置优先级
    pub fn with_priority(mut self, priority: u8) -> Self {
        self.priority = priority.clamp(1, 10);
        self
    }

    /// 标记任务开始
    pub fn mark_started(&mut self) {
        self.status = TaskStatus::Downloading;
        self.started_at = Some(Utc::now());
    }

    /// 标记任务完成
    pub fn mark_completed(&mut self) {
        self.status = TaskStatus::Completed;
        self.completed_at = Some(Utc::now());
    }

    /// 标记任务失败
    pub fn mark_failed(&mut self, error: String, retry_count: usize) {
        self.status = TaskStatus::Failed { error, retry_count };
    }

    /// 计算下载耗时（秒）
    pub fn elapsed_secs(&self) -> Option<i64> {
        self.started_at.map(|start| {
            let end = self.completed_at.unwrap_or_else(Utc::now);
            (end - start).num_seconds()
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_source_detection() {
        // HTTP
        let source = DownloadSource::detect("https://example.com/file.zip");
        assert!(matches!(source, DownloadSource::Http { .. }));

        // Magnet
        let source = DownloadSource::detect("magnet:?xt=urn:btih:abc123&dn=测试文件");
        if let DownloadSource::Magnet { display_name, .. } = source {
            assert!(display_name.is_some());
        } else {
            panic!("应该识别为磁力链接");
        }

        // Torrent file
        let source = DownloadSource::detect("/path/to/file.torrent");
        assert!(matches!(source, DownloadSource::Torrent { .. }));
    }

    #[test]
    fn test_task_status() {
        let status = TaskStatus::Downloading;
        assert!(status.is_active());
        assert!(status.can_pause());
        assert!(!status.can_resume());

        let status = TaskStatus::Paused;
        assert!(!status.is_active());
        assert!(status.can_resume());
    }

    #[test]
    fn test_task_creation() {
        let source = DownloadSource::detect("https://example.com/test.zip");
        let task = DownloadTask::new(source, PathBuf::from("/downloads"));

        assert_eq!(task.name, "test.zip");
        assert!(matches!(task.status, TaskStatus::Pending));
        assert_eq!(task.priority, 5);
    }
}
