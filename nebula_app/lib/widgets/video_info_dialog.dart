import 'package:flutter/material.dart';
import 'package:nebula_app/src/rust/api/download.dart';
import '../theme.dart';

class VideoInfoDialog extends StatefulWidget {
  final String url;

  const VideoInfoDialog({
    super.key,
    required this.url,
  });

  @override
  State<VideoInfoDialog> createState() => _VideoInfoDialogState();
}

class _VideoInfoDialogState extends State<VideoInfoDialog> {
  late Future<VideoInfo> _infoFuture;
  String? _selectedFormatId;

  @override
  void initState() {
    super.initState();
    _infoFuture = getVideoInfo(url: widget.url);
  }

  String _formatDuration(BigInt? seconds) {
    if (seconds == null) return '--:--';
    final d = Duration(seconds: seconds.toInt());
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String _formatFileSize(BigInt? bytes) {
    if (bytes == null) return '未知大小';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = bytes.toInt().toDouble();
    while (size > 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: NebulaTheme.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: NebulaTheme.border),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: FutureBuilder<VideoInfo>(
          future: _infoFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   const Icon(Icons.error_outline, color: NebulaTheme.error, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    '获取视频信息失败',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('关闭'),
                  ),
                ],
              );
            }

            if (!snapshot.hasData) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    '正在解析视频信息...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              );
            }

            final info = snapshot.data!;
            
            if (_selectedFormatId == null && info.formats.isNotEmpty) {
               _selectedFormatId = info.formats.lastOrNull?.formatId;
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '下载视频',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                
                // 封面
                if (info.thumbnail != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      info.thumbnail!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 180,
                        color: Colors.black26,
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // 标题
                Text(
                  info.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // 信息行
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: NebulaTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(info.duration),
                      style: const TextStyle(color: NebulaTheme.textSecondary),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.person, size: 16, color: NebulaTheme.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        info.uploader ?? '未知作者',
                        style: const TextStyle(color: NebulaTheme.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 画质选择列表
                Text(
                  '选择画质',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                
                Container(
                  height: 240, 
                  decoration: BoxDecoration(
                    color: NebulaTheme.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: NebulaTheme.border),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: info.formats.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      // 倒序显示，通常高质量在前或后，视 yt-dlp 而定。
                      // 原代码用了 reversed，这里也保持倒序
                      final format = info.formats[info.formats.length - 1 - index];
                      final isSelected = _selectedFormatId == format.formatId;
                      
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedFormatId = format.formatId;
                          });
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? NebulaTheme.primaryStart.withOpacity(0.15) : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: isSelected 
                                ? Border.all(color: NebulaTheme.primaryStart.withOpacity(0.5))
                                : Border.all(color: Colors.transparent),
                          ),
                          child: Row(
                            children: [
                              // 分辨率/格式
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: NebulaTheme.card,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  format.ext.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: NebulaTheme.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                format.resolution ?? '未知分辨率',
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  color: isSelected ? NebulaTheme.primaryStart : NebulaTheme.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              // 大小
                              if (format.filesize != null)
                                Text(
                                  _formatFileSize(format.filesize),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? NebulaTheme.primaryStart : NebulaTheme.textMuted,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),
                
                // 按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: NebulaTheme.textSecondary,
                      ),
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _selectedFormatId == null ? null : () {
                        Navigator.pop(context, _selectedFormatId);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: NebulaTheme.primaryStart,
                        disabledBackgroundColor: NebulaTheme.primaryStart.withOpacity(0.3),
                      ),
                      child: const Text('开始下载'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
