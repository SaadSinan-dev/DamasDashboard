/// Exceptions thrown by data sources.
///
/// These never escape the data layer: repository implementations catch them and
/// convert them into failures, so the domain and presentation layers only ever
/// deal with values, not control flow.
library;

sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// A remote data source was unreachable or returned an error status.
final class NetworkException extends AppException {
  const NetworkException(super.message);
}

/// Local storage read/write failed.
final class CacheException extends AppException {
  const CacheException(super.message);
}

/// The requested record does not exist in the data source.
final class NotFoundException extends AppException {
  const NotFoundException(super.message, {this.resourceId});

  final String? resourceId;
}
