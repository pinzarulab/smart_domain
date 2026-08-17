import 'failure.dart';

final class NetworkFailure extends Failure {
  const NetworkFailure({super.message, super.cause, super.stackTrace});
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message, super.cause, super.stackTrace});
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message, super.cause, super.stackTrace});
}

final class ForbiddenFailure extends Failure {
  const ForbiddenFailure({super.message, super.cause, super.stackTrace});
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message, super.cause, super.stackTrace});
}

final class ValidationFailure extends Failure {
  const ValidationFailure({
    this.fields = const {},
    super.message,
    super.cause,
    super.stackTrace,
  });

  /// Validation messages keyed by field name.
  final Map<String, String> fields;
}

final class ConflictFailure extends Failure {
  const ConflictFailure({super.message, super.cause, super.stackTrace});
}

final class CacheFailure extends Failure {
  const CacheFailure({super.message, super.cause, super.stackTrace});
}

final class UnknownFailure extends Failure {
  const UnknownFailure({super.message, super.cause, super.stackTrace});
}
