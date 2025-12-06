//! 下载管理器模块
//!
//! 统一管理所有下载任务，提供高层 API 供上层应用调用。

use crate::config::ManagerConfig;
use crate::error::{NebulaError, Result};
use crate::event::{DownloadEvent, Progress};
use crate::protocol::http::HttpHandler;
use crate::protocol::torrent::TorrentHandler;
use crate::protocol::video::VideoHandler;
use crate::protocol::ProtocolHandler;
use crate::task::{DownloadSource, DownloadTask, TaskId, TaskStatus};

use std::collections::HashMap;
use std::path::PathBuf;
use std::sync::Arc;
use tokio::sync::{broadcast, RwLock};
use tracing::{error, info, warn};

/// 事件通道容量
const EVENT_CHANNEL_CAPACITY: usize = 1024;

/// 下载管理器
///
/// 核心入口，管理所有下载任务的生命周期
///
/// # 示例
///
/// ```rust,ignore
/// use nebula_core::{DownloadManager, ManagerConfig};
///
/// #[tokio::main]
/// async fn main() -> anyhow::Result<()> {
///     let config = ManagerConfig::default();
///     let manager = DownloadManager::new(config).await?;
///
///     // 添加下载任务
///     let task_id = manager.add_task(
///         "magnet:?xt=urn:btih:...",
///         PathBuf::from("/downloads"),
///     ).await?;
///
///     // 监听事件
///     let mut events = manager.subscribe();
///     while let Ok(event) = events.recv().await {
///         println!("{:?}", event);
///     }
///
///     Ok(())
/// }
/// ```
pub struct DownloadManager {
    /// 配置
    config: ManagerConfig,

    /// 所有任务
    tasks: Arc<RwLock<HashMap<TaskId, DownloadTask>>>,

    /// HTTP 下载处理器
    http_handler: Arc<HttpHandler>,

    /// BitTorrent 下载处理器 (可选，初始化失败时为 None)
    torrent_handler: Option<Arc<TorrentHandler>>,

    /// 事件广播发送端
    event_tx: broadcast::Sender<DownloadEvent>,
}

impl DownloadManager {
    /// 创建新的下载管理器
    ///
    /// # 参数
    /// - `config`: 管理器配置
    ///
    /// # 返回
    /// 初始化完成的下载管理器实例
    pub async fn new(config: ManagerConfig) -> Result<Self> {
        info!("初始化下载管理器...");

        // 确保下载目录存在
        if !config.download_dir.exists() {
            tokio::fs::create_dir_all(&config.download_dir).await?;
            info!("已创建下载目录: {:?}", config.download_dir);
        }

        // 创建 HTTP 处理器
        let http_handler = Arc::new(HttpHandler::new(config.http.clone())?);

        // 创建 BitTorrent 处理器 (可选)
        let data_dir = config.download_dir.join(".nebula");
        let torrent_handler = match TorrentHandler::new(config.torrent.clone(), data_dir).await {
            Ok(handler) => {
                info!("BitTorrent 处理器初始化成功");
                Some(Arc::new(handler))
            }
            Err(e) => {
                warn!("BitTorrent 处理器初始化失败，磁力链接下载将不可用: {}", e);
                None
            }
        };

        // 创建事件通道
        let (event_tx, _) = broadcast::channel(EVENT_CHANNEL_CAPACITY);

        info!("下载管理器初始化完成");

        Ok(Self {
            config,
            tasks: Arc::new(RwLock::new(HashMap::new())),
            http_handler,
            torrent_handler,
            event_tx,
        })
    }

