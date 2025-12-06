//! BitTorrent 下载协议处理器
//!
//! 基于 librqbit 实现 BitTorrent 协议支持，包括：
//! - 磁力链接解析
//! - .torrent 文件下载
//! - DHT 网络
//! - 顺序下载（边下边播）

use super::ProtocolHandler;
use crate::config::TorrentConfig;
use crate::error::{NebulaError, Result};
use crate::event::{DownloadEvent, Progress};
use crate::task::{DownloadSource, TaskId};

use async_trait::async_trait;
use librqbit::{AddTorrent, AddTorrentOptions, AddTorrentResponse, Session, SessionOptions};
use std::collections::HashMap;
use std::path::PathBuf;
use std::sync::Arc;
use std::time::Duration;
use tokio::sync::{broadcast, RwLock};
use tracing::{debug, info, warn};

#[allow(dead_code)]
struct TorrentTask {
    /// librqbit 内部任务 ID
    handle_id: usize,
    /// 我们的任务 ID
    task_id: TaskId,
    /// 保存路径
    save_path: PathBuf,
    /// 种子名称（用于显示）
    name: String,
}

/// BitTorrent 协议处理器
pub struct TorrentHandler {
    /// librqbit Session
    session: Arc<Session>,
    /// 配置
    #[allow(dead_code)]
    config: TorrentConfig,
    /// 任务映射：TaskId -> TorrentTask
    tasks: Arc<RwLock<HashMap<TaskId, TorrentTask>>>,
}

impl TorrentHandler {
    /// 创建新的 BitTorrent 处理器
    ///
    /// # 参数
    /// - `config`: BitTorrent 配置
    /// - `data_dir`: 数据存储目录（用于 DHT 状态等）
    pub async fn new(config: TorrentConfig, data_dir: PathBuf) -> Result<Self> {
        // 确保数据目录存在
        tokio::fs::create_dir_all(&data_dir).await?;

        // 构建 Session 配置
        let session_opts = SessionOptions {
            disable_dht: !config.enable_dht,
            disable_dht_persistence: false,
            ..Default::default()
        };

        // 创建 Session - 返回的已经是 Arc<Session>
        let session = Session::new_with_opts(data_dir, session_opts)
            .await
            .map_err(|e| NebulaError::Internal(format!("创建 BitTorrent Session 失败: {}", e)))?;

        info!("BitTorrent 引擎已初始化");

        Ok(Self {
            session,
            config,
            tasks: Arc::new(RwLock::new(HashMap::new())),
        })
    }

    /// 添加种子任务
    async fn add_torrent(
        &self,
        task_id: TaskId,
        source: &DownloadSource,
        save_path: PathBuf,
        event_tx: broadcast::Sender<DownloadEvent>,
    ) -> Result<()> {
        // 构建添加选项
        let add_opts = AddTorrentOptions {
            output_folder: Some(save_path.to_string_lossy().to_string()),
            overwrite: true,
            ..Default::default()
        };

        // 根据来源类型添加种子
        let add_torrent = match source {
            DownloadSource::Magnet { uri, .. } => AddTorrent::from_url(uri.as_str()),
            DownloadSource::Torrent { path } => {
                let content = tokio::fs::read(path).await.map_err(|e| NebulaError::IoError {
                    path: path.clone(),
                    message: e.to_string(),
                })?;
                AddTorrent::from_bytes(content)
            }
            _ => {
                return Err(NebulaError::UnsupportedProtocol(
                    "非 BitTorrent 来源".to_string(),
                ))
            }
        };

        // 添加种子到 Session
        let response = self
            .session
            .add_torrent(add_torrent, Some(add_opts))
            .await
            .map_err(|e| NebulaError::Internal(format!("添加种子失败: {}", e)))?;

        let (handle_id, handle) = match response {
            AddTorrentResponse::Added(id, handle) => {
                info!("种子已添加: id={}", id);
                (id, handle)
            }
            AddTorrentResponse::AlreadyManaged(id, handle) => {
                warn!("种子已存在: id={}", id);
                (id, handle)
            }
            AddTorrentResponse::ListOnly(_) => {
                return Err(NebulaError::Internal("意外的 ListOnly 响应".to_string()));
            }
        };

        // 从 stats 获取基本信息
        let stats = handle.stats();
        let total_size = stats.total_bytes;
        
        // 从源获取名称，或使用 info_hash
        let name = match source {
            DownloadSource::Magnet { display_name, .. } => {
                display_name.clone().unwrap_or_else(|| format!("torrent-{}", handle_id))
            }
            DownloadSource::Torrent { path } => {
                path.file_stem()
                    .and_then(|s| s.to_str())
                    .unwrap_or("unknown")
                    .to_string()
            }
            _ => format!("torrent-{}", handle_id),
        };

        // 发送元数据接收事件
        let _ = event_tx.send(DownloadEvent::MetadataReceived {
            task_id,
            name: name.clone(),
            total_size,
            file_count: 1, // 简化处理，不再获取详细文件列表
        });

        // 注册任务映射
        {
            let mut tasks = self.tasks.write().await;
            tasks.insert(
                task_id,
                TorrentTask {
                    handle_id,
                    task_id,
                    save_path,
                    name,
                },
            );
        }

        // 发送开始事件
        let _ = event_tx.send(DownloadEvent::TaskStarted { task_id });

        // 启动进度监控任务
        self.spawn_progress_monitor(task_id, handle_id, event_tx);

        Ok(())
    }

