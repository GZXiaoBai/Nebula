//! # Nebula Core - 核心下载引擎
//!
//! Nebula 的核心下载库，提供统一的下载管理接口，支持以下协议：
//!
//! - **HTTP/HTTPS**: 多线程下载，断点续传
//! - **BitTorrent**: 磁力链接，.torrent 文件，DHT 网络
//!
//! ## 快速开始
//!
//! ```rust,ignore
//! use nebula_core::{DownloadManager, ManagerConfig};
//!
//! #[tokio::main]
//! async fn main() -> anyhow::Result<()> {
//!     // 创建下载管理器
//!     let config = ManagerConfig::default();
//!     let manager = DownloadManager::new(config).await?;
//!
//!     // 添加磁力链接下载任务
//!     let task_id = manager.add_task(
//!         "magnet:?xt=urn:btih:...",
//!         "/path/to/downloads".into(),
//!     ).await?;
//!
//!     // 订阅进度事件
//!     let mut events = manager.subscribe();
//!     while let Ok(event) = events.recv().await {
//!         println!("进度: {:?}", event);
//!     }
//!
//!     Ok(())
//! }
//! ```
//!
//! ## 模块结构
//!
//! - [`manager`]: 下载管理器，统一调度所有下载任务
//! - [`task`]: 下载任务定义和状态管理
//! - [`protocol`]: 协议处理模块（HTTP、BitTorrent）
//! - [`event`]: 事件系统，用于进度通知
//! - [`config`]: 配置管理
//! - [`error`]: 统一错误类型

pub mod config;
pub mod error;
pub mod event;
pub mod manager;
pub mod protocol;
pub mod task;

// 重新导出常用类型，方便外部使用
pub use config::ManagerConfig;
pub use error::{NebulaError, Result};
pub use event::{DownloadEvent, Progress};
pub use manager::DownloadManager;
pub use task::{DownloadSource, DownloadTask, TaskId, TaskStatus};
