import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Debug-only request/response logging. Callers should only add this
/// interceptor when `kDebugMode` is true (see dio_client.dart) so nothing
/// leaks request/response bodies in release builds.
final PrettyDioLogger loggingInterceptor = PrettyDioLogger();
