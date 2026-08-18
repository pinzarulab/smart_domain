import 'dart:async';

import 'result.dart';

/// Transformations for an asynchronous [Result].
extension ResultFutureExtensions<T, E> on Future<Result<T, E>> {
  /// Awaits this future and transforms its success value.
  Future<Result<U, E>> mapResult<U>(
    FutureOr<U> Function(T value) transform,
  ) async {
    return (await this).mapAsync(transform);
  }

  /// Awaits this future and chains another result-returning operation.
  Future<Result<U, E>> flatMapResult<U>(
    FutureOr<Result<U, E>> Function(T value) transform,
  ) async {
    return (await this).flatMapAsync(transform);
  }

  /// Awaits this future and transforms either branch into one value.
  Future<R> foldResult<R>({
    required FutureOr<R> Function(T value) onSuccess,
    required FutureOr<R> Function(E error) onFailure,
  }) async {
    final result = await this;
    return await result.fold<FutureOr<R>>(
      onSuccess: onSuccess,
      onFailure: onFailure,
    );
  }
}
