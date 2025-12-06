//! 统一错误类型定义
//!
//! 使用 `thiserror` 定义所有可能的错误类型，方便错误处理和传播。

use std::path::PathBuf;
use thiserror::Error;

/// Nebula 核心库统一错误类型
#[derive(Error, Debug)]
pub enum NebulaError {
    // ===== 任务相关错误 =====
    /// 任务不存在
    #[error("任务不存在: {0}")]
    TaskNotFound(String),

    /// 任务状态无效（例如：尝试暂停已完成的任务）
    #[error("任务状态无效: 当前状态为 {current}，无法执行 {action}")]
    InvalidTaskState {
        /// 当前状态
        current: String,
        /// 尝试执行的操作
        action: String,
    },

    /// 任务已存在（重复添加）
    #[error("任务已存在: {0}")]
    TaskAlreadyExists(String),

    // ===== 协议相关错误 =====
    /// 不支持的协议
    #[error("不支持的协议: {0}")]
    UnsupportedProtocol(String),

    /// 无效的 URL 格式
    #[error("无效的 URL: {0}")]
    InvalidUrl(String),

    /// 无效的磁力链接
    #[error("无效的磁力链接: {0}")]
    InvalidMagnet(String),

    /// Torrent 文件解析失败
    #[error("Torrent 文件解析失败: {0}")]
    TorrentParseError(String),

    // ===== 网络相关错误 =====
    /// 网络连接失败
    #[error("网络连接失败: {0}")]
    NetworkError(String),

    /// HTTP 请求失败
    #[error("HTTP 请求失败: 状态码 {status_code} - {message}")]
    HttpError {
        /// HTTP 状态码
        status_code: u16,
        /// 错误信息
        message: String,
    },

    /// 服务器不支持断点续传
    #[error("服务器不支持断点续传")]
    ResumeNotSupported,

    /// 连接超时
    #[error("连接超时: {0}")]
    Timeout(String),

    // ===== 文件系统错误 =====
    /// 文件 IO 错误
    #[error("文件操作失败: {path} - {message}")]
    IoError {
        /// 文件路径
        path: PathBuf,
        /// 错误信息
        message: String,
    },

    /// 磁盘空间不足
    #[error("磁盘空间不足: 需要 {required} 字节，可用 {available} 字节")]
    InsufficientDiskSpace {
        /// 需要的空间
        required: u64,
        /// 可用空间
        available: u64,
    },

    /// 权限不足
    #[error("权限不足: {0}")]
    PermissionDenied(String),

    // ===== BitTorrent 相关错误 =====
    /// DHT 启动失败
    #[error("DHT 网络启动失败: {0}")]
    DhtError(String),

    /// Tracker 连接失败
    #[error("Tracker 连接失败: {0}")]
    TrackerError(String),

    /// 没有可用的 Peer
    #[error("没有可用的 Peer")]
    NoPeersAvailable,

    // ===== 配置相关错误 =====
    /// 配置无效
    #[error("配置无效: {0}")]
    InvalidConfig(String),

    // ===== 内部错误 =====
    /// 内部错误（不应该发生）
    #[error("内部错误: {0}")]
    Internal(String),

    /// 第三方库错误包装
    #[error(transparent)]
    Other(#[from] anyhow::Error),
}

/// Nebula 核心库 Result 类型别名
pub type Result<T> = std::result::Result<T, NebulaError>;

// ===== 错误转换实现 =====

impl From<std::io::Error> for NebulaError {
    fn from(err: std::io::Error) -> Self {
        NebulaError::IoError {
            path: PathBuf::new(),
            message: err.to_string(),
        }
    }
}

impl From<reqwest::Error> for NebulaError {
    fn from(err: reqwest::Error) -> Self {
        if err.is_timeout() {
            NebulaError::Timeout(err.to_string())
        } else if err.is_connect() {
            NebulaError::NetworkError(err.to_string())
        } else if let Some(status) = err.status() {
            NebulaError::HttpError {
                status_code: status.as_u16(),
                message: err.to_string(),
            }
        } else {
            NebulaError::NetworkError(err.to_string())
        }
    }
}

impl From<url::ParseError> for NebulaError {
    fn from(err: url::ParseError) -> Self {
        NebulaError::InvalidUrl(err.to_string())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_error_display() {
        let err = NebulaError::TaskNotFound("task-123".to_string());
        assert!(err.to_string().contains("task-123"));

        let err = NebulaError::InvalidTaskState {
            current: "已完成".to_string(),
            action: "暂停".to_string(),
        };
        assert!(err.to_string().contains("已完成"));
        assert!(err.to_string().contains("暂停"));
    }
}
