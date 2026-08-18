import 'package:smart_domain/smart_domain.dart';
import 'package:test/test.dart';

void main() {
  group('ResultFutureExtensions', () {
    test('mapResult accepts synchronous and asynchronous transforms', () async {
      final sync = Future.value(
        const Success<int, String>(2),
      ).mapResult((value) => value * 2);
      final async = Future.value(
        const Success<int, String>(2),
      ).mapResult((value) async => value * 3);

      expect(await sync, const Success<int, String>(4));
      expect(await async, const Success<int, String>(6));
    });

    test('mapResult preserves failure without invoking transform', () async {
      var invoked = false;
      final result = Future.value(
        const FailureResult<int, String>('failed'),
      ).mapResult((value) {
        invoked = true;
        return value * 2;
      });

      expect(await result, const FailureResult<int, String>('failed'));
      expect(invoked, isFalse);
    });

    test('flatMapResult chains results and short-circuits failures', () async {
      final success = Future.value(
        const Success<int, String>(2),
      ).flatMapResult((value) => Success(value * 2));
      final failure = Future.value(
        const FailureResult<int, String>('failed'),
      ).flatMapResult((value) => Success(value * 2));

      expect(await success, const Success<int, String>(4));
      expect(await failure, const FailureResult<int, String>('failed'));
    });

    test('foldResult supports asynchronous branch callbacks', () async {
      final success = Future.value(
        const Success<int, String>(2),
      ).foldResult(
        onSuccess: (value) async => 'value:$value',
        onFailure: (error) => 'error:$error',
      );
      final failure = Future.value(
        const FailureResult<int, String>('failed'),
      ).foldResult(
        onSuccess: (value) => 'value:$value',
        onFailure: (error) async => 'error:$error',
      );

      expect(await success, 'value:2');
      expect(await failure, 'error:failed');
    });
  });
}
