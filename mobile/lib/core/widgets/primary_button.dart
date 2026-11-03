import 'package:flutter/material.dart';

import '../constants/strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'pressable_scale.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final background = enabled ? AppColors.primary : AppColors.border;
    final foreground = enabled ? AppColors.surface : AppColors.textSecondary;

    return PressableScale(
      onPressed: enabled ? onPressed : null,
      child: Semantics(
        button: true,
        label: isLoading ? AppStrings.loading : label,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: AppColors.textSecondary,
                  ),
                )
              : Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
