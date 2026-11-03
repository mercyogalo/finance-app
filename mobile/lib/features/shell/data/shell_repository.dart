import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/network/api_client.dart';
import '../domain/shell_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final shellRepositoryProvider = Provider<ShellRepository>((ref) {
  if (AppConfig.useMockRepositories) {
    return const MockShellRepository();
  }
  return ApiShellRepository(ref.watch(apiClientProvider));
});

class ApiShellRepository implements ShellRepository {
  const ApiShellRepository(this._client);

  final ApiClient _client;

  @override
  Future<bool> load() async {
    try {
      final response = await _client.dio.get<dynamic>('/health');
      final data = response.data;
      if (data is Map && data['status'] == 'ok') {
        return true;
      }
      throw exceptionFromStatus(response.statusCode, data);
    } on DioException catch (error) {
      throw exceptionFromDio(error);
    }
  }
}

class MockShellRepository implements ShellRepository {
  const MockShellRepository({this.ready = true, this.error});

  final bool ready;
  final Object? error;

  @override
  Future<bool> load() async {
    final failure = error;
    if (failure != null) {
      throw failure;
    }
    return ready;
  }
}
