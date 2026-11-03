import 'package:flutter/material.dart';

import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: EmptyState(
          title: AppStrings.notFoundTitle,
          message: AppStrings.notFoundMessage,
          icon: Icons.search_off_outlined,
        ),
      ),
    );
  }
}
