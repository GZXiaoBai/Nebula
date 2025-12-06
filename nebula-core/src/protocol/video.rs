//! 视频网站下载处理器
//!
//! 通过 yt-dlp 支持 Bilibili、YouTube 等 1000+ 网站

use serde::{Deserialize, Serialize};
use std::path::PathBuf;
use std::process::Stdio;
use tokio::io::{AsyncBufReadExt, BufReader};
use tokio::process::Command;
use tokio::sync::mpsc;
use tracing::{debug, error, info, warn};

use crate::error::{NebulaError, Result};
use crate::event::{DownloadEvent, Progress};
use crate::task::TaskId;

/// 视频格式信息
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct VideoFormat {
    pub format_id: String,
    pub ext: String,
    pub resolution: Option<String>,
    pub filesize: Option<u64>,
    pub vcodec: Option<String>,
    pub acodec: Option<String>,
    pub format_note: Option<String>,
}

/// 视频信息
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct VideoInfo {
    pub id: String,
    pub title: String,
    pub description: Option<String>,
    pub thumbnail: Option<String>,
    pub duration: Option<u64>,
    pub uploader: Option<String>,
    pub formats: Vec<VideoFormat>,
    pub webpage_url: String,
}

/// yt-dlp JSON 输出结构
#[derive(Debug, Deserialize)]
struct YtDlpInfo {
    id: String,
    title: String,
    description: Option<String>,
    thumbnail: Option<String>,
    duration: Option<f64>,
    uploader: Option<String>,
    formats: Option<Vec<YtDlpFormat>>,
    webpage_url: Option<String>,
}

#[derive(Debug, Deserialize)]
struct YtDlpFormat {
    format_id: String,
    ext: Option<String>,
    resolution: Option<String>,
    filesize: Option<u64>,
    filesize_approx: Option<u64>,
    vcodec: Option<String>,
    acodec: Option<String>,
    format_note: Option<String>,
}

/// 视频下载处理器
pub struct VideoHandler {
    yt_dlp_path: PathBuf,
    output_dir: PathBuf,
}

impl VideoHandler {
    /// 创建新的视频处理器
    pub fn new(output_dir: PathBuf) -> Result<Self> {
        // 查找 yt-dlp 路径
        let yt_dlp_path = Self::find_yt_dlp()?;
        info!("Found yt-dlp at: {:?}", yt_dlp_path);

        Ok(Self {
            yt_dlp_path,
            output_dir,
        })
    }

    /// 查找 yt-dlp 可执行文件
    /// 优先查找应用内嵌版本，然后查找系统安装版本
    fn find_yt_dlp() -> Result<PathBuf> {
        // 1. 首先查找应用 bundle 内的 yt-dlp
        if let Ok(exe_path) = std::env::current_exe() {
            // macOS: xxx.app/Contents/MacOS/nebula_app -> ../Resources/yt-dlp
            // Windows: target/release/nebula_app.exe -> ./yt-dlp.exe
            
            #[cfg(target_os = "macos")]
            {
                if let Some(macos_dir) = exe_path.parent() {
                    let bundle_path = macos_dir.parent()
                        .map(|contents| contents.join("Resources").join("yt-dlp"));
                    if let Some(p) = bundle_path {
                        if p.exists() {
                            info!("使用内嵌 yt-dlp (macOS): {:?}", p);
                            return Ok(p);
                        }
                    }
                }
            }

            #[cfg(target_os = "windows")]
            {
                if let Some(app_dir) = exe_path.parent() {
                    let p = app_dir.join("yt-dlp.exe");
                    if p.exists() {
                        info!("使用内嵌 yt-dlp (Windows): {:?}", p);
                        return Ok(p);
                    }
                }
            }
        }

        // 2. 查找常见系统路径
        let paths = [
            "/opt/homebrew/bin/yt-dlp",
            "/usr/local/bin/yt-dlp",
            "/usr/bin/yt-dlp",
        ];

        for path in paths {
            let p = PathBuf::from(path);
            if p.exists() {
                return Ok(p);
            }
        }

        // 3. 尝试 which 命令
        if let Ok(output) = std::process::Command::new("which")
            .arg("yt-dlp")
            .output()
        {
            if output.status.success() {
                let path = String::from_utf8_lossy(&output.stdout)
                    .trim()
                    .to_string();
                if !path.is_empty() {
                    return Ok(PathBuf::from(path));
                }
            }
        }

        Err(NebulaError::Internal(
            "yt-dlp 未找到".to_string(),
        ))
    }

