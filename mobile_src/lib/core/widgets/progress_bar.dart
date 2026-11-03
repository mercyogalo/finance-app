import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({required this.progress, super.key});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final target = progress.clamp(0, 1).toDouble();
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: target),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: SizedBox(
            height: 8,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: AppColors.border),
                if (value > 0)
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: value,
                    child: const ColoredBox(color: AppColors.primary),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
