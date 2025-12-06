//! Nebula CLI - 命令行下载工具
//!
//! 提供命令行接口测试核心下载功能。
//!
//! # 使用示例
//!
//! ```bash
//! # 下载 HTTP 文件
//! nebula download "https://example.com/file.zip" -o ~/Downloads
//!
//! # 下载磁力链接
//! nebula download "magnet:?xt=urn:btih:..." -o ~/Downloads
//!
//! # 显示帮助信息
//! nebula --help
//! ```

use anyhow::{Context, Result};
use clap::{Parser, Subcommand};
use console::style;
use indicatif::{ProgressBar, ProgressStyle};
use nebula_core::{DownloadEvent, DownloadManager, ManagerConfig, Progress};
use std::path::PathBuf;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
use tracing::Level;
use tracing_subscriber::FmtSubscriber;

/// Nebula - 下一代智能下载器
#[derive(Parser, Debug)]
#[command(name = "nebula")]
#[command(author = "Zhou")]
#[command(version = env!("CARGO_PKG_VERSION"))]
#[command(about = "星云下载器 - 极简于外，极强于内", long_about = None)]
struct Cli {
    /// 日志级别 (trace, debug, info, warn, error)
    #[arg(short, long, default_value = "info")]
    log_level: String,

    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand, Debug)]
enum Commands {
    /// 下载文件
    Download {
        /// 下载来源 (URL、磁力链接或 .torrent 文件路径)
        source: String,

        /// 保存目录
        #[arg(short, long)]
        output: Option<PathBuf>,

        /// 显示详细进度信息
        #[arg(short, long)]
        verbose: bool,
    },

    /// 显示版本信息
    Version,
}

#[tokio::main]
async fn main() -> Result<()> {
    let cli = Cli::parse();

    // 初始化日志
    let log_level = match cli.log_level.to_lowercase().as_str() {
        "trace" => Level::TRACE,
        "debug" => Level::DEBUG,
        "info" => Level::INFO,
        "warn" => Level::WARN,
        "error" => Level::ERROR,
        _ => Level::INFO,
    };

    let _subscriber = FmtSubscriber::builder()
        .with_max_level(log_level)
        .with_target(false)
        .compact()
        .init();

    match cli.command {
        Commands::Download {
            source,
            output,
            verbose,
        } => {
            download_command(&source, output, verbose).await?;
        }
        Commands::Version => {
            println!(
                "{} {} - {}",
                style("Nebula").cyan().bold(),
                env!("CARGO_PKG_VERSION"),
                "下一代智能跨平台下载器"
            );
        }
    }

    Ok(())
}

/// 执行下载命令
async fn download_command(source: &str, output: Option<PathBuf>, verbose: bool) -> Result<()> {
    println!(
        "\n{} Nebula 下载器 v{}\n",
        style("🌌").cyan(),
        env!("CARGO_PKG_VERSION")
    );

    // 创建下载管理器
    let mut config = ManagerConfig::default();
    if let Some(output_dir) = &output {
        config.download_dir = output_dir.clone();
    }

    println!(
        "{} 初始化下载引擎...",
        style("[1/3]").bold().dim()
    );

    let manager = DownloadManager::new(config)
        .await
        .context("初始化下载管理器失败")?;

    // 设置 Ctrl+C 处理
    let running = Arc::new(AtomicBool::new(true));
    let r = running.clone();
    ctrlc::set_handler(move || {
        println!("\n{} 正在停止下载...", style("⚠").yellow());
        r.store(false, Ordering::SeqCst);
    })
    .expect("设置 Ctrl+C 处理失败");

    // 订阅事件
    let mut events = manager.subscribe();

    println!(
        "{} 添加下载任务...",
        style("[2/3]").bold().dim()
    );

    // 添加下载任务
    let save_path = output.unwrap_or_else(|| manager.config().download_dir.clone());
    let task_id = manager
        .add_task(source, save_path.clone())
        .await
        .context("添加下载任务失败")?;

    println!(
        "{} 任务已添加: {}\n",
        style("✓").green(),
        task_id.short()
    );

    println!(
        "{} 开始下载...\n",
        style("[3/3]").bold().dim()
    );

    // 创建进度条
    let pb = ProgressBar::new(100);
    pb.set_style(
        ProgressStyle::default_bar()
            .template("{spinner:.green} [{elapsed_precise}] [{bar:40.cyan/blue}] {percent}% ({bytes}/{total_bytes}) @ {bytes_per_sec} ETA: {eta}")
            .unwrap()
            .progress_chars("█▉▊▋▌▍▎▏  "),
    );

    // 监听事件并更新进度条
    let mut completed = false;
    while running.load(Ordering::SeqCst) && !completed {
        tokio::select! {
            event = events.recv() => {
                match event {
                    Ok(DownloadEvent::ProgressUpdated { task_id: tid, progress }) if tid == task_id => {
                        update_progress_bar(&pb, &progress);
                    }
                    Ok(DownloadEvent::MetadataReceived { task_id: tid, name, total_size, file_count }) if tid == task_id => {
                        println!("{} 元数据已获取:", style("ℹ").blue());
                        println!("  名称: {}", style(&name).white().bold());
                        println!("  大小: {}", format_bytes(total_size));
                        println!("  文件数: {}\n", file_count);
                        pb.set_length(total_size);
                    }
                    Ok(DownloadEvent::TaskCompleted { task_id: tid, .. }) if tid == task_id => {
                        pb.finish_with_message("下载完成!");
                        completed = true;
                        println!("\n{} 下载完成!", style("✓").green().bold());
                        println!("  保存位置: {:?}", save_path);
                    }
                    Ok(DownloadEvent::TaskFailed { task_id: tid, error }) if tid == task_id => {
                        pb.finish_with_message("下载失败");
                        completed = true;
                        println!("\n{} 下载失败: {}", style("✗").red().bold(), error);
                    }
                    Ok(DownloadEvent::PeerUpdate { task_id: tid, connected_peers, total_peers }) if tid == task_id && verbose => {
                        pb.set_message(format!("Peers: {}/{}", connected_peers, total_peers));
                    }
                    _ => {}
                }
            }
            _ = tokio::time::sleep(std::time::Duration::from_millis(100)) => {
                // 保持循环活跃
            }
        }
    }

    // 如果用户中断，取消任务
    if !completed {
        println!("\n{} 正在取消任务...", style("⚠").yellow());
        manager.cancel(task_id, false).await?;
        println!("{} 任务已取消（文件已保留，下次可断点续传）", style("✓").green());
    }

    Ok(())
}

/// 更新进度条
fn update_progress_bar(pb: &ProgressBar, progress: &Progress) {
    if progress.total_size > 0 {
        pb.set_length(progress.total_size);
        pb.set_position(progress.downloaded_size);
    }
}

/// 格式化字节数
fn format_bytes(bytes: u64) -> String {
    const KB: u64 = 1024;
    const MB: u64 = KB * 1024;
    const GB: u64 = MB * 1024;

    if bytes >= GB {
        format!("{:.2} GB", bytes as f64 / GB as f64)
    } else if bytes >= MB {
        format!("{:.2} MB", bytes as f64 / MB as f64)
    } else if bytes >= KB {
        format!("{:.2} KB", bytes as f64 / KB as f64)
    } else {
        format!("{} B", bytes)
    }
}
