import 'package:smart_domain/smart_domain.dart';
import 'package:test/test.dart';

final class BusinessFailure extends Failure {
  const BusinessFailure({super.message});
}

final class StringFailureMapper implements FailureMapper<String> {
  const StringFailureMapper();

  @override
  Failure map(String error, [StackTrace? stackTrace]) =>
      UnknownFailure(message: error, stackTrace: stackTrace);
}

void main() {
  test('Failure remains extensible for business failures', () {
    const failure = BusinessFailure(message: 'declined');
    expect(failure.toString(), 'BusinessFailure: declined');
  });

  test('common failures retain diagnostics', () {
    final cause = StateError('offline');
    final stackTrace = StackTrace.current;
    final failure = NetworkFailure(
      message: 'No connection',
      cause: cause,
      stackTrace: stackTrace,
    );

    expect(failure.message, 'No connection');
    expect(failure.cause, same(cause));
    expect(failure.stackTrace, same(stackTrace));
  });

  test('ValidationFailure defaults to no field errors', () {
    expect(const ValidationFailure().fields, isEmpty);
    expect(const ValidationFailure(fields: {'email': 'Required'}).fields, {
      'email': 'Required',
    });
  });

  test('FailureMapper supports boundary-specific conversion', () {
    const mapper = StringFailureMapper();
    final result = mapper.map('bad response');

    expect(result, isA<UnknownFailure>());
    expect(result.message, 'bad response');
  });
}
