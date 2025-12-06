//! 协议处理模块
//!
//! 提供不同下载协议的统一抽象和具体实现。

pub mod http;
pub mod torrent;

use crate::error::Result;
use crate::event::{DownloadEvent, Progress};
use crate::task::{DownloadSource, TaskId};
use async_trait::async_trait;
use std::path::PathBuf;
use tokio::sync::broadcast;

/// 协议处理器 trait
///
/// 所有下载协议都需要实现此 trait，提供统一的下载控制接口
#[async_trait]
pub trait ProtocolHandler: Send + Sync {
    /// 开始下载
    ///
    /// # 参数
    /// - `task_id`: 任务 ID
    /// - `source`: 下载来源
    /// - `save_path`: 保存路径
    /// - `event_tx`: 事件发送通道
    async fn start(
        &self,
        task_id: TaskId,
        source: &DownloadSource,
        save_path: PathBuf,
        event_tx: broadcast::Sender<DownloadEvent>,
    ) -> Result<()>;

    /// 暂停下载
    async fn pause(&self, task_id: TaskId) -> Result<()>;

    /// 恢复下载
    async fn resume(&self, task_id: TaskId) -> Result<()>;

    /// 取消下载
    ///
    /// # 参数
    /// - `task_id`: 任务 ID
    /// - `delete_files`: 是否删除已下载的文件
    async fn cancel(&self, task_id: TaskId, delete_files: bool) -> Result<()>;

    /// 获取当前进度
    async fn get_progress(&self, task_id: TaskId) -> Result<Progress>;
}

/// 获取文件信息的结果
#[derive(Debug, Clone)]
pub struct FileInfo {
    /// 文件名
    pub name: String,

    /// 文件大小（字节）
    /// 如果无法确定则为 None
    pub size: Option<u64>,

    /// 是否支持断点续传
    pub supports_resume: bool,

    /// MIME 类型
    pub mime_type: Option<String>,
}
