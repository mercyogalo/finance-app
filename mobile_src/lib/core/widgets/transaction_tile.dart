import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/money.dart';

enum TransactionDirection { credit, debit, penalty }

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    required this.title,
    required this.subtitle,
    required this.amountMinor,
    required this.direction,
    this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final int amountMinor;
  final TransactionDirection direction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final amountColor = switch (direction) {
      TransactionDirection.credit => AppColors.primary,
      TransactionDirection.debit => AppColors.textPrimary,
      TransactionDirection.penalty => AppColors.error,
    };
    final icon = switch (direction) {
      TransactionDirection.credit => Icons.arrow_downward_rounded,
      TransactionDirection.debit => Icons.arrow_upward_rounded,
      TransactionDirection.penalty => Icons.flag_outlined,
    };
    final iconColor = direction == TransactionDirection.penalty ? AppColors.error : AppColors.primaryDark;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 4),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: AppColors.primaryTint, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Text(
                formatKes(amountMinor),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: amountColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
