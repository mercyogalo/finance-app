import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/money.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({required this.progress, this.size = 72, this.child, super.key});

  final double progress;
  final double size;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final target = progress.clamp(0, 1).toDouble();
    return Semantics(
      label: formatPercent(target),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: target),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (context, value, inner) {
          return SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _RingPainter(progress: value),
              child: Center(child: inner),
            ),
          );
        },
        child: child ??
            Text(
              formatPercent(target),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 8.0;
    final rect = Offset.zero & size;
    final deflated = rect.deflate(stroke / 2);
    final track = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final value = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(deflated, 0, math.pi * 2, false, track);
    canvas.drawArc(deflated, -math.pi / 2, math.pi * 2 * progress, false, value);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.progress != progress;
}