    /// 添加下载任务
    ///
    /// 自动识别 URL 类型并选择合适的下载协议
    ///
    /// # 参数
    /// - `source`: 下载来源（URL、磁力链接或 torrent 文件路径）
    /// - `save_path`: 保存路径（目录或文件路径）
    ///
    /// # 返回
    /// 新创建的任务 ID
    pub async fn add_task(&self, source: &str, save_path: PathBuf) -> Result<TaskId> {
        // 自动识别来源类型
        let download_source = DownloadSource::detect(source);
        let protocol_name = download_source.protocol_name();

        info!("添加下载任务: {} (协议: {})", source, protocol_name);

        // 确定实际保存路径
        let actual_save_path = if save_path.as_os_str().is_empty() {
            self.config.download_dir.clone()
        } else {
            save_path
        };

        // 创建任务
        let task = DownloadTask::new(download_source.clone(), actual_save_path.clone());
        let task_id = task.id;

        // 注册任务
        {
            let mut tasks = self.tasks.write().await;
            tasks.insert(task_id, task.clone());
        }

        // 发送任务添加事件
        let _ = self.event_tx.send(DownloadEvent::TaskAdded {
            task_id,
            name: task.name.clone(),
        });

        // 根据协议类型选择处理器并开始下载
        let event_tx = self.event_tx.clone();
        let tasks = Arc::clone(&self.tasks);

        match &download_source {
            DownloadSource::Http { .. } => {
                let handler = Arc::clone(&self.http_handler);
                tokio::spawn(async move {
                    // 更新任务状态为下载中
                    {
                        let mut tasks_guard = tasks.write().await;
                        if let Some(task) = tasks_guard.get_mut(&task_id) {
                            task.mark_started();
                        }
                    }

                    // 执行下载
                    if let Err(e) = handler
                        .start(task_id, &download_source, actual_save_path, event_tx.clone())
                        .await
                    {
                        error!("HTTP 下载失败: {}", e);
                        let _ = event_tx.send(DownloadEvent::TaskFailed {
                            task_id,
                            error: e.to_string(),
                        });

                        // 更新任务状态
                        let mut tasks_guard = tasks.write().await;
                        if let Some(task) = tasks_guard.get_mut(&task_id) {
                            task.mark_failed(e.to_string(), 0);
                        }
                    } else {
                        // 更新任务状态为完成
                        let mut tasks_guard = tasks.write().await;
                        if let Some(task) = tasks_guard.get_mut(&task_id) {
                            task.mark_completed();
                        }
                    }
                });
            }
            DownloadSource::Magnet { .. } | DownloadSource::Torrent { .. } => {
                let handler = match &self.torrent_handler {
                    Some(h) => Arc::clone(h),
                    None => {
                        return Err(NebulaError::UnsupportedProtocol(
                            "BitTorrent 未初始化，磁力链接下载不可用".to_string(),
                        ));
                    }
                };
                tokio::spawn(async move {
                    // 更新任务状态
                    {
                        let mut tasks_guard = tasks.write().await;
                        if let Some(task) = tasks_guard.get_mut(&task_id) {
                            task.status = TaskStatus::FetchingMetadata;
                        }
                    }

                    // 执行下载
                    if let Err(e) = handler
                        .start(task_id, &download_source, actual_save_path, event_tx.clone())
                        .await
                    {
                        error!("BitTorrent 下载失败: {}", e);
                        let _ = event_tx.send(DownloadEvent::TaskFailed {
                            task_id,
                            error: e.to_string(),
                        });

                        // 更新任务状态
                        let mut tasks_guard = tasks.write().await;
                        if let Some(task) = tasks_guard.get_mut(&task_id) {
                            task.mark_failed(e.to_string(), 0);
                        }
                    }
                });
            }
            DownloadSource::Ftp { .. } => {
                warn!("暂不支持 FTP 协议");
                return Err(NebulaError::UnsupportedProtocol("FTP".to_string()));
            }
            DownloadSource::Video { url, format_id } => {
                let download_dir = self.config.download_dir.clone();
                let url_clone = url.clone();
                let format_id_clone = format_id.clone();
                
                tokio::spawn(async move {
                    // 创建 VideoHandler
                    let handler = match VideoHandler::new(download_dir.clone()) {
                        Ok(h) => h,
                        Err(e) => {
                            error!("创建 VideoHandler 失败: {}", e);
                            let _ = event_tx.send(DownloadEvent::TaskFailed {
                                task_id,
                                error: e.to_string(),
                            });
                            return;
                        }
                    };

                    // 1. 先获取视频信息
                    info!("获取视频信息: {}", url_clone);
                    match handler.get_video_info(&url_clone).await {
                        Ok(video_info) => {
                            // 发送元数据事件，更新任务名称
                            let _ = event_tx.send(DownloadEvent::MetadataReceived {
                                task_id,
                                name: video_info.title.clone(),
                                total_size: 0, // 视频大小在下载时才知道
                                file_count: 1,
                            });

                            // 更新任务名称
                            {
                                let mut tasks_guard = tasks.write().await;
                                if let Some(task) = tasks_guard.get_mut(&task_id) {
                                    task.name = video_info.title.clone();
                                    task.mark_started();
                                }
                            }

                            // 2. 开始下载
                            let (tx, mut rx) = tokio::sync::mpsc::channel(100);
                            
                            // 转发事件到 broadcast channel
                            let event_tx_clone = event_tx.clone();
                            tokio::spawn(async move {
                                while let Some(event) = rx.recv().await {
                                    let _ = event_tx_clone.send(event);
                                }
                            });

                            if let Err(e) = handler
                                .download_video(&url_clone, format_id_clone.as_deref(), tx, task_id)
                                .await
                            {
                                error!("视频下载失败: {}", e);
                                let _ = event_tx.send(DownloadEvent::TaskFailed {
                                    task_id,
                                    error: e.to_string(),
                                });

                                let mut tasks_guard = tasks.write().await;
                                if let Some(task) = tasks_guard.get_mut(&task_id) {
                                    task.mark_failed(e.to_string(), 0);
                                }
                            } else {
                                let mut tasks_guard = tasks.write().await;
                                if let Some(task) = tasks_guard.get_mut(&task_id) {
                                    task.mark_completed();
                                }
                            }
                        }
                        Err(e) => {
                            error!("获取视频信息失败: {}", e);
                            let _ = event_tx.send(DownloadEvent::TaskFailed {
                                task_id,
                                error: format!("获取视频信息失败: {}", e),
                            });
                        }
                    }
                });
            }
        }

        Ok(task_id)
    }

