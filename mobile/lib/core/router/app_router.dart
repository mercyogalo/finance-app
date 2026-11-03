import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/shell/presentation/not_found_screen.dart';
import '../../features/shell/presentation/shell_screen.dart';
import 'app_transition_page.dart';
import 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) =>
            AppTransitionPage(key: state.pageKey, child: const ShellScreen()),
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
});
