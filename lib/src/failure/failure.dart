/// Base class for application failures.
///
/// Applications may extend this class with domain-specific failures.
abstract class Failure {
  const Failure({this.message, this.cause, this.stackTrace});

  final String? message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() {
    final detail = message ?? cause?.toString();
    return detail == null ? runtimeType.toString() : '$runtimeType: $detail';
  }
}
