import 'failure.dart';

/// Converts boundary-specific errors into domain [Failure] values.
abstract interface class FailureMapper<E> {
  Failure map(E error, [StackTrace? stackTrace]);
}
