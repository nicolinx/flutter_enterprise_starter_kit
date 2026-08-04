import 'package:dio/dio.dart';
import 'package:flutter_enterprise_starter_kit/core/error/exceptions.dart';

/// Normalizes every [DioException] into one of the app's typed
/// [Exception]s, so data sources only ever need to catch
/// [ServerException]/[NetworkException] instead of inspecting Dio-specific
/// error types.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.connectionError:
        handler.next(err.copyWith(error: const NetworkException()));
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        handler.next(
          err.copyWith(
            error: ServerException('Server error (status $statusCode)'),
          ),
        );
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        handler.next(err.copyWith(error: const ServerException()));
    }
  }
}
