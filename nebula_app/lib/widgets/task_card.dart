import 'package:flutter/material.dart';
import '../theme.dart';
import '../providers/download_provider.dart';
import 'progress_bar.dart';

/// 下载任务卡片组件 - 重构版本
class TaskCard extends StatefulWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.onPause,
    this.onResume,
    this.onCancel,
    this.onTap,
  });

  final DownloadTaskInfo task;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onCancel;
  final VoidCallback? onTap;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: NebulaTheme.animFast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

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
        return NebulaTheme.darkTextMuted;
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
    final theme = Theme.of(context);
    final progress = widget.task.progress;
    final progressValue = progress != null && progress.totalSize > BigInt.zero
        ? progress.downloadedSize.toDouble() / progress.totalSize.toDouble()
        : 0.0;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animController.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: NebulaTheme.animFast,
            padding: const EdgeInsets.all(NebulaTheme.spacingMd),
            decoration: BoxDecoration(
              color: _isHovered ? theme.nebulaCardHover : theme.nebulaCard,
              borderRadius: BorderRadius.circular(NebulaTheme.radiusMd),
              border: Border.all(
                color: _isHovered
                    ? NebulaTheme.primaryStart.withOpacity(0.3)
                    : theme.nebulaBorder.withOpacity(0.5),
              ),
              boxShadow: _isHovered ? theme.nebulaCardShadow : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题行
                Row(
                  children: [
                    // 状态图标
                    // 状态图标或缩略图
                    if (widget.task.thumbnail != null)
                      Container(
                        width: 60,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(NebulaTheme.radiusSm),
                          color: NebulaTheme.background,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(NebulaTheme.radiusSm),
                          child: Image.network(
                            widget.task.thumbnail!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: _getStatusColor().withOpacity(0.15),
                              child: Icon(
                                _getStatusIcon(),
                                color: _getStatusColor(),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
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
                    const SizedBox(width: NebulaTheme.spacingMd),
                    // 文件名
                    Expanded(
                      child: Text(
                        widget.task.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.nebulaTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // 操作按钮
                    AnimatedOpacity(
                      opacity: _isHovered ? 1.0 : 0.0,
                      duration: NebulaTheme.animFast,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.task.status == TaskStatus.downloading)
                            _buildIconButton(
                              Icons.pause_rounded,
                              '暂停',
                              widget.onPause,
                            ),
                          if (widget.task.status == TaskStatus.paused)
                            _buildIconButton(
                              Icons.play_arrow_rounded,
                              '继续',
                              widget.onResume,
                            ),
                          _buildIconButton(
                            Icons.close_rounded,
                            '取消',
                            widget.onCancel,
                            color: NebulaTheme.error,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: NebulaTheme.spacingMd),

                // 进度条
                ProgressBar(
                  progress: progressValue,
                  height: 6,
                  showGlow: widget.task.status == TaskStatus.downloading,
                ),
                const SizedBox(height: NebulaTheme.spacingSm),

                // 信息行
                Row(
                  children: [
                    // 进度百分比
                    Text(
                      '${(progressValue * 100).toStringAsFixed(1)}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.nebulaTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: NebulaTheme.spacingMd),
                    // 已下载 / 总大小
                    if (progress != null)
                      Text(
                        '${_formatBytes(progress.downloadedSize.toInt())} / ${_formatBytes(progress.totalSize.toInt())}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.nebulaTextMuted,
                        ),
                      ),
                    if (widget.task.connectedPeers != null) ...[
                      const SizedBox(width: NebulaTheme.spacingMd),
                      Icon(Icons.people_alt_outlined, size: 14, color: theme.nebulaTextMuted),
                      const SizedBox(width: 4),
                       Text(
                        '${widget.task.connectedPeers}/${widget.task.totalPeers ?? 0}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.nebulaTextMuted,
                        ),
                      ),
                    ],
                    const Spacer(),
                    // 速度和 ETA
                    if (widget.task.status == TaskStatus.downloading && progress != null) ...[
                      Icon(
                        Icons.speed_rounded,
                        size: 14,
                        color: theme.nebulaTextMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatSpeed(progress.downloadSpeed.toInt()),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: NebulaTheme.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: NebulaTheme.spacingMd),
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: theme.nebulaTextMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatEta(progress.etaSecs?.toInt()),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.nebulaTextMuted,
                        ),
                      ),
                    ],
                    // 错误信息
                    if (widget.task.status == TaskStatus.failed && widget.task.error != null)
                      Flexible(
                        child: Text(
                          widget.task.error!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: NebulaTheme.error,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String tooltip, VoidCallback? onPressed, {Color? color}) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(NebulaTheme.radiusSm),
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              icon,
              size: 18,
              color: color ?? theme.nebulaTextSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
