import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../widgets/task_card.dart';
import '../widgets/video_info_dialog.dart';
import '../src/rust/api/download.dart';
import '../settings.dart';

/// 下载列表页
class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key});

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  final TextEditingController _urlController = TextEditingController();
  final FocusNode _urlFocusNode = FocusNode();
  final Map<String, DownloadTaskInfo> _tasks = {};

  @override
  void initState() {
    super.initState();
    _subscribeToEvents();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _urlFocusNode.dispose();
    super.dispose();
  }

  void _subscribeToEvents() async {
    final stream = await subscribeEvents();
    stream.listen((event) {
      if (!mounted) return;
      
      switch (event) {
        case NebulaEvent_TaskAdded(:final taskId, :final name):
          setState(() {
            _tasks[taskId] = DownloadTaskInfo(
              id: taskId,
              name: name,
              status: TaskStatus.pending,
            );
          });
        case NebulaEvent_TaskStarted(:final taskId):
          setState(() {
            _tasks[taskId]?.status = TaskStatus.downloading;
          });
        case NebulaEvent_ProgressUpdated(:final taskId, :final progress):
          setState(() {
            _tasks[taskId]?.progress = progress;
          });
        case NebulaEvent_TaskCompleted(:final taskId):
          setState(() {
            _tasks[taskId]?.status = TaskStatus.completed;
          });
        case NebulaEvent_TaskFailed(:final taskId, :final error):
          setState(() {
            _tasks[taskId]?.status = TaskStatus.failed;
            _tasks[taskId]?.error = error;
          });
        case NebulaEvent_MetadataReceived(:final taskId, :final name, :final totalSize, :final fileCount):
          setState(() {
            _tasks[taskId]?.name = name;
            _tasks[taskId]?.totalSize = totalSize.toInt();
            _tasks[taskId]?.fileCount = fileCount.toInt();
          });
        default:
          break;
      }
    });
  }

  Future<void> _addDownload() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    try {
      // 检查是否是视频 URL
      final isVideo = await isVideoUrl(url: url);
      
      if (isVideo && mounted) {
        // 显示视频信息对话框
        final formatId = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (context) => VideoInfoDialog(url: url),
        );
        
        if (formatId != null && mounted) {
          final savePath = await AppSettings.getDownloadPath();
          await addVideoDownload(
            url: url,
            savePath: savePath,
            formatId: formatId,
          );
        }
      } else {
        // 普通下载
        final savePath = await AppSettings.getDownloadPath();
        await addDownload(source: url, savePath: savePath);
      }

      _urlController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加下载失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeTasks = _tasks.values
        .where((t) => t.status != TaskStatus.completed)
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部标题和输入区域
          _buildHeader(theme),
          
          // 任务列表
          Expanded(
            child: activeTasks.isEmpty
                ? _buildEmptyState(theme)
                : _buildTaskList(activeTasks),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(NebulaTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Text(
                '下载中',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.nebulaTextPrimary,
                ),
              ),
              const SizedBox(width: NebulaTheme.spacingMd),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: NebulaTheme.spacingSm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: NebulaTheme.primaryStart.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(NebulaTheme.radiusSm),
                ),
                child: Text(
                  '${_tasks.values.where((t) => t.status == TaskStatus.downloading).length}',
                  style: TextStyle(
                    color: NebulaTheme.primaryStart,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: NebulaTheme.spacingMd),
          
          // URL 输入框
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _urlController,
                  focusNode: _urlFocusNode,
                  decoration: InputDecoration(
                    hintText: '粘贴下载链接 (HTTP/磁力链接/视频地址)',
                    hintStyle: TextStyle(color: theme.nebulaTextMuted),
                    prefixIcon: Icon(
                      Icons.link_rounded,
                      color: theme.nebulaTextMuted,
                    ),
                    suffixIcon: _urlController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _urlController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _addDownload(),
                ),
              ),
              const SizedBox(width: NebulaTheme.spacingMd),
              FilledButton.icon(
                onPressed: _addDownload,
                icon: const Icon(Icons.add_rounded),
                label: const Text('添加'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: NebulaTheme.spacingLg,
                    vertical: NebulaTheme.spacingMd,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.nebulaCard,
              borderRadius: BorderRadius.circular(NebulaTheme.radiusLg),
            ),
            child: Icon(
              Icons.cloud_download_outlined,
              size: 40,
              color: theme.nebulaTextMuted,
            ),
          ),
          const SizedBox(height: NebulaTheme.spacingLg),
          Text(
            '暂无下载任务',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.nebulaTextSecondary,
            ),
          ),
          const SizedBox(height: NebulaTheme.spacingSm),
          Text(
            '粘贴链接或拖拽文件到此处开始下载',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.nebulaTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<DownloadTaskInfo> tasks) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: NebulaTheme.spacingLg),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: NebulaTheme.spacingMd),
          child: TaskCard(
            task: task,
            onPause: () => pauseDownload(taskId: task.id),
            onResume: () => resumeDownload(taskId: task.id),
            onCancel: () => cancelDownload(taskId: task.id, deleteFiles: true),
          ),
        );
      },
    );
  }
}

/// 任务状态
enum TaskStatus {
  pending,
  downloading,
  paused,
  completed,
  failed,
}

/// 下载任务信息
class DownloadTaskInfo {
  String id;
  String name;
  TaskStatus status;
  ProgressEvent? progress;
  String? error;
  int? totalSize;
  int? fileCount;

  DownloadTaskInfo({
    required this.id,
    required this.name,
    required this.status,
    this.progress,
    this.error,
    this.totalSize,
    this.fileCount,
  });
}
