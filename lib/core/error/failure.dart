import 'package:equatable/equatable.dart';

/// A domain-level description of something that went wrong.
///
/// Failures deliberately carry **no user-facing text**. The domain layer has no
/// business knowing which language the user reads, so each variant is a type
/// that the presentation layer pattern-matches into a localized message. That
/// keeps `lib/features/*/domain` free of `AppL10n` and keeps translations in
/// one place.
sealed class Failure extends Equatable {
  const Failure({this.cause, this.stackTrace});

  /// The original exception, kept for logging only — never shown to the user.
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => <Object?>[runtimeType, cause];
}

/// The device is offline, or a remote call timed out or returned an error.
final class NetworkFailure extends Failure {
  const NetworkFailure({super.cause, super.stackTrace});
}

/// Local storage could not be read or written.
final class CacheFailure extends Failure {
  const CacheFailure({super.cause, super.stackTrace});
}

/// A requested record does not exist.
final class NotFoundFailure extends Failure {
  const NotFoundFailure({this.resourceId, super.cause, super.stackTrace});

  final String? resourceId;

  @override
  List<Object?> get props => <Object?>[...super.props, resourceId];
}

/// Input did not satisfy a business rule. [field] identifies which input, so
/// the form can attach the message to the right control.
final class ValidationFailure extends Failure {
  const ValidationFailure({required this.field, super.cause, super.stackTrace});

  final String field;

  @override
  List<Object?> get props => <Object?>[...super.props, field];
}

/// Anything not covered above. Always logged with its stack trace.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure({super.cause, super.stackTrace});
}
