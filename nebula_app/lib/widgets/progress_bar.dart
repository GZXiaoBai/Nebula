import 'package:flutter/material.dart';

import '../theme.dart';

/// 渐变进度条组件
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.showGlow = true,
  });

  /// 进度值 (0.0 - 1.0)
  final double progress;

  /// 进度条高度
  final double height;

  /// 是否显示发光效果
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: NebulaTheme.surface,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: Stack(
          children: [
            // 进度填充
            AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              widthFactor: progress.clamp(0.0, 1.0),
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  gradient: NebulaTheme.progressGradient,
                  borderRadius: BorderRadius.circular(height / 2),
                  boxShadow: showGlow ? NebulaTheme.glowShadow : null,
                ),
              ),
            ),
            // 光泽效果
            if (progress > 0 && progress < 1)
              Positioned.fill(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: 0.3,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0),
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 带动画的 FractionallySizedBox
class AnimatedFractionallySizedBox extends ImplicitlyAnimatedWidget {
  const AnimatedFractionallySizedBox({
    super.key,
    required super.duration,
    super.curve,
    this.widthFactor,
    this.heightFactor,
    this.alignment = Alignment.center,
    this.child,
  });

  final double? widthFactor;
  final double? heightFactor;
  final AlignmentGeometry alignment;
  final Widget? child;

  @override
  ImplicitlyAnimatedWidgetState<AnimatedFractionallySizedBox> createState() =>
      _AnimatedFractionallySizedBoxState();
}

class _AnimatedFractionallySizedBoxState
    extends AnimatedWidgetBaseState<AnimatedFractionallySizedBox> {
  Tween<double>? _widthFactor;
  Tween<double>? _heightFactor;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _widthFactor = visitor(
      _widthFactor,
      widget.widthFactor ?? 0,
      (value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
    _heightFactor = visitor(
      _heightFactor,
      widget.heightFactor ?? 0,
      (value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: _widthFactor?.evaluate(animation),
      heightFactor: _heightFactor?.evaluate(animation),
      alignment: widget.alignment,
      child: widget.child,
    );
  }
}