    /// 查找 ffmpeg 可执行文件
    fn find_ffmpeg() -> Option<PathBuf> {
        // 1. 查找常见系统路径
        let paths = [
            "/opt/homebrew/bin/ffmpeg",
            "/usr/local/bin/ffmpeg",
            "/usr/bin/ffmpeg",
            "C:\\Program Files\\ffmpeg\\bin\\ffmpeg.exe", // Windows 常见路径
        ];

        for path in paths {
            let p = PathBuf::from(path);
            if p.exists() {
                debug!("找到 ffmpeg: {:?}", p);
                return Some(p);
            }
        }

        // 2. 尝试 which / where 命令
        let cmd = if cfg!(windows) { "where" } else { "which" };
        if let Ok(output) = std::process::Command::new(cmd)
            .arg("ffmpeg")
            .output()
        {
            if output.status.success() {
                let path = String::from_utf8_lossy(&output.stdout)
                    .trim()
                    .lines()
                    .next() // where 可能返回多行
                    .map(|s| s.to_string())
                    .unwrap_or_default();
                    
                if !path.is_empty() {
                    let p = PathBuf::from(path);
                    debug!("通过 {} 找到 ffmpeg: {:?}", cmd, p);
                    return Some(p);
                }
            }
        }

        warn!("未找到 ffmpeg，视频合并可能失败");
        None
    }

