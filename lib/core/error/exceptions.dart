/// Thrown by data sources when a remote/server call fails.
class ServerException implements Exception {
  const ServerException([this.message = 'A server error occurred']);

  final String message;
}

/// Thrown by data sources when a local cache read/write fails.
class CacheException implements Exception {
  const CacheException([this.message = 'A cache error occurred']);

  final String message;
}

/// Thrown when there is no network connectivity for a call that requires it.
class NetworkException implements Exception {
  const NetworkException([this.message = 'No network connection']);

  final String message;
}
