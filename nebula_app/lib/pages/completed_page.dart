import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/download_provider.dart';

/// 已完成下载页
class CompletedPage extends StatefulWidget {
  const CompletedPage({super.key});

  @override
  State<CompletedPage> createState() => _CompletedPageState();
}

class _CompletedPageState extends State<CompletedPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<DownloadProvider>(
      builder: (context, provider, child) {
        final completedTasks = provider.completedTasks;
        // 按完成时间倒序排列
        completedTasks.sort((a, b) {
          if (a.completedAt == null) return 1;
          if (b.completedAt == null) return -1;
          return b.completedAt!.compareTo(a.completedAt!);
        });

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部标题
              _buildHeader(theme, completedTasks.length),

              // 任务列表
              Expanded(
                child: completedTasks.isEmpty
                    ? _buildEmptyState(theme)
                    : _buildTaskList(completedTasks),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme, int count) {
    return Container(
      padding: const EdgeInsets.all(NebulaTheme.spacingLg),
      child: Row(
        children: [
          Text(
            '已完成',
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
              color: NebulaTheme.success.withOpacity(0.2),
              borderRadius: BorderRadius.circular(NebulaTheme.radiusSm),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: NebulaTheme.success,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const Spacer(),
          if (count > 0)
            TextButton.icon(
              onPressed: _clearAll,
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text('清空'),
              style: TextButton.styleFrom(
                foregroundColor: theme.nebulaTextMuted,
              ),
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
              Icons.check_circle_outline_rounded,
              size: 40,
              color: theme.nebulaTextMuted,
            ),
          ),
          const SizedBox(height: NebulaTheme.spacingLg),
          Text(
            '暂无已完成任务',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.nebulaTextSecondary,
            ),
          ),
          const SizedBox(height: NebulaTheme.spacingSm),
          Text(
            '完成的下载会显示在这里',
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
        return _CompletedTaskCard(
          task: task,
          onOpen: () => _openFile(task),
          onOpenFolder: () => _openFolder(task),
          onDelete: () => _deleteTask(task),
        );
      },
    );
  }

  void _clearAll() {
    // TODO: 实现清空逻辑（可能需要在 Provider 中添加方法）
    // 目前仅展示 Dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清空'),
        content: const Text('确定要清空所有已完成记录吗？文件不会被删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: context.read<DownloadProvider>().clearCompleted();
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _openFile(DownloadTaskInfo task) {
    // TODO: 实现打开文件
  }

  void _openFolder(DownloadTaskInfo task) {
    // TODO: 实现打开文件夹
  }

  void _deleteTask(DownloadTaskInfo task) {
    // TODO: context.read<DownloadProvider>().removeTask(task.id);
  }
}

/// 已完成任务卡片
class _CompletedTaskCard extends StatelessWidget {
  final DownloadTaskInfo task;
  final VoidCallback onOpen;
  final VoidCallback onOpenFolder;
  final VoidCallback onDelete;

  const _CompletedTaskCard({
    required this.task,
    required this.onOpen,
    required this.onOpenFolder,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: NebulaTheme.spacingMd),
      padding: const EdgeInsets.all(NebulaTheme.spacingMd),
      decoration: BoxDecoration(
        color: theme.nebulaCard,
        borderRadius: BorderRadius.circular(NebulaTheme.radiusMd),
        border: Border.all(
          color: theme.nebulaBorder.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 文件图标
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: NebulaTheme.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(NebulaTheme.radiusSm),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: NebulaTheme.success,
              size: 24,
            ),
          ),
          const SizedBox(width: NebulaTheme.spacingMd),

          // 文件信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.nebulaTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatSize(task.totalSize ?? 0)} • ${_formatDate(task.completedAt ?? DateTime.now())}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.nebulaTextMuted,
                  ),
                ),
              ],
            ),
          ),

          // 操作按钮
          IconButton(
            onPressed: onOpen,
            icon: const Icon(Icons.play_arrow_rounded),
            tooltip: '打开',
          ),
          IconButton(
            onPressed: onOpenFolder,
            icon: const Icon(Icons.folder_open_rounded),
            tooltip: '打开所在文件夹',
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: '删除记录',
          ),
        ],
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return '今天 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return '昨天';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} 天前';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}