    /// 检查 URL 是否为支持的视频网站
    pub fn is_video_url(url: &str) -> bool {
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

    /// 获取视频信息
    pub async fn get_video_info(&self, url: &str) -> Result<VideoInfo> {
        info!("获取视频信息: {}", url);

        let output = Command::new(&self.yt_dlp_path)
            .args([
                "-j",
                "--no-warnings",
                "--no-playlist",
                url,
            ])
            .output()
            .await
            .map_err(|e| NebulaError::Internal(format!("执行 yt-dlp 失败: {}", e)))?;

        if !output.status.success() {
            let stderr = String::from_utf8_lossy(&output.stderr);
            return Err(NebulaError::Internal(format!(
                "获取视频信息失败: {}",
                stderr
            )));
        }

        let info: YtDlpInfo = serde_json::from_slice(&output.stdout)
            .map_err(|e| NebulaError::Internal(format!("解析视频信息失败: {}", e)))?;

        let formats = info
            .formats
            .unwrap_or_default()
            .into_iter()
            .filter(|f| {
                // 过滤掉只有音频或只有视频的格式
                f.vcodec.as_ref().map(|v| v != "none").unwrap_or(false)
                    || f.acodec.as_ref().map(|a| a != "none").unwrap_or(false)
            })
            .map(|f| VideoFormat {
                format_id: f.format_id,
                ext: f.ext.unwrap_or_else(|| "mp4".to_string()),
                resolution: f.resolution,
                filesize: f.filesize.or(f.filesize_approx),
                vcodec: f.vcodec,
                acodec: f.acodec,
                format_note: f.format_note,
            })
            .collect();

        Ok(VideoInfo {
            id: info.id,
            title: info.title,
            description: info.description,
            thumbnail: info.thumbnail,
            duration: info.duration.map(|d| d as u64),
            uploader: info.uploader,
            formats,
            webpage_url: info.webpage_url.unwrap_or_else(|| url.to_string()),
        })
    }

    /// 下载视频
    pub async fn download_video(
        &self,
        url: &str,
        format_id: Option<&str>,
        event_tx: mpsc::Sender<DownloadEvent>,
        task_id: TaskId,
    ) -> Result<PathBuf> {
        info!("开始下载视频: {} (format: {:?})", url, format_id);

        let output_template = self
            .output_dir
            .join("%(id)s.%(ext)s")
            .to_string_lossy()
            .to_string();

        let mut args = vec![
            "--newline".to_string(),
            "--no-warnings".to_string(),
            "--no-playlist".to_string(),
            "-o".to_string(),
            output_template,
        ];

        // 显式指定 ffmpeg 路径
        if let Some(ffmpeg_path) = Self::find_ffmpeg() {
             args.push("--ffmpeg-location".to_string());
             args.push(ffmpeg_path.to_string_lossy().to_string());
        }

        args.push("--merge-output-format".to_string());
        args.push("mp4".to_string());

        if let Some(fmt) = format_id {
            // 用户指定了格式（通常是 video-only）
            // 自动附加 +bestaudio 以合并音频，如果合并失败则回退到该格式本身
            args.push("-f".to_string());
            args.push(format!("{}+bestaudio/best", fmt));
        } else {
            // 不指定 -f，让 yt-dlp 自动选择
            // 优先选择 H.264 编码 (兼容性最好)，其次是分辨率
            args.push("-S".to_string());
            args.push("vcodec:h264,res,acodec:m4a".to_string());
        }
        
        info!("YT-DLP Arguments (v6-audio-merge): {:?}", args);

        args.push(url.to_string());

        info!("执行: {:?} {:?}", self.yt_dlp_path, args);

        let mut child = Command::new(&self.yt_dlp_path)
            .args(&args)
            .stdout(Stdio::piped())
            .stderr(Stdio::piped())
            .spawn()
            .map_err(|e| NebulaError::Internal(format!("启动 yt-dlp 失败: {}", e)))?;

        // 发送开始事件
        let _ = event_tx
            .send(DownloadEvent::TaskStarted { task_id })
            .await;

        // 读取标准输出（进度信息）
        let stdout = child.stdout.take();
        let stderr = child.stderr.take();
        
        let task_id_clone = task_id;
        let event_tx_clone = event_tx.clone();

        // 异步读取 stdout
        let stdout_handle = if let Some(stdout) = stdout {
            Some(tokio::spawn(async move {
                let reader = BufReader::new(stdout);
                let mut lines = reader.lines();
                
                while let Ok(Some(line)) = lines.next_line().await {
                    debug!("yt-dlp stdout: {}", line);
                    // 解析进度
                    if line.contains("[download]") && line.contains("%") {
                        if let Some(progress) = Self::parse_progress(&line) {
                            let _ = event_tx_clone
                                .send(DownloadEvent::ProgressUpdated {
                                    task_id: task_id_clone,
                                    progress,
                                })
                                .await;
                        }
                    }
                }
            }))
        } else {
            None
        };

        // 异步读取 stderr
        let stderr_output = if let Some(stderr) = stderr {
            let reader = BufReader::new(stderr);
            let mut lines = reader.lines();
            let mut output = String::new();
            
            while let Ok(Some(line)) = lines.next_line().await {
                debug!("yt-dlp stderr: {}", line);
                output.push_str(&line);
                output.push('\n');
            }
            output
        } else {
            String::new()
        };

        // 等待 stdout 读取完成
        if let Some(handle) = stdout_handle {
            let _ = handle.await;
        }

        // 等待子进程完成
        let status = child
            .wait()
            .await
            .map_err(|e| NebulaError::Internal(format!("等待 yt-dlp 失败: {}", e)))?;

        if status.success() {
            info!("视频下载完成");
            let _ = event_tx
                .send(DownloadEvent::TaskCompleted {
                    task_id,
                    completed_at: chrono::Utc::now(),
                })
                .await;
            Ok(self.output_dir.clone())
        } else {
            let error_msg = if stderr_output.is_empty() {
                "视频下载失败".to_string()
            } else {
                format!("视频下载失败: {}", stderr_output.lines().next().unwrap_or(""))
            };
            error!("{}", error_msg);
            let _ = event_tx
                .send(DownloadEvent::TaskFailed {
                    task_id,
                    error: error_msg.clone(),
                })
                .await;
            Err(NebulaError::Internal(error_msg))
        }
    }

    /// 解析 yt-dlp 进度输出
    fn parse_progress(line: &str) -> Option<Progress> {
        // [download]  45.2% of 100.00MiB at 5.00MiB/s ETA 00:10
        let parts: Vec<&str> = line.split_whitespace().collect();

        let mut percentage = 0.0;
        let mut total_size = 0u64;
        let mut download_speed = 0u64;
        let mut eta_secs = None;

        for (i, part) in parts.iter().enumerate() {
            if part.ends_with('%') {
                if let Ok(p) = part.trim_end_matches('%').parse::<f64>() {
                    percentage = p;
                }
            } else if part.contains("MiB") || part.contains("GiB") || part.contains("KiB") {
                if i > 0 && parts.get(i - 1) == Some(&"of") {
                    total_size = Self::parse_size(part);
                } else if i > 0 && parts.get(i - 1) == Some(&"at") {
                    download_speed = Self::parse_size(part);
                }
            } else if i > 0 && parts.get(i - 1) == Some(&"ETA") {
                eta_secs = Self::parse_eta(part);
            }
        }

        let downloaded_size = (total_size as f64 * percentage / 100.0) as u64;

        Some(Progress {
            total_size,
            downloaded_size,
            download_speed,
            upload_speed: 0,
            eta_secs,
            percentage,
        })
    }

    fn parse_size(s: &str) -> u64 {
        let s = s.trim();
        if s.ends_with("GiB") || s.ends_with("GiB/s") {
            let num = s.trim_end_matches("GiB").trim_end_matches("/s");
            num.parse::<f64>().unwrap_or(0.0) as u64 * 1024 * 1024 * 1024
        } else if s.ends_with("MiB") || s.ends_with("MiB/s") {
            let num = s.trim_end_matches("MiB").trim_end_matches("/s");
            num.parse::<f64>().unwrap_or(0.0) as u64 * 1024 * 1024
        } else if s.ends_with("KiB") || s.ends_with("KiB/s") {
            let num = s.trim_end_matches("KiB").trim_end_matches("/s");
            num.parse::<f64>().unwrap_or(0.0) as u64 * 1024
        } else {
            0
        }
    }

    fn parse_eta(s: &str) -> Option<u64> {
        // 格式: MM:SS 或 HH:MM:SS
        let parts: Vec<&str> = s.split(':').collect();
        match parts.len() {
            2 => {
                let mins: u64 = parts[0].parse().ok()?;
                let secs: u64 = parts[1].parse().ok()?;
                Some(mins * 60 + secs)
            }
            3 => {
                let hours: u64 = parts[0].parse().ok()?;
                let mins: u64 = parts[1].parse().ok()?;
                let secs: u64 = parts[2].parse().ok()?;
                Some(hours * 3600 + mins * 60 + secs)
            }
            _ => None,
        }
    }
}