    /// 暂停下载任务
    pub async fn pause(&self, task_id: TaskId) -> Result<()> {
        let task = {
            let tasks = self.tasks.read().await;
            tasks.get(&task_id).cloned()
        };

        let task = task.ok_or_else(|| NebulaError::TaskNotFound(task_id.to_string()))?;

        if !task.status.can_pause() {
            return Err(NebulaError::InvalidTaskState {
                current: task.status.description(),
                action: "暂停".to_string(),
            });
        }

        // 根据协议类型调用对应处理器
        match &task.source {
            DownloadSource::Http { .. } => {
                self.http_handler.pause(task_id).await?;
            }
            DownloadSource::Magnet { .. } | DownloadSource::Torrent { .. } => {
                if let Some(ref handler) = self.torrent_handler {
                    handler.pause(task_id).await?;
                } else {
                    return Err(NebulaError::UnsupportedProtocol("BitTorrent 未初始化".to_string()));
                }
            }
            _ => return Err(NebulaError::UnsupportedProtocol("Unsupported".to_string())),
        }

        // 更新任务状态
        {
            let mut tasks = self.tasks.write().await;
            if let Some(task) = tasks.get_mut(&task_id) {
                task.status = TaskStatus::Paused;
            }
        }

        let _ = self.event_tx.send(DownloadEvent::TaskPaused { task_id });

        Ok(())
    }

