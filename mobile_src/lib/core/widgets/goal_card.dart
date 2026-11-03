import 'package:flutter/material.dart';

import '../constants/strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/money.dart';
import 'count_up_amount.dart';
import 'progress_bar.dart';
import 'progress_ring.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({
    required this.name,
    required this.savedMinor,
    required this.targetMinor,
    required this.progress,
    this.onTap,
    super.key,
  });

  final String name;
  final int savedMinor;
  final int targetMinor;
  final double progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 0,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppColors.softShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                ProgressRing(progress: progress, size: 72),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.xs),
                      CountUpAmount(
                        amountMinor: savedMinor,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${AppStrings.ofTarget} ${formatKes(targetMinor)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ProgressBar(progress: progress),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
