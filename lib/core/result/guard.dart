import '../error/exceptions.dart';
import '../error/failure.dart';
import '../utils/app_logger.dart';
import 'result.dart';

/// Runs [body] and converts any thrown [AppException] into the matching
/// [Failure].
///
/// Every repository method funnels through this, which is why no `try`/`catch`
/// appears anywhere else in the app. Unrecognised errors become
/// [UnexpectedFailure] and are logged with their stack trace rather than
/// swallowed.
Future<Result<T>> guardAsync<T>(
  Future<T> Function() body, {
  required String operation,
}) async {
  try {
    return Success<T>(await body());
  } on NetworkException catch (error, stackTrace) {
    AppLogger.warning('$operation failed: network', error: error);
    return Failed<T>(NetworkFailure(cause: error, stackTrace: stackTrace));
  } on CacheException catch (error, stackTrace) {
    AppLogger.warning('$operation failed: cache', error: error);
    return Failed<T>(CacheFailure(cause: error, stackTrace: stackTrace));
  } on NotFoundException catch (error, stackTrace) {
    AppLogger.info('$operation: ${error.resourceId ?? 'resource'} not found');
    return Failed<T>(
      NotFoundFailure(
        resourceId: error.resourceId,
        cause: error,
        stackTrace: stackTrace,
      ),
    );
  } catch (error, stackTrace) {
    AppLogger.error(
      '$operation failed unexpectedly',
      error: error,
      stackTrace: stackTrace,
    );
    return Failed<T>(UnexpectedFailure(cause: error, stackTrace: stackTrace));
  }
}