    /// 恢复下载任务
    pub async fn resume(&self, task_id: TaskId) -> Result<()> {
        let task = {
            let tasks = self.tasks.read().await;
            tasks.get(&task_id).cloned()
        };

        let task = task.ok_or_else(|| NebulaError::TaskNotFound(task_id.to_string()))?;

        if !task.status.can_resume() {
            return Err(NebulaError::InvalidTaskState {
                current: task.status.description(),
                action: "恢复".to_string(),
            });
        }

        // 根据协议类型调用对应处理器
        match &task.source {
            DownloadSource::Http { .. } => {
                self.http_handler.resume(task_id).await?;
            }
            DownloadSource::Magnet { .. } | DownloadSource::Torrent { .. } => {
                if let Some(ref handler) = self.torrent_handler {
                    handler.resume(task_id).await?;
                } else {
                    return Err(NebulaError::UnsupportedProtocol("BitTorrent 未初始化".to_string()));
                }
            }
            _ => return Err(NebulaError::UnsupportedProtocol("Unsupported".to_string())),
        }

        // 更新任务状态
        {
            let mut tasks = self.tasks.write().await;
            if let Some(task) = tasks.get_mut(&task_id) {
                task.status = TaskStatus::Downloading;
            }
        }

        let _ = self.event_tx.send(DownloadEvent::TaskResumed { task_id });

        Ok(())
    }

    /// 取消下载任务
    ///
    /// # 参数
    /// - `task_id`: 任务 ID
    /// - `delete_files`: 是否删除已下载的文件
    pub async fn cancel(&self, task_id: TaskId, delete_files: bool) -> Result<()> {
        let task = {
            let mut tasks = self.tasks.write().await;
            tasks.remove(&task_id)
        };

        let task = task.ok_or_else(|| NebulaError::TaskNotFound(task_id.to_string()))?;

        // 根据协议类型调用对应处理器
        match &task.source {
            DownloadSource::Http { .. } => {
                let _ = self.http_handler.cancel(task_id, delete_files).await;
            }
            DownloadSource::Magnet { .. } | DownloadSource::Torrent { .. } => {
                if let Some(ref handler) = self.torrent_handler {
                    let _ = handler.cancel(task_id, delete_files).await;
                }
            }
            _ => {}
        }

        let _ = self.event_tx.send(DownloadEvent::TaskRemoved { task_id });

        Ok(())
    }

    /// 获取任务信息
    pub async fn get_task(&self, task_id: TaskId) -> Option<DownloadTask> {
        let tasks = self.tasks.read().await;
        tasks.get(&task_id).cloned()
    }

    /// 获取所有任务列表
    pub async fn list_tasks(&self) -> Vec<DownloadTask> {
        let tasks = self.tasks.read().await;
        tasks.values().cloned().collect()
    }

    /// 获取下载进度
    pub async fn get_progress(&self, task_id: TaskId) -> Result<Progress> {
        let task = {
            let tasks = self.tasks.read().await;
            tasks.get(&task_id).cloned()
        };

        let task = task.ok_or_else(|| NebulaError::TaskNotFound(task_id.to_string()))?;

        match &task.source {
            DownloadSource::Http { .. } => self.http_handler.get_progress(task_id).await,
            DownloadSource::Magnet { .. } | DownloadSource::Torrent { .. } => {
                if let Some(ref handler) = self.torrent_handler {
                    handler.get_progress(task_id).await
                } else {
                    Err(NebulaError::UnsupportedProtocol("BitTorrent 未初始化".to_string()))
                }
            }
            _ => Err(NebulaError::UnsupportedProtocol("Unsupported".to_string())),
        }
    }

    /// 订阅下载事件流
    ///
    /// 返回一个接收器，可用于监听所有下载事件
    pub fn subscribe(&self) -> broadcast::Receiver<DownloadEvent> {
        self.event_tx.subscribe()
    }

    /// 获取当前配置
    pub fn config(&self) -> &ManagerConfig {
        &self.config
    }

    /// 获取下载目录
    pub fn download_dir(&self) -> &PathBuf {
        &self.config.download_dir
    }

    /// 获取活跃任务数量
    pub async fn active_task_count(&self) -> usize {
        let tasks = self.tasks.read().await;
        tasks.values().filter(|t| t.status.is_active()).count()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_source_detection() {
        let config = ManagerConfig::default();
        let manager = DownloadManager::new(config).await;
        assert!(manager.is_ok());
    }
}
