import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../widgets/task_card.dart';
import '../widgets/video_info_dialog.dart';
import '../src/rust/api/download.dart' as api;
import '../settings.dart';

/// 下载列表页
import 'package:provider/provider.dart';
import '../providers/download_provider.dart';

/// 下载列表页
class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key});

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  final TextEditingController _urlController = TextEditingController();
  final FocusNode _urlFocusNode = FocusNode();

  @override
  void dispose() {
    _urlController.dispose();
    _urlFocusNode.dispose();
    super.dispose();
  }

  Future<void> _addDownload() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    try {
      // 检查是否是视频 URL
      final isVideo = await api.isVideoUrl(url: url);
      
      if (isVideo && mounted) {
        // 显示视频信息对话框
        // 显示视频信息对话框
        final result = await showDialog<({String formatId, String title, String? thumbnail})>(
          context: context,
          barrierDismissible: false,
          builder: (context) => VideoInfoDialog(url: url),
        );
        
        if (result != null && mounted) {
          final savePath = await AppSettings.getDownloadPath();
          await api.addVideoDownload(
            url: url,
            savePath: savePath,
            formatId: result.formatId,
            title: result.title,
            thumbnail: result.thumbnail,
          );
        }
      } else {
        // 普通下载
        final savePath = await AppSettings.getDownloadPath();
        await api.addDownload(source: url, savePath: savePath);
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
    
    return Consumer<DownloadProvider>(
      builder: (context, provider, child) {
        final activeTasks = provider.activeTasks;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部标题和输入区域
              _buildHeader(theme, activeTasks),
              
              // 任务列表
              Expanded(
                child: activeTasks.isEmpty
                    ? _buildEmptyState(theme)
                    : _buildTaskList(activeTasks),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme, List<DownloadTaskInfo> tasks) {
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
                  '${tasks.where((t) => t.status == TaskStatus.downloading).length}',
                  style: const TextStyle(
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
            onPause: () => api.pauseDownload(taskId: task.id),
            onResume: () => api.resumeDownload(taskId: task.id),
            onCancel: () => api.cancelDownload(taskId: task.id, deleteFiles: true),
          ),
        );
      },
    );
  }
}
