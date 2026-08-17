part of 'result.dart';

/// Failed [Result] containing [error].
final class FailureResult<T, E> extends Result<T, E> {
  const FailureResult(this.error);

  final E error;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FailureResult<T, E> && other.error == error;

  @override
  int get hashCode => Object.hash(FailureResult, error);

  @override
  String toString() => 'FailureResult($error)';
}
