import 'package:flutter/material.dart';

import '../constants/strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class LoadingSkeleton extends StatefulWidget {
  const LoadingSkeleton({
    this.height = 88,
    this.width = double.infinity,
    super.key,
  });

  final double height;
  final double width;

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppStrings.loading,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final color =
              Color.lerp(
                AppColors.border,
                AppColors.background,
                _controller.value,
              ) ??
              AppColors.border;
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          );
        },
      ),
    );
  }
}
