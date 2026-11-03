import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_skeleton.dart';
import 'shell_controller.dart';

class ShellScreen extends ConsumerWidget {
  const ShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shellControllerProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: state.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                LoadingSkeleton(height: 28, width: 160),
                SizedBox(height: AppSpacing.md),
                LoadingSkeleton(height: 88),
              ],
            ),
          ),
          error: (error, _) => EmptyState(
            title: AppStrings.somethingWentWrong,
            message: _message(error),
            icon: Icons.cloud_off_outlined,
            actionLabel: AppStrings.retry,
            onAction: () => ref.read(shellControllerProvider.notifier).retry(),
          ),
          data: (ready) {
            if (!ready) {
              return const EmptyState(
                title: AppStrings.shellEmptyTitle,
                message: AppStrings.shellEmptyMessage,
                icon: Icons.savings_outlined,
              );
            }
            return const _ReadyBody();
          },
        ),
      ),
    );
  }

  String _message(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return AppStrings.genericError;
  }
}

class _ReadyBody extends StatelessWidget {
  const _ReadyBody();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.appName, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.appTagline,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
