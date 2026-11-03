import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/shell_repository.dart';

class ShellController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() {
    return ref.watch(shellRepositoryProvider).load();
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(shellRepositoryProvider).load());
  }
}

final shellControllerProvider = AsyncNotifierProvider<ShellController, bool>(ShellController.new);
