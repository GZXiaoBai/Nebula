//! Nebula 下载 API
//!
//! 暴露给 Flutter/Dart 的下载功能接口

use crate::frb_generated::StreamSink;
use flutter_rust_bridge::frb;
use nebula_core::{DownloadEvent, DownloadManager, ManagerConfig, Progress};
use std::path::PathBuf;
use std::sync::Arc;
use tokio::sync::RwLock;

/// 全局下载管理器实例
static MANAGER: RwLock<Option<Arc<DownloadManager>>> = RwLock::const_new(None);

/// 进度事件（传递给 Dart）
#[frb(dart_metadata = ("freezed"))]
pub struct ProgressEvent {
    pub task_id: String,
    pub total_size: u64,
    pub downloaded_size: u64,
    pub download_speed: u64,
    pub percentage: f64,
    pub eta_secs: Option<u64>,
}

impl From<&Progress> for ProgressEvent {
    fn from(p: &Progress) -> Self {
        Self {
            task_id: String::new(),
            total_size: p.total_size,
            downloaded_size: p.downloaded_size,
            download_speed: p.download_speed,
            percentage: p.percentage,
            eta_secs: p.eta_secs,
        }
    }
}

/// 下载事件类型
#[frb(dart_metadata = ("freezed"))]
pub enum NebulaEvent {
    TaskAdded { task_id: String, name: String },
    TaskStarted { task_id: String },
    ProgressUpdated { task_id: String, progress: ProgressEvent },
    TaskCompleted { task_id: String },
    TaskFailed { task_id: String, error: String },
    TaskPaused { task_id: String },
    TaskResumed { task_id: String },
    TaskRemoved { task_id: String },
    MetadataReceived { task_id: String, name: String, total_size: u64, file_count: usize },
}

/// 初始化下载管理器
///
/// 必须在使用其他下载功能之前调用
#[frb]
pub async fn init_download_manager(download_dir: String) -> Result<(), String> {
    let config = ManagerConfig {
        download_dir: PathBuf::from(&download_dir),
        ..Default::default()
    };

    let manager = DownloadManager::new(config)
        .await
        .map_err(|e| e.to_string())?;

    let mut guard = MANAGER.write().await;
    *guard = Some(Arc::new(manager));

    tracing::info!("下载管理器已初始化: {}", download_dir);
    Ok(())
}

/// 添加下载任务
///
/// 自动识别 URL 类型（HTTP/磁力链接/种子文件）
#[frb]
pub async fn add_download(source: String, save_path: String) -> Result<String, String> {
    let guard = MANAGER.read().await;
    let manager = guard.as_ref().ok_or("下载管理器未初始化")?;

    let task_id = manager
        .add_task(&source, PathBuf::from(&save_path))
        .await
        .map_err(|e| e.to_string())?;

    Ok(task_id.to_string())
}

/// 暂停下载任务
#[frb]
pub async fn pause_download(task_id: String) -> Result<(), String> {
    let guard = MANAGER.read().await;
    let manager = guard.as_ref().ok_or("下载管理器未初始化")?;

    let id = nebula_core::TaskId::from_string(&task_id)
        .map_err(|e| format!("无效的任务 ID: {}", e))?;

    manager.pause(id).await.map_err(|e| e.to_string())
}

/// 恢复下载任务
#[frb]
pub async fn resume_download(task_id: String) -> Result<(), String> {
    let guard = MANAGER.read().await;
    let manager = guard.as_ref().ok_or("下载管理器未初始化")?;

    let id = nebula_core::TaskId::from_string(&task_id)
        .map_err(|e| format!("无效的任务 ID: {}", e))?;

    manager.resume(id).await.map_err(|e| e.to_string())
}

/// 取消下载任务
#[frb]
pub async fn cancel_download(task_id: String, delete_files: bool) -> Result<(), String> {
    let guard = MANAGER.read().await;
    let manager = guard.as_ref().ok_or("下载管理器未初始化")?;

    let id = nebula_core::TaskId::from_string(&task_id)
        .map_err(|e| format!("无效的任务 ID: {}", e))?;

    manager.cancel(id, delete_files).await.map_err(|e| e.to_string())
}

