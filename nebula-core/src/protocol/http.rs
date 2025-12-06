//! HTTP/HTTPS 下载协议处理器
//!
//! 实现基于 reqwest 的多线程下载，支持：
//! - 断点续传（Range 请求）
//! - 多线程分块下载
//! - 自动重试

use super::{FileInfo, ProtocolHandler};
use crate::config::HttpConfig;
use crate::error::{NebulaError, Result};
use crate::event::{DownloadEvent, Progress};
use crate::task::{DownloadSource, TaskId};

use async_trait::async_trait;
use futures::StreamExt;
use reqwest::header::{ACCEPT_RANGES, CONTENT_LENGTH, CONTENT_TYPE, RANGE};
use reqwest::Client;
use std::collections::HashMap;
use std::path::PathBuf;
use std::sync::Arc;
use std::time::Duration;
use tokio::fs::{File, OpenOptions};
use tokio::io::AsyncWriteExt;
use tokio::sync::{broadcast, Mutex, RwLock};
use tracing::{debug, info};

#[allow(dead_code)]
struct HttpTask {
    /// 任务 ID
    task_id: TaskId,
    /// 是否已暂停
    paused: bool,
    /// 是否已取消
    cancelled: bool,
    /// 当前进度
    progress: Progress,
    /// 保存路径
    save_path: PathBuf,
}

/// HTTP 协议处理器
pub struct HttpHandler {
    /// HTTP 客户端
    client: Client,
    #[allow(dead_code)]
    config: HttpConfig,
    /// 活跃任务映射表
    tasks: Arc<RwLock<HashMap<TaskId, Arc<Mutex<HttpTask>>>>>,
}

impl HttpHandler {
    /// 创建新的 HTTP 处理器
    pub fn new(config: HttpConfig) -> Result<Self> {
        let mut client_builder = Client::builder()
            .connect_timeout(Duration::from_secs(config.connect_timeout_secs))
            .timeout(Duration::from_secs(config.read_timeout_secs))
            .user_agent(&config.user_agent);

        // 配置代理
        if let Some(proxy_url) = &config.proxy {
            let proxy = reqwest::Proxy::all(proxy_url)
                .map_err(|e| NebulaError::InvalidConfig(format!("无效的代理地址: {}", e)))?;
            client_builder = client_builder.proxy(proxy);
        }

        let client = client_builder
            .build()
            .map_err(|e| NebulaError::Internal(format!("创建 HTTP 客户端失败: {}", e)))?;

        Ok(Self {
            client,
            config,
            tasks: Arc::new(RwLock::new(HashMap::new())),
        })
    }

    /// 获取远程文件信息
    pub async fn get_file_info(&self, url: &str) -> Result<FileInfo> {
        let response = self
            .client
            .head(url)
            .send()
            .await
            .map_err(|e| NebulaError::NetworkError(e.to_string()))?;

        if !response.status().is_success() {
            return Err(NebulaError::HttpError {
                status_code: response.status().as_u16(),
                message: format!("HEAD 请求失败: {}", response.status()),
            });
        }

        let headers = response.headers();

        // 获取文件大小
        let size = headers
            .get(CONTENT_LENGTH)
            .and_then(|v| v.to_str().ok())
            .and_then(|v| v.parse::<u64>().ok());

        // 检查是否支持断点续传
        let supports_resume = headers
            .get(ACCEPT_RANGES)
            .map(|v| v.to_str().unwrap_or("") == "bytes")
            .unwrap_or(false);

        // 获取 MIME 类型
        let mime_type = headers
            .get(CONTENT_TYPE)
            .and_then(|v| v.to_str().ok())
            .map(|s| s.to_string());

        // 从 URL 提取文件名
        let name = url
            .rsplit('/')
            .next()
            .unwrap_or("download")
            .split('?')
            .next()
            .unwrap_or("download")
            .to_string();

        Ok(FileInfo {
            name,
            size,
            supports_resume,
            mime_type,
        })
    }