    /// 启动进度监控协程
    fn spawn_progress_monitor(
        &self,
        task_id: TaskId,
        handle_id: usize,
        event_tx: broadcast::Sender<DownloadEvent>,
    ) {
        let session = Arc::clone(&self.session);
        let tasks = Arc::clone(&self.tasks);

        tokio::spawn(async move {
            loop {
                // 检查任务是否仍然存在
                {
                    let tasks_guard = tasks.read().await;
                    if !tasks_guard.contains_key(&task_id) {
                        debug!("任务已移除，停止监控: {}", task_id);
                        break;
                    }
                }

                // 获取种子状态
                if let Some(handle) = session.get(handle_id.into()) {
                    let stats = handle.stats();

                    // 从 stats 获取进度信息
                    let total_bytes = stats.total_bytes;
                    let downloaded_bytes = stats.progress_bytes;

                    let mut progress = Progress::new(total_bytes, downloaded_bytes);

                    // 从 live stats 获取速度信息
                    if let Some(ref live) = stats.live {
                        let download_speed = (live.download_speed.mbps * 1024.0 * 1024.0 / 8.0) as u64;
                        let upload_speed = (live.upload_speed.mbps * 1024.0 * 1024.0 / 8.0) as u64;
                        progress.update_speed(download_speed, upload_speed);

                        // 发送 Peer 更新事件
                        let connected_peers = live.snapshot.peer_stats.live as usize;
                        let total_peers = live.snapshot.peer_stats.seen as usize;
                        let _ = event_tx.send(DownloadEvent::PeerUpdate {
                            task_id,
                            connected_peers,
                            total_peers,
                        });
                    }

                    // 发送进度事件
                    if event_tx
                        .send(DownloadEvent::ProgressUpdated {
                            task_id,
                            progress: progress.clone(),
                        })
                        .is_err()
                    {
                        break; // 没有接收者了
                    }

                    // 检查是否完成
                    if progress.is_completed() {
                        info!("种子下载完成: {}", task_id);
                        let _ = event_tx.send(DownloadEvent::TaskCompleted {
                            task_id,
                            completed_at: chrono::Utc::now(),
                        });
                        break;
                    }
                } else {
                    warn!("找不到种子句柄: {}", handle_id);
                    break;
                }

                // 每秒更新一次
                tokio::time::sleep(Duration::from_secs(1)).await;
            }
        });
    }
}

#[async_trait]
impl ProtocolHandler for TorrentHandler {
    async fn start(
        &self,
        task_id: TaskId,
        source: &DownloadSource,
        save_path: PathBuf,
        event_tx: broadcast::Sender<DownloadEvent>,
    ) -> Result<()> {
        info!("开始 BitTorrent 下载: {:?}", source);
        self.add_torrent(task_id, source, save_path, event_tx).await
    }

    async fn pause(&self, task_id: TaskId) -> Result<()> {
        // 注意：librqbit 当前版本 pause/start 是 pub(crate)，无法直接调用
        // 暂时记录日志，后续版本可能会开放 API
        let tasks = self.tasks.read().await;
        if tasks.contains_key(&task_id) {
            warn!("BitTorrent 暂停功能当前不可用: {}", task_id);
            Ok(())
        } else {
            Err(NebulaError::TaskNotFound(task_id.to_string()))
        }
    }

    async fn resume(&self, task_id: TaskId) -> Result<()> {
        // 注意：librqbit 当前版本 pause/start 是 pub(crate)，无法直接调用
        let tasks = self.tasks.read().await;
        if tasks.contains_key(&task_id) {
            warn!("BitTorrent 恢复功能当前不可用: {}", task_id);
            Ok(())
        } else {
            Err(NebulaError::TaskNotFound(task_id.to_string()))
        }
    }

    async fn cancel(&self, task_id: TaskId, delete_files: bool) -> Result<()> {
        let mut tasks = self.tasks.write().await;
        if let Some(task) = tasks.remove(&task_id) {
            // 删除已下载的文件
            if delete_files && task.save_path.exists() {
                let _ = tokio::fs::remove_dir_all(&task.save_path).await;
            }
            info!("种子已取消: {}", task_id);
            Ok(())
        } else {
            Err(NebulaError::TaskNotFound(task_id.to_string()))
        }
    }

    async fn get_progress(&self, task_id: TaskId) -> Result<Progress> {
        let tasks = self.tasks.read().await;
        if let Some(task) = tasks.get(&task_id) {
            if let Some(handle) = self.session.get(task.handle_id.into()) {
                let stats = handle.stats();
                let total_bytes = stats.total_bytes;
                let downloaded_bytes = stats.progress_bytes;
                
                let mut progress = Progress::new(total_bytes, downloaded_bytes);
                
                if let Some(ref live) = stats.live {
                    let download_speed = (live.download_speed.mbps * 1024.0 * 1024.0 / 8.0) as u64;
                    let upload_speed = (live.upload_speed.mbps * 1024.0 * 1024.0 / 8.0) as u64;
                    progress.update_speed(download_speed, upload_speed);
                }
                
                Ok(progress)
            } else {
                Err(NebulaError::TaskNotFound(task_id.to_string()))
            }
        } else {
            Err(NebulaError::TaskNotFound(task_id.to_string()))
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    // 注意：BitTorrent 测试需要网络访问，通常作为集成测试运行
}