/// 订阅下载事件流
///
/// 返回一个 Stream，用于接收下载进度和状态变化
#[frb(stream_dart_await)]
pub async fn subscribe_events(sink: StreamSink<NebulaEvent>) -> Result<(), String> {
    let guard = MANAGER.read().await;
    let manager = guard.as_ref().ok_or("下载管理器未初始化")?;

    let mut receiver = manager.subscribe();

    // 在后台任务中处理事件
    tokio::spawn(async move {
        while let Ok(event) = receiver.recv().await {
            let nebula_event = match event {
                DownloadEvent::TaskAdded { task_id, name } => {
                    NebulaEvent::TaskAdded {
                        task_id: task_id.to_string(),
                        name,
                    }
                }
                DownloadEvent::TaskStarted { task_id } => {
                    NebulaEvent::TaskStarted {
                        task_id: task_id.to_string(),
                    }
                }
                DownloadEvent::ProgressUpdated { task_id, progress } => {
                    let mut pe = ProgressEvent::from(&progress);
                    pe.task_id = task_id.to_string();
                    NebulaEvent::ProgressUpdated {
                        task_id: task_id.to_string(),
                        progress: pe,
                    }
                }
                DownloadEvent::TaskCompleted { task_id, .. } => {
                    NebulaEvent::TaskCompleted {
                        task_id: task_id.to_string(),
                    }
                }
                DownloadEvent::TaskFailed { task_id, error } => {
                    NebulaEvent::TaskFailed {
                        task_id: task_id.to_string(),
                        error,
                    }
                }
                DownloadEvent::TaskPaused { task_id } => {
                    NebulaEvent::TaskPaused {
                        task_id: task_id.to_string(),
                    }
                }
                DownloadEvent::TaskResumed { task_id } => {
                    NebulaEvent::TaskResumed {
                        task_id: task_id.to_string(),
                    }
                }
                DownloadEvent::TaskRemoved { task_id } => {
                    NebulaEvent::TaskRemoved {
                        task_id: task_id.to_string(),
                    }
                }
                DownloadEvent::MetadataReceived { task_id, name, total_size, file_count } => {
                    NebulaEvent::MetadataReceived {
                        task_id: task_id.to_string(),
                        name,
                        total_size,
                        file_count,
                    }
                }
                DownloadEvent::PeerUpdate { .. } => continue, // 跳过 Peer 更新事件
            };

            if sink.add(nebula_event).is_err() {
                break; // 接收端已关闭
            }
        }
    });

    Ok(())
}

/// 视频信息（传递给 Dart）
#[frb(dart_metadata = ("freezed"))]
pub struct VideoInfo {
    pub id: String,
    pub title: String,
    pub thumbnail: Option<String>,
    pub duration: Option<u64>,
    pub uploader: Option<String>,
    pub formats: Vec<VideoFormat>,
}

/// 视频格式选项
#[frb(dart_metadata = ("freezed"))]
pub struct VideoFormat {
    pub format_id: String,
    pub ext: String,
    pub resolution: Option<String>,
    pub filesize: Option<u64>,
    pub format_note: Option<String>,
}

/// 检查 URL 是否为视频网站
#[frb]
pub fn is_video_url(url: String) -> bool {
    nebula_core::protocol::video::VideoHandler::is_video_url(&url)
}

/// 获取视频信息
///
/// 需要系统已安装 yt-dlp
#[frb]
pub async fn get_video_info(url: String) -> Result<VideoInfo, String> {
    let guard = MANAGER.read().await;
    let manager = guard.as_ref().ok_or("下载管理器未初始化")?;

    let handler = nebula_core::protocol::video::VideoHandler::new(manager.download_dir().clone())
        .map_err(|e| e.to_string())?;

    let info = handler.get_video_info(&url).await.map_err(|e| e.to_string())?;

    Ok(VideoInfo {
        id: info.id,
        title: info.title,
        thumbnail: info.thumbnail,
        duration: info.duration,
        uploader: info.uploader,
        formats: info
            .formats
            .into_iter()
            .map(|f| VideoFormat {
                format_id: f.format_id,
                ext: f.ext,
                resolution: f.resolution,
                filesize: f.filesize,
                format_note: f.format_note,
            })
            .collect(),
    })
}
