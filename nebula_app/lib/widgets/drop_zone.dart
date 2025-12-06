import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

/// 拖拽区域组件
class DropZone extends StatefulWidget {
  const DropZone({
    super.key,
    required this.onUrlSubmitted,
  });

  /// 提交 URL 时的回调
  final void Function(String url) onUrlSubmitted;

  @override
  State<DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<DropZone> {
  bool _isDragging = false;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitUrl() {
    final url = _controller.text.trim();
    if (url.isNotEmpty) {
      widget.onUrlSubmitted(url);
      _controller.clear();
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      _controller.text = data.text!;
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(NebulaTheme.spacingLg),
      decoration: BoxDecoration(
        color: _isDragging ? NebulaTheme.card : NebulaTheme.surface,
        borderRadius: BorderRadius.circular(NebulaTheme.radiusLg),
        border: Border.all(
          color: _isDragging ? NebulaTheme.primaryStart : NebulaTheme.border,
          width: _isDragging ? 2 : 1,
        ),
        boxShadow: _isDragging ? NebulaTheme.glowShadow : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 图标
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(NebulaTheme.spacingMd),
            decoration: BoxDecoration(
              gradient: _isDragging ? NebulaTheme.primaryGradient : null,
              color: _isDragging ? null : NebulaTheme.card,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_download_rounded,
              size: 48,
              color: _isDragging
                  ? NebulaTheme.textPrimary
                  : NebulaTheme.textSecondary,
            ),
          ),
          const SizedBox(height: NebulaTheme.spacingMd),

          // 标题
          Text(
            '拖拽文件到此处',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: NebulaTheme.spacingSm),

          // 副标题
          Text(
            '或粘贴链接开始下载',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: NebulaTheme.spacingLg),

          // 输入框
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: '输入 HTTP/磁力链接...',
                    hintStyle: TextStyle(
                      color: NebulaTheme.textMuted,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.paste_rounded),
                      tooltip: '粘贴',
                      onPressed: _pasteFromClipboard,
                    ),
                  ),
                  onSubmitted: (_) => _submitUrl(),
                ),
              ),
              const SizedBox(width: NebulaTheme.spacingSm),
              Container(
                decoration: BoxDecoration(
                  gradient: NebulaTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(NebulaTheme.radiusMd),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add_rounded),
                  color: NebulaTheme.textPrimary,
                  tooltip: '添加下载',
                  onPressed: _submitUrl,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
