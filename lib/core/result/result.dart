import '../error/failure.dart';

/// The outcome of an operation that can fail.
///
/// Repositories return `Result<T>` instead of throwing, which makes failure part
/// of the type signature: a caller cannot forget to handle it, because the value
/// is unreachable until the result is destructured.
///
/// ```dart
/// switch (await repository.getReports()) {
///   case Success(:final value): emit(ReportsState.loaded(value));
///   case Failed(:final failure): emit(ReportsState.error(failure));
/// }
/// ```
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;

  /// The value, or `null` when this result is a failure.
  T? get valueOrNull => switch (this) {
        Success<T>(:final T value) => value,
        Failed<T>() => null,
      };

  /// The failure, or `null` when this result is a success.
  Failure? get failureOrNull => switch (this) {
        Success<T>() => null,
        Failed<T>(:final Failure failure) => failure,
      };

  /// Collapses both branches into a single value.
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) =>
      switch (this) {
        Success<T>(:final T value) => onSuccess(value),
        Failed<T>(:final Failure failure) => onFailure(failure),
      };

  /// Transforms a successful value, passing failures through untouched.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
        Success<T>(:final T value) => Success<R>(transform(value)),
        Failed<T>(:final Failure failure) => Failed<R>(failure),
      };
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString() => 'Success<$T>($value)';
}

final class Failed<T> extends Result<T> {
  const Failed(this.failure);

  final Failure failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failed<T> &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  @override
  String toString() => 'Failed<$T>($failure)';
}
