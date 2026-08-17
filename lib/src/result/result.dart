part 'failure_result.dart';
part 'success.dart';

/// Outcome of an operation that either contains a value or an error.
///
/// `Result` is intentionally independent from the package's `Failure` type.
/// Use any error type suitable for the domain.
sealed class Result<T, E> {
  const Result();

  /// Captures a synchronous exception and converts it to an error value.
  static Result<T, E> guard<T, E>(
    T Function() operation, {
    required E Function(Object error, StackTrace stackTrace) onError,
  }) {
    try {
      return Success<T, E>(operation());
    } catch (error, stackTrace) {
      return FailureResult<T, E>(onError(error, stackTrace));
    }
  }

  /// Captures an asynchronous exception and converts it to an error value.
  static Future<Result<T, E>> guardAsync<T, E>(
    Future<T> Function() operation, {
    required E Function(Object error, StackTrace stackTrace) onError,
  }) async {
    try {
      return Success<T, E>(await operation());
    } catch (error, stackTrace) {
      return FailureResult<T, E>(onError(error, stackTrace));
    }
  }

  /// Converts values and errors from a stream into typed results.
  ///
  /// Errors thrown while creating the stream and errors emitted after a
  /// listener subscribes are both captured.
  static Stream<Result<T, E>> guardStream<T, E>(
    Stream<T> Function() operation, {
    required E Function(Object error, StackTrace stackTrace) onError,
  }) async* {
    try {
      await for (final value in operation()) {
        yield Success<T, E>(value);
      }
    } catch (error, stackTrace) {
      yield FailureResult<T, E>(onError(error, stackTrace));
    }
  }

  /// Whether this result contains a value.
  bool get isSuccess => this is Success<T, E>;

  /// Whether this result contains an error.
  bool get isFailure => this is FailureResult<T, E>;

  /// Transforms either branch into one value.
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(E error) onFailure,
  }) =>
      switch (this) {
        Success<T, E>(:final value) => onSuccess(value),
        FailureResult<T, E>(:final error) => onFailure(error),
      };

  /// Transforms a success value while preserving an error.
  Result<U, E> map<U>(U Function(T value) transform) => switch (this) {
        Success<T, E>(:final value) => Success<U, E>(transform(value)),
        FailureResult<T, E>(:final error) => FailureResult<U, E>(error),
      };

  /// Asynchronously transforms a success value while preserving an error.
  Future<Result<U, E>> mapAsync<U>(
    Future<U> Function(T value) transform,
  ) async =>
      switch (this) {
        Success<T, E>(:final value) => Success<U, E>(await transform(value)),
        FailureResult<T, E>(:final error) => FailureResult<U, E>(error),
      };

  /// Transforms an error while preserving a success value.
  Result<T, F> mapError<F>(F Function(E error) transform) => switch (this) {
        Success<T, E>(:final value) => Success<T, F>(value),
        FailureResult<T, E>(:final error) =>
          FailureResult<T, F>(transform(error)),
      };

  /// Chains an operation returning another result without nesting results.
  Result<U, E> flatMap<U>(Result<U, E> Function(T value) transform) =>
      switch (this) {
        Success<T, E>(:final value) => transform(value),
        FailureResult<T, E>(:final error) => FailureResult<U, E>(error),
      };

  /// Asynchronously chains a result-returning operation without nesting.
  Future<Result<U, E>> flatMapAsync<U>(
    Future<Result<U, E>> Function(T value) transform,
  ) async =>
      switch (this) {
        Success<T, E>(:final value) => await transform(value),
        FailureResult<T, E>(:final error) => FailureResult<U, E>(error),
      };

  /// Returns the success value, or `null` for a failure.
  T? getOrNull() => switch (this) {
        Success<T, E>(:final value) => value,
        FailureResult<T, E>() => null,
      };

  /// Returns the error, or `null` for a success.
  E? errorOrNull() => switch (this) {
        Success<T, E>() => null,
        FailureResult<T, E>(:final error) => error,
      };

  /// Returns the success value or computes a fallback from the error.
  T getOrElse(T Function(E error) fallback) => switch (this) {
        Success<T, E>(:final value) => value,
        FailureResult<T, E>(:final error) => fallback(error),
      };
}
