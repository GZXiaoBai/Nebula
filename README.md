# Nebula (星云) 🌌

> 下一代智能跨平台下载器 - 极简于外，极强于内

## 项目简介

Nebula 是一款面向所有用户的通用下载工具，旨在消除技术门槛，让小白用户通过直观的引导完成下载，同时为极客用户提供深度定制的协议与网络控制。

### 核心特性

- 🎯 **零配置上手** - 智能识别链接，自动优化下载参数
- ⚡ **多协议支持** - HTTP/HTTPS, FTP, BitTorrent (磁力链接 & .torrent)
- 🔄 **断点续传** - 网络波动无忧，自动恢复下载
- 📺 **边下边播** - 视频文件优先下载头尾，支持播放器直接打开
- 🖥️ **跨平台** - macOS, Windows, Android 一套代码

### 两种模式

| 禅模式 (Zen)       | 舰长模式 (Captain)   |
| ------------------ | -------------------- |
| 极简界面，一键下载 | 仪表盘风格，完整控制 |
| 自动识别剪贴板链接 | Tracker 编辑与订阅   |
| 智能向导引导设置   | 代理 / IP 过滤设置   |
| 适合普通用户       | 适合高级用户         |

## 技术架构

```
┌─────────────────────────────────────────┐
│           Flutter UI Layer              │
│    (禅模式 / 舰长模式 / 设置页面)          │
├─────────────────────────────────────────┤
│        flutter_rust_bridge              │
├─────────────────────────────────────────┤
│           Nebula Core (Rust)            │
│  ┌─────────────┬─────────────────────┐  │
│  │ HTTP Engine │  BitTorrent Engine  │  │
│  │  (reqwest)  │    (librqbit)       │  │
│  └─────────────┴─────────────────────┘  │
└─────────────────────────────────────────┘
```

## 快速开始

### 环境要求

- Rust 1.75+
- Flutter 3.16+ (Phase 2+)

### 构建运行

```bash
# 克隆项目
git clone https://github.com/user/nebula.git
cd nebula

# 构建核心库
cargo build --release

# 运行 CLI 工具测试磁力链接下载
cargo run -p nebula-cli -- download "magnet:?xt=urn:btih:..." -o ~/Downloads
```

## 项目结构

```
Downloader/
├── Cargo.toml          # Workspace 配置
├── nebula-core/        # 核心下载引擎 (Rust)
├── nebula-cli/         # 命令行测试工具
└── nebula-app/         # Flutter 应用 (Phase 2)
```

## 开发路线图

- [x] Phase 1: 核心引擎搭建
- [ ] Phase 2: Flutter 框架与桥接
- [ ] Phase 3: UI 实现与交互
- [ ] Phase 4: 高级功能与新手引导
- [ ] Phase 5: 打包与优化

## 许可证

MIT License
