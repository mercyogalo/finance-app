import 'package:dio/dio.dart';

import '../constants/app_config.dart';
import '../constants/strings.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({Dio? dio, String? baseUrl}) : dio = dio ?? Dio() {
    final resolved = baseUrl ?? (this.dio.options.baseUrl.isEmpty ? AppConfig.apiBaseUrl : this.dio.options.baseUrl);
    this.dio.options = this.dio.options.copyWith(
      baseUrl: resolved,
      connectTimeout: this.dio.options.connectTimeout ?? const Duration(seconds: 15),
      receiveTimeout: this.dio.options.receiveTimeout ?? const Duration(seconds: 20),
      headers: {
        ...this.dio.options.headers,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          final exception = exceptionFromDio(error);
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: exception,
              message: exception.message,
            ),
          );
        },
      ),
    );
  }

  final Dio dio;
}

ApiException exceptionFromDio(DioException error) {
  final existing = error.error;
  if (existing is ApiException) {
    return existing;
  }
  final parsed = exceptionFromBody(error.response?.statusCode, error.response?.data);
  if (parsed != null) {
    return parsed;
  }
  return ApiException(
    code: 'NETWORK',
    message: AppStrings.networkError,
    statusCode: error.response?.statusCode,
  );
}

ApiException exceptionFromStatus(int? statusCode, dynamic data) {
  return exceptionFromBody(statusCode, data) ??
      ApiException(
        code: 'HTTP_$statusCode',
        message: AppStrings.genericError,
        statusCode: statusCode,
      );
}

ApiException? exceptionFromBody(int? statusCode, dynamic data) {
  if (data is! Map) {
    return null;
  }
  final body = data['error'];
  if (body is! Map) {
    return null;
  }
  final code = body['code']?.toString() ?? '';
  final message = body['message']?.toString() ?? '';
  if (code.isEmpty || message.isEmpty) {
    return null;
  }
  return ApiException(code: code, message: message, statusCode: statusCode);
}
