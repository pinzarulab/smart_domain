import 'dart:async';

part 'failure_result.dart';
part 'success.dart';

/// Successes and failures collected from multiple [Result] values.
typedef ResultPartition<T, E> = ({List<T> successes, List<E> failures});

/// Outcome of an operation that either contains a value or an error.
///
/// `Result` is intentionally independent from the package's `Failure` type.
/// Use any error type suitable for the domain.
sealed class Result<T, E> {
  const Result();

  /// Creates a successful result.
  static Result<T, E> success<T, E>(T value) => Success<T, E>(value);

  /// Creates a failed result.
  static Result<T, E> failure<T, E>(E error) => FailureResult<T, E>(error);

  /// Creates a successful result for an operation with no output value.
  static Result<void, E> unit<E>() => Success<void, E>(null);

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

  /// Collects successful results in input order or returns the first failure.
  static Future<Result<List<T>, E>> sequence<T, E>(
    Iterable<FutureOr<Result<T, E>>> results,
  ) async {
    final values = <T>[];
    for (final resultOrFuture in results) {
      final result = await resultOrFuture;
      switch (result) {
        case Success<T, E>(:final value):
          values.add(value);
        case FailureResult<T, E>(:final error):
          return FailureResult<List<T>, E>(error);
      }
    }
    return Success<List<T>, E>(values);
  }

  /// Maps each input to a result, collecting values or stopping at failure.
  static Future<Result<List<T>, E>> traverse<Input, T, E>(
    Iterable<Input> inputs,
    FutureOr<Result<T, E>> Function(Input input) transform,
  ) async {
    final values = <T>[];
    for (final input in inputs) {
      final result = await transform(input);
      switch (result) {
        case Success<T, E>(:final value):
          values.add(value);
        case FailureResult<T, E>(:final error):
          return FailureResult<List<T>, E>(error);
      }
    }
    return Success<List<T>, E>(values);
  }

  /// Separates all successes and failures without short-circuiting.
  static ResultPartition<T, E> partition<T, E>(
    Iterable<Result<T, E>> results,
  ) {
    final successes = <T>[];
    final failures = <E>[];
    for (final result in results) {
      switch (result) {
        case Success<T, E>(:final value):
          successes.add(value);
        case FailureResult<T, E>(:final error):
          failures.add(error);
      }
    }
    return (successes: successes, failures: failures);
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
    FutureOr<U> Function(T value) transform,
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
    FutureOr<Result<U, E>> Function(T value) transform,
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

  /// Replaces a failure with a successful fallback value.
  Result<T, E> recover(T Function(E error) fallback) => switch (this) {
        Success<T, E>() => this,
        FailureResult<T, E>(:final error) => Success<T, E>(fallback(error)),
      };

  /// Asynchronously replaces a failure with a successful fallback value.
  Future<Result<T, E>> recoverAsync(
    FutureOr<T> Function(E error) fallback,
  ) async =>
      switch (this) {
        Success<T, E>() => this,
        FailureResult<T, E>(:final error) =>
          Success<T, E>(await fallback(error)),
      };

  /// Runs [effect] for a success and returns this result unchanged.
  Result<T, E> tap(void Function(T value) effect) {
    if (this case Success<T, E>(:final value)) effect(value);
    return this;
  }

  /// Runs [effect] for a failure and returns this result unchanged.
  Result<T, E> tapError(void Function(E error) effect) {
    if (this case FailureResult<T, E>(:final error)) effect(error);
    return this;
  }

  /// Returns the success value or throws the contained error.
  T getOrThrow() {
    return switch (this) {
      Success<T, E>(:final value) => value,
      FailureResult<T, E>(:final error) when error is Object => throw error,
      FailureResult<T, E>() => throw StateError(
          'Cannot throw a null Result error.',
        ),
    };
  }
}
