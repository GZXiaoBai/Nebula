//! 事件系统模块
//!
//! 定义下载过程中的各类事件，用于向上层通知下载进度、状态变化等。

use crate::task::TaskId;
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

/// 下载事件枚举
///
/// 用于通知上层应用下载状态的变化
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum DownloadEvent {
    /// 任务已添加
    TaskAdded {
        task_id: TaskId,
        name: String,
    },

    /// 任务开始下载
    TaskStarted {
        task_id: TaskId,
    },

    /// 下载进度更新
    ProgressUpdated {
        task_id: TaskId,
        progress: Progress,
    },

    /// 任务暂停
    TaskPaused {
        task_id: TaskId,
    },

    /// 任务恢复
    TaskResumed {
        task_id: TaskId,
    },

    /// 任务完成
    TaskCompleted {
        task_id: TaskId,
        /// 完成时间
        completed_at: DateTime<Utc>,
    },

    /// 任务失败
    TaskFailed {
        task_id: TaskId,
        /// 错误信息
        error: String,
    },

    /// 任务已取消/删除
    TaskRemoved {
        task_id: TaskId,
    },

    /// BitTorrent 特有：元数据已获取（磁力链接解析完成）
    MetadataReceived {
        task_id: TaskId,
        /// 种子名称
        name: String,
        /// 总大小（字节）
        total_size: u64,
        /// 文件数量
        file_count: usize,
    },

    /// BitTorrent 特有：Peer 连接状态变化
    PeerUpdate {
        task_id: TaskId,
        /// 已连接 Peer 数
        connected_peers: usize,
        /// 总发现 Peer 数
        total_peers: usize,
    },
}

/// 下载进度信息
#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct Progress {
    /// 总大小（字节）
    /// 对于某些资源（如磁力链接），在获取元数据前可能为 0
    pub total_size: u64,

    /// 已下载大小（字节）
    pub downloaded_size: u64,

    /// 当前下载速度（字节/秒）
    pub download_speed: u64,

    /// 当前上传速度（字节/秒）
    /// HTTP 下载时为 0
    pub upload_speed: u64,

    /// 预计剩余时间（秒）
    /// 如果无法计算则为 None
    pub eta_secs: Option<u64>,

    /// 下载进度百分比 (0.0 - 100.0)
    pub percentage: f64,
}

impl Progress {
    /// 创建新的进度实例
    pub fn new(total_size: u64, downloaded_size: u64) -> Self {
        let percentage = if total_size > 0 {
            (downloaded_size as f64 / total_size as f64) * 100.0
        } else {
            0.0
        };

        Self {
            total_size,
            downloaded_size,
            download_speed: 0,
            upload_speed: 0,
            eta_secs: None,
            percentage,
        }
    }

    /// 更新下载速度并计算 ETA
    pub fn update_speed(&mut self, download_speed: u64, upload_speed: u64) {
        self.download_speed = download_speed;
        self.upload_speed = upload_speed;

        // 计算 ETA
        if download_speed > 0 && self.total_size > self.downloaded_size {
            let remaining = self.total_size - self.downloaded_size;
            self.eta_secs = Some(remaining / download_speed);
        } else {
            self.eta_secs = None;
        }
    }

    /// 更新已下载大小
    pub fn update_downloaded(&mut self, downloaded_size: u64) {
        self.downloaded_size = downloaded_size;
        if self.total_size > 0 {
            self.percentage = (downloaded_size as f64 / self.total_size as f64) * 100.0;
        }
    }

    /// 检查是否已完成
    pub fn is_completed(&self) -> bool {
        self.total_size > 0 && self.downloaded_size >= self.total_size
    }

    /// 格式化下载速度为人类可读字符串
    pub fn format_speed(&self) -> String {
        format_bytes_per_sec(self.download_speed)
    }

    /// 格式化已下载大小 / 总大小
    pub fn format_size(&self) -> String {
        format!(
            "{} / {}",
            format_bytes(self.downloaded_size),
            format_bytes(self.total_size)
        )
    }

    /// 格式化 ETA
    pub fn format_eta(&self) -> String {
        match self.eta_secs {
            Some(secs) if secs < 60 => format!("{}秒", secs),
            Some(secs) if secs < 3600 => format!("{}分{}秒", secs / 60, secs % 60),
            Some(secs) => format!("{}时{}分", secs / 3600, (secs % 3600) / 60),
            None => "计算中...".to_string(),
        }
    }
}

/// 格式化字节数为人类可读字符串
fn format_bytes(bytes: u64) -> String {
    const KB: u64 = 1024;
    const MB: u64 = KB * 1024;
    const GB: u64 = MB * 1024;
    const TB: u64 = GB * 1024;

    if bytes >= TB {
        format!("{:.2} TB", bytes as f64 / TB as f64)
    } else if bytes >= GB {
        format!("{:.2} GB", bytes as f64 / GB as f64)
    } else if bytes >= MB {
        format!("{:.2} MB", bytes as f64 / MB as f64)
    } else if bytes >= KB {
        format!("{:.2} KB", bytes as f64 / KB as f64)
    } else {
        format!("{} B", bytes)
    }
}

/// 格式化速度（字节/秒）
fn format_bytes_per_sec(bytes_per_sec: u64) -> String {
    format!("{}/s", format_bytes(bytes_per_sec))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_progress_percentage() {
        let progress = Progress::new(1000, 500);
        assert!((progress.percentage - 50.0).abs() < 0.01);
    }

    #[test]
    fn test_format_bytes() {
        assert_eq!(format_bytes(500), "500 B");
        assert_eq!(format_bytes(1024), "1.00 KB");
        assert_eq!(format_bytes(1024 * 1024), "1.00 MB");
        assert_eq!(format_bytes(1024 * 1024 * 1024), "1.00 GB");
    }

    #[test]
    fn test_eta_calculation() {
        let mut progress = Progress::new(10000, 5000);
        progress.update_speed(1000, 0); // 1000 B/s
        assert_eq!(progress.eta_secs, Some(5)); // 5秒完成剩余 5000 字节
    }
}