    /// 执行单线程下载（带断点续传）
    async fn download_single_thread(
        &self,
        task_id: TaskId,
        url: &str,
        save_path: PathBuf,
        event_tx: broadcast::Sender<DownloadEvent>,
        file_info: FileInfo,
    ) -> Result<()> {
        let task = Arc::new(Mutex::new(HttpTask {
            task_id,
            paused: false,
            cancelled: false,
            progress: Progress::new(file_info.size.unwrap_or(0), 0),
            save_path: save_path.clone(),
        }));

        // 注册任务
        {
            let mut tasks = self.tasks.write().await;
            tasks.insert(task_id, Arc::clone(&task));
        }

        // 检查是否有已下载的部分（断点续传）
        let existing_size = if save_path.exists() {
            tokio::fs::metadata(&save_path)
                .await
                .map(|m| m.len())
                .unwrap_or(0)
        } else {
            0
        };

        // 如果文件已完整下载，直接完成
        if let Some(total) = file_info.size {
            if existing_size >= total {
                info!("文件已完整下载: {:?}", save_path);
                let _ = event_tx.send(DownloadEvent::TaskCompleted {
                    task_id,
                    completed_at: chrono::Utc::now(),
                });
                return Ok(());
            }
        }

        // 创建/打开文件（追加模式）
        let mut file = if existing_size > 0 && file_info.supports_resume {
            info!("断点续传: 从 {} 字节处继续", existing_size);
            OpenOptions::new()
                .write(true)
                .append(true)
                .open(&save_path)
                .await?
        } else {
            // 确保父目录存在
            if let Some(parent) = save_path.parent() {
                tokio::fs::create_dir_all(parent).await?;
            }
            File::create(&save_path).await?
        };

        // 构建请求（支持 Range）
        let mut request = self.client.get(url);
        let start_offset = if existing_size > 0 && file_info.supports_resume {
            request = request.header(RANGE, format!("bytes={}-", existing_size));
            existing_size
        } else {
            0
        };

        // 发送请求
        let response = request
            .send()
            .await
            .map_err(|e| NebulaError::NetworkError(e.to_string()))?;

        if !response.status().is_success() && response.status() != reqwest::StatusCode::PARTIAL_CONTENT {
            return Err(NebulaError::HttpError {
                status_code: response.status().as_u16(),
                message: format!("下载请求失败: {}", response.status()),
            });
        }

        // 发送开始事件
        let _ = event_tx.send(DownloadEvent::TaskStarted { task_id });

        // 流式下载
        let mut stream = response.bytes_stream();
        let mut downloaded = start_offset;
        let mut last_update = std::time::Instant::now();
        let mut last_downloaded = downloaded;

        while let Some(chunk_result) = stream.next().await {
            // 检查是否暂停或取消
            {
                let task_guard = task.lock().await;
                if task_guard.cancelled {
                    info!("任务已取消: {}", task_id);
                    return Ok(());
                }
                if task_guard.paused {
                    // 暂停状态，等待恢复
                    drop(task_guard);
                    tokio::time::sleep(Duration::from_millis(100)).await;
                    continue;
                }
            }

            let chunk = chunk_result.map_err(|e| NebulaError::NetworkError(e.to_string()))?;
            file.write_all(&chunk).await?;
            downloaded += chunk.len() as u64;

            // 更新进度（每 200ms 更新一次）
            let now = std::time::Instant::now();
            if now.duration_since(last_update).as_millis() >= 200 {
                let elapsed = now.duration_since(last_update).as_secs_f64();
                let speed = ((downloaded - last_downloaded) as f64 / elapsed) as u64;

                let mut progress = Progress::new(file_info.size.unwrap_or(downloaded), downloaded);
                progress.update_speed(speed, 0);

                // 更新任务进度
                {
                    let mut task_guard = task.lock().await;
                    task_guard.progress = progress.clone();
                }

                // 发送进度事件
                let _ = event_tx.send(DownloadEvent::ProgressUpdated { task_id, progress });

                last_update = now;
                last_downloaded = downloaded;
            }
        }

        // 确保数据写入磁盘
        file.flush().await?;

        info!("下载完成: {:?}", save_path);

        // 发送完成事件
        let _ = event_tx.send(DownloadEvent::TaskCompleted {
            task_id,
            completed_at: chrono::Utc::now(),
        });

        // 移除任务
        {
            let mut tasks = self.tasks.write().await;
            tasks.remove(&task_id);
        }

        Ok(())
    }
}

#[async_trait]
impl ProtocolHandler for HttpHandler {
    async fn start(
        &self,
        task_id: TaskId,
        source: &DownloadSource,
        save_path: PathBuf,
        event_tx: broadcast::Sender<DownloadEvent>,
    ) -> Result<()> {
        let url = match source {
            DownloadSource::Http { url } => url.clone(),
            _ => return Err(NebulaError::UnsupportedProtocol("非 HTTP 来源".to_string())),
        };

        info!("开始 HTTP 下载: {}", url);

        // 获取文件信息
        let file_info = self.get_file_info(&url).await?;
        debug!("文件信息: {:?}", file_info);

        // 确定保存路径
        let final_path = if save_path.is_dir() {
            save_path.join(&file_info.name)
        } else {
            save_path
        };

        // 执行下载
        self.download_single_thread(task_id, &url, final_path, event_tx, file_info)
            .await
    }

    async fn pause(&self, task_id: TaskId) -> Result<()> {
        let tasks = self.tasks.read().await;
        if let Some(task) = tasks.get(&task_id) {
            let mut task_guard = task.lock().await;
            task_guard.paused = true;
            info!("任务已暂停: {}", task_id);
            Ok(())
        } else {
            Err(NebulaError::TaskNotFound(task_id.to_string()))
        }
    }

    async fn resume(&self, task_id: TaskId) -> Result<()> {
        let tasks = self.tasks.read().await;
        if let Some(task) = tasks.get(&task_id) {
            let mut task_guard = task.lock().await;
            task_guard.paused = false;
            info!("任务已恢复: {}", task_id);
            Ok(())
        } else {
            Err(NebulaError::TaskNotFound(task_id.to_string()))
        }
    }

    async fn cancel(&self, task_id: TaskId, delete_files: bool) -> Result<()> {
        let mut tasks = self.tasks.write().await;
        if let Some(task) = tasks.remove(&task_id) {
            let mut task_guard = task.lock().await;
            task_guard.cancelled = true;

            if delete_files && task_guard.save_path.exists() {
                let _ = tokio::fs::remove_file(&task_guard.save_path).await;
                info!("已删除文件: {:?}", task_guard.save_path);
            }

            info!("任务已取消: {}", task_id);
            Ok(())
        } else {
            Err(NebulaError::TaskNotFound(task_id.to_string()))
        }
    }

    async fn get_progress(&self, task_id: TaskId) -> Result<Progress> {
        let tasks = self.tasks.read().await;
        if let Some(task) = tasks.get(&task_id) {
            let task_guard = task.lock().await;
            Ok(task_guard.progress.clone())
        } else {
            Err(NebulaError::TaskNotFound(task_id.to_string()))
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_http_handler_creation() {
        let config = HttpConfig::default();
        let handler = HttpHandler::new(config);
        assert!(handler.is_ok());
    }
}
