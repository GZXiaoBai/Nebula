import 'package:flutter/material.dart';

import '../theme.dart';
import 'progress_bar.dart';

/// 下载任务状态
enum TaskStatus {
  pending,
  downloading,
  paused,
  completed,
  failed,
}

/// 下载任务数据模型
class DownloadTask {
  final String id;
  final String name;
  final TaskStatus status;
  final double progress;
  final int downloadSpeed; // bytes per second
  final int totalSize;
  final int downloadedSize;
  final int? etaSeconds;

  const DownloadTask({
    required this.id,
    required this.name,
    required this.status,
    required this.progress,
    required this.downloadSpeed,
    required this.totalSize,
    required this.downloadedSize,
    this.etaSeconds,
  });
}

/// 下载任务卡片组件
class TaskCard extends StatefulWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.onPause,
    this.onResume,
    this.onCancel,
  });

  final DownloadTask task;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onCancel;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isHovered = false;

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String _formatSpeed(int bytesPerSecond) {
    return '${_formatBytes(bytesPerSecond)}/s';
  }

  String _formatEta(int? seconds) {
    if (seconds == null || seconds <= 0) return '--';
    if (seconds < 60) return '$seconds 秒';
    if (seconds < 3600) return '${seconds ~/ 60} 分 ${seconds % 60} 秒';
    final hours = seconds ~/ 3600;
    final mins = (seconds % 3600) ~/ 60;
    return '$hours 时 $mins 分';
  }

  IconData _getStatusIcon() {
    switch (widget.task.status) {
      case TaskStatus.pending:
        return Icons.hourglass_empty_rounded;
      case TaskStatus.downloading:
        return Icons.arrow_downward_rounded;
      case TaskStatus.paused:
        return Icons.pause_rounded;
      case TaskStatus.completed:
        return Icons.check_circle_rounded;
      case TaskStatus.failed:
        return Icons.error_rounded;
    }
  }

  Color _getStatusColor() {
    switch (widget.task.status) {
      case TaskStatus.pending:
        return NebulaTheme.textMuted;
      case TaskStatus.downloading:
        return NebulaTheme.primaryStart;
      case TaskStatus.paused:
        return NebulaTheme.warning;
      case TaskStatus.completed:
        return NebulaTheme.success;
      case TaskStatus.failed:
        return NebulaTheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(NebulaTheme.spacingMd),
        decoration: BoxDecoration(
          color: _isHovered ? NebulaTheme.cardHover : NebulaTheme.card,
          borderRadius: BorderRadius.circular(NebulaTheme.radiusMd),
          border: Border.all(
            color: _isHovered ? NebulaTheme.borderLight : NebulaTheme.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题行
            Row(
              children: [
                // 状态图标
                Container(
                  padding: const EdgeInsets.all(NebulaTheme.spacingSm),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.15),
                    borderRadius: BorderRadius.circular(NebulaTheme.radiusSm),
                  ),
                  child: Icon(
                    _getStatusIcon(),
                    color: _getStatusColor(),
                    size: 20,
                  ),
                ),
                const SizedBox(width: NebulaTheme.spacingSm),
                // 文件名
                Expanded(
                  child: Text(
                    widget.task.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // 操作按钮
                if (_isHovered) ...[
                  if (widget.task.status == TaskStatus.downloading)
                    IconButton(
                      icon: const Icon(Icons.pause_rounded),
                      iconSize: 20,
                      tooltip: '暂停',
                      onPressed: widget.onPause,
                    ),
                  if (widget.task.status == TaskStatus.paused)
                    IconButton(
                      icon: const Icon(Icons.play_arrow_rounded),
                      iconSize: 20,
                      tooltip: '继续',
                      onPressed: widget.onResume,
                    ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    iconSize: 20,
                    tooltip: '取消',
                    onPressed: widget.onCancel,
                  ),
                ],
              ],
            ),
            const SizedBox(height: NebulaTheme.spacingSm),

            // 进度条
            ProgressBar(
              progress: widget.task.progress,
              height: 6,
              showGlow: widget.task.status == TaskStatus.downloading,
            ),
            const SizedBox(height: NebulaTheme.spacingSm),

            // 信息行
            Row(
              children: [
                // 进度百分比
                Text(
                  '${(widget.task.progress * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: NebulaTheme.textSecondary,
                      ),
                ),
                const SizedBox(width: NebulaTheme.spacingMd),
                // 已下载 / 总大小
                Text(
                  '${_formatBytes(widget.task.downloadedSize)} / ${_formatBytes(widget.task.totalSize)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                // 速度
                if (widget.task.status == TaskStatus.downloading) ...[
                  Icon(
                    Icons.speed_rounded,
                    size: 14,
                    color: NebulaTheme.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatSpeed(widget.task.downloadSpeed),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: NebulaTheme.success,
                        ),
                  ),
                  const SizedBox(width: NebulaTheme.spacingMd),
                  // ETA
                  Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: NebulaTheme.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatEta(widget.task.etaSeconds),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
