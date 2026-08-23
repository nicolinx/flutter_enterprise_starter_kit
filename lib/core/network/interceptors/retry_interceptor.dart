import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_enterprise_starter_kit/core/error/exceptions.dart';

const _retryCountKey = 'retryCount';

/// Retries idempotent GET requests on transient failures (timeouts,
/// connection errors, 5xx) with exponential backoff. Must run after
/// `ErrorInterceptor` so `err.error` is already a typed exception.
class RetryInterceptor extends Interceptor {
  RetryInterceptor(
    this._dio, {
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 500),
  });

  final Dio _dio;
  final int maxRetries;
  final Duration baseDelay;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    unawaited(handleError(err, handler));
  }

  /// Public so tests can await it instead of pumping the event queue.
  @visibleForTesting
  Future<void> handleError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_isRetryable(err)) {
      handler.next(err);
      return;
    }

    final requestOptions = err.requestOptions;
    final attempt = (requestOptions.extra[_retryCountKey] as int? ?? 0) + 1;
    if (attempt > maxRetries) {
      handler.next(err);
      return;
    }
    requestOptions.extra[_retryCountKey] = attempt;

    await Future<void>.delayed(baseDelay * (1 << (attempt - 1)));

    try {
      final response = await _dio.fetch<dynamic>(requestOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _isRetryable(DioException err) {
    if (err.requestOptions.method.toUpperCase() != 'GET') {
      return false;
    }

    final error = err.error;
    if (error is NetworkException) {
      return true;
    }
    if (error is ServerException) {
      final statusCode = err.response?.statusCode;
      return statusCode != null && statusCode >= 500 && statusCode < 600;
    }
    return false;
  }
}
