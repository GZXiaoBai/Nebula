import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/settings.dart';
import '../src/rust/api/download.dart';
import '../theme.dart';
import '../widgets/drop_zone.dart';
import '../widgets/task_card.dart';
import '../widgets/video_info_dialog.dart';
import 'settings_page.dart';

/// 首页
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<DownloadTask> _tasks = [];
  bool _isInitialized = false;
  String? _initError;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _initDownloadManager();
  }

  Future<void> _initDownloadManager() async {
    try {
      final settings = context.read<AppSettings>();
      await initDownloadManager(downloadDir: settings.downloadDir);

      final stream = await subscribeEvents();
      stream.listen(_handleEvent);

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _initError = e.toString();
      });
    }
  }

  void _handleEvent(NebulaEvent event) {
    event.when(
      taskAdded: (taskId, name) {
        setState(() {
          _tasks.add(DownloadTask(
            id: taskId,
            name: name,
            status: TaskStatus.pending,
            progress: 0,
            downloadSpeed: 0,
            totalSize: 0,
            downloadedSize: 0,
          ));
        });
      },
      taskStarted: (taskId) {
        _updateTask(taskId, (task) => DownloadTask(
              id: task.id,
              name: task.name,
              status: TaskStatus.downloading,
              progress: task.progress,
              downloadSpeed: task.downloadSpeed,
              totalSize: task.totalSize,
              downloadedSize: task.downloadedSize,
            ));
      },
      progressUpdated: (taskId, progress) {
        _updateTask(taskId, (task) => DownloadTask(
              id: task.id,
              name: task.name,
              status: TaskStatus.downloading,
              progress: progress.percentage / 100,
              downloadSpeed: progress.downloadSpeed.toInt(),
              totalSize: progress.totalSize.toInt(),
              downloadedSize: progress.downloadedSize.toInt(),
              etaSeconds: progress.etaSecs?.toInt(),
            ));
      },
      taskCompleted: (taskId) {
        _updateTask(taskId, (task) => DownloadTask(
              id: task.id,
              name: task.name,
              status: TaskStatus.completed,
              progress: 1.0,
              downloadSpeed: 0,
              totalSize: task.totalSize,
              downloadedSize: task.totalSize,
            ));
      },
      taskFailed: (taskId, error) {
        _updateTask(taskId, (task) => DownloadTask(
              id: task.id,
              name: task.name,
              status: TaskStatus.failed,
              progress: task.progress,
              downloadSpeed: 0,
              totalSize: task.totalSize,
              downloadedSize: task.downloadedSize,
            ));
        _showError(error);
      },
      taskPaused: (taskId) {
        _updateTask(taskId, (task) => DownloadTask(
              id: task.id,
              name: task.name,
              status: TaskStatus.paused,
              progress: task.progress,
              downloadSpeed: 0,
              totalSize: task.totalSize,
              downloadedSize: task.downloadedSize,
            ));
      },
      taskResumed: (taskId) {
        _updateTask(taskId, (task) => DownloadTask(
              id: task.id,
              name: task.name,
              status: TaskStatus.downloading,
              progress: task.progress,
              downloadSpeed: task.downloadSpeed,
              totalSize: task.totalSize,
              downloadedSize: task.downloadedSize,
            ));
      },
      taskRemoved: (taskId) {
        setState(() {
          _tasks.removeWhere((t) => t.id == taskId);
        });
      },
      metadataReceived: (taskId, name, totalSize, fileCount) {
        _updateTask(taskId, (task) => DownloadTask(
              id: task.id,
              name: name,
              status: task.status,
              progress: task.progress,
              downloadSpeed: task.downloadSpeed,
              totalSize: totalSize.toInt(),
              downloadedSize: task.downloadedSize,
            ));
      },
    );
  }

  void _updateTask(String taskId, DownloadTask Function(DownloadTask) updater) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index >= 0) {
        _tasks[index] = updater(_tasks[index]);
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: NebulaTheme.error,
      ),
    );
  }

  Future<void> _addDownload(String url) async {
    try {
      final settings = context.read<AppSettings>();
      
      // 检查链接是否为空
      if (url.trim().isEmpty) return;

      // 检查是不是视频链接
      final isVideo = await isVideoUrl(url: url);

      if (isVideo) {
        // 显示视频信息弹窗
        // 注意：这里需要 BuildContext，但在 async 之后使用 context 最好检查 mounted
        if (!mounted) return;
        
        final formatId = await showDialog<String>(
          context: context,
          builder: (context) => VideoInfoDialog(url: url),
        );
        
        // 如果用户关闭弹窗（返回null），则不进行下载
        if (formatId == null) return;
        
        await addVideoDownload(
          url: url,
          savePath: settings.downloadDir,
          formatId: formatId,
        );
      } else {
        // 普通下载（HTTP/Magnet/Torrent）
        await addDownload(
          source: url,
          savePath: settings.downloadDir,
        );
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    }
  }

  void _handleFileDrop(DropDoneDetails details) {
    for (final file in details.files) {
      final path = file.path;
      if (path.endsWith('.torrent')) {
        _addDownload(path);
      }
    }
  }

  Future<void> _pauseTask(String taskId) async {
    try {
      await pauseDownload(taskId: taskId);
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _resumeTask(String taskId) async {
    try {
      await resumeDownload(taskId: taskId);
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _cancelTask(String taskId) async {
    try {
      await cancelDownload(taskId: taskId, deleteFiles: false);
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsPage(
          settings: context.read<AppSettings>(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initError != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: NebulaTheme.error,
              ),
              const SizedBox(height: NebulaTheme.spacingMd),
              Text(
                '初始化失败',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: NebulaTheme.spacingSm),
              Text(
                _initError!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return DropTarget(
      onDragEntered: (_) => setState(() => _isDragging = true),
      onDragExited: (_) => setState(() => _isDragging = false),
      onDragDone: _handleFileDrop,
      child: Scaffold(
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            border: _isDragging
                ? Border.all(color: NebulaTheme.primaryStart, width: 3)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(NebulaTheme.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题栏
                Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          NebulaTheme.primaryGradient.createShader(bounds),
                      child: const Text(
                        '🌌 Nebula',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.settings_rounded),
                      tooltip: '设置',
                      onPressed: _openSettings,
                    ),
                  ],
                ),
                const SizedBox(height: NebulaTheme.spacingLg),

                // 拖拽区域
                DropZone(onUrlSubmitted: _addDownload),
                const SizedBox(height: NebulaTheme.spacingLg),

                // 下载列表标题
                if (_tasks.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.download_rounded,
                        color: NebulaTheme.textSecondary,
                      ),
                      const SizedBox(width: NebulaTheme.spacingSm),
                      Text(
                        '下载任务 (${_tasks.length})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: NebulaTheme.spacingSm),
                ],

                // 下载任务列表
                Expanded(
                  child: _tasks.isEmpty
                      ? Center(
                          child: Text(
                            '暂无下载任务\n拖拽 .torrent 文件到窗口开始下载',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        )
                      : ListView.separated(
                          itemCount: _tasks.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: NebulaTheme.spacingSm),
                          itemBuilder: (context, index) {
                            final task = _tasks[index];
                            return TaskCard(
                              task: task,
                              onPause: () => _pauseTask(task.id),
                              onResume: () => _resumeTask(task.id),
                              onCancel: () => _cancelTask(task.id),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
