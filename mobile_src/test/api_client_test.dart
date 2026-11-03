import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hifadhi/core/constants/app_config.dart';
import 'package:hifadhi/core/constants/strings.dart';
import 'package:hifadhi/core/network/api_client.dart';
import 'package:hifadhi/core/network/api_exception.dart';
import 'package:hifadhi/features/shell/data/shell_repository.dart';

void main() {
  test('api client uses the configured base url', () {
    final client = ApiClient(baseUrl: 'http://example.test');
    expect(client.dio.options.baseUrl, 'http://example.test');
    expect(AppConfig.apiBaseUrl, 'http://localhost:3000');
  });

  test('api errors keep the backend code and message', () {
    final exception = exceptionFromBody(404, {
      'error': {'code': 'NOT_FOUND', 'message': 'Route not found: GET /missing'},
    });
    expect(exception?.code, 'NOT_FOUND');
    expect(exception?.message, 'Route not found: GET /missing');
    expect(exception?.statusCode, 404);
  });

  test('mock shell repository can succeed, return empty, or fail', () async {
    expect(await const MockShellRepository().load(), isTrue);
    expect(await const MockShellRepository(ready: false).load(), isFalse);
    expect(
      () => const MockShellRepository(error: ApiException(code: 'X', message: 'nope')).load(),
      throwsA(isA<ApiException>()),
    );
  });

  test('api shell repository reads a healthy payload', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = _JsonAdapter(statusCode: 200, body: '{"status":"ok"}');
    final repository = ApiShellRepository(ApiClient(dio: dio));

    expect(await repository.load(), isTrue);
  });

  test('api shell repository surfaces the shared error shape', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = _JsonAdapter(
      statusCode: 503,
      body: '{"error":{"code":"NOT_READY","message":"Database is unavailable"}}',
    );
    final repository = ApiShellRepository(ApiClient(dio: dio));

    expect(
      () => repository.load(),
      throwsA(
        isA<ApiException>()
            .having((error) => error.code, 'code', 'NOT_READY')
            .having((error) => error.message, 'message', 'Database is unavailable'),
      ),
    );
  });

  test('a transport failure uses the network message', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.httpClientAdapter = _ThrowingAdapter();
    final repository = ApiShellRepository(ApiClient(dio: dio));

    expect(
      () => repository.load(),
      throwsA(isA<ApiException>().having((error) => error.message, 'message', AppStrings.networkError)),
    );
  });
}

class _JsonAdapter implements HttpClientAdapter {
  _JsonAdapter({required this.statusCode, required this.body});

  final int statusCode;
  final String body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _ThrowingAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw DioException(requestOptions: options, type: DioExceptionType.connectionError);
  }

  @override
  void close({bool force = false}) {}
}
