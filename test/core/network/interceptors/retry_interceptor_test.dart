import 'package:dio/dio.dart';
import 'package:flutter_enterprise_starter_kit/core/error/exceptions.dart';
import 'package:flutter_enterprise_starter_kit/core/network/interceptors/retry_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

class _MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

void main() {
  setUpAll(() {
    final fallbackRequestOptions = RequestOptions(path: '/fallback');
    registerFallbackValue(fallbackRequestOptions);
    registerFallbackValue(
      DioException(requestOptions: fallbackRequestOptions),
    );
  });

  late _MockDio dio;
  late _MockErrorInterceptorHandler handler;
  late RetryInterceptor interceptor;

  setUp(() {
    dio = _MockDio();
    handler = _MockErrorInterceptorHandler();
    interceptor = RetryInterceptor(dio, baseDelay: Duration.zero);
  });

  DioException networkError(RequestOptions requestOptions) {
    return DioException(
      requestOptions: requestOptions,
      error: const NetworkException(),
      type: DioExceptionType.connectionError,
    );
  }

  DioException serverError(RequestOptions requestOptions, int statusCode) {
    return DioException(
      requestOptions: requestOptions,
      error: const ServerException(),
      response: Response<dynamic>(
        requestOptions: requestOptions,
        statusCode: statusCode,
      ),
      type: DioExceptionType.badResponse,
    );
  }

  test('resolves with the response once a retry succeeds', () async {
    final requestOptions = RequestOptions(path: '/posts');
    final err = networkError(requestOptions);
    final response = Response<dynamic>(
      requestOptions: requestOptions,
      statusCode: 200,
    );
    when(
      () => dio.fetch<dynamic>(requestOptions),
    ).thenAnswer((_) async => response);

    await interceptor.handleError(err, handler);

    verify(() => dio.fetch<dynamic>(requestOptions)).called(1);
    verify(() => handler.resolve(response)).called(1);
    verifyNever(() => handler.next(any()));
  });

  test('retries a transient 5xx and tracks the attempt count', () async {
    final requestOptions = RequestOptions(path: '/posts');
    final err = serverError(requestOptions, 503);
    when(() => dio.fetch<dynamic>(requestOptions)).thenThrow(err);

    await interceptor.handleError(err, handler);

    verify(() => dio.fetch<dynamic>(requestOptions)).called(1);
    expect(requestOptions.extra['retryCount'], 1);
    verify(() => handler.next(err)).called(1);
  });

  test('gives up once maxRetries has already been reached', () async {
    final requestOptions = RequestOptions(path: '/posts')
      ..extra['retryCount'] = 3;
    final err = serverError(requestOptions, 503);

    await interceptor.handleError(err, handler);

    verifyNever(() => dio.fetch<dynamic>(any()));
    verify(() => handler.next(err)).called(1);
  });

  test('does not retry a 4xx response', () async {
    final requestOptions = RequestOptions(path: '/posts');
    final err = serverError(requestOptions, 404);

    await interceptor.handleError(err, handler);

    verifyNever(() => dio.fetch<dynamic>(any()));
    verify(() => handler.next(err)).called(1);
  });

  test('does not retry non-GET requests', () async {
    final requestOptions = RequestOptions(path: '/posts', method: 'POST');
    final err = networkError(requestOptions);

    await interceptor.handleError(err, handler);

    verifyNever(() => dio.fetch<dynamic>(any()));
    verify(() => handler.next(err)).called(1);
  });
}
