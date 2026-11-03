import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum StatusTone { neutral, onTrack, behind, locked, error }

class StatusChip extends StatelessWidget {
  const StatusChip({required this.label, required this.tone, super.key});

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = switch (tone) {
      StatusTone.neutral => (
        AppColors.background,
        AppColors.textSecondary,
        AppColors.border,
      ),
      StatusTone.onTrack => (
        AppColors.primaryTint,
        AppColors.primaryDark,
        AppColors.primaryTint,
      ),
      StatusTone.behind => (
        AppColors.accentTint,
        AppColors.textPrimary,
        AppColors.accentTint,
      ),
      StatusTone.locked => (
        AppColors.background,
        AppColors.textSecondary,
        AppColors.border,
      ),
      StatusTone.error => (AppColors.surface, AppColors.error, AppColors.error),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.$3),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(color: colors.$2, fontWeight: FontWeight.w600),
      ),
    );
  }
}
