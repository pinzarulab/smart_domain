import 'package:smart_domain/smart_domain.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    test('reports its branch', () {
      const success = Success<int, String>(1);
      const failure = FailureResult<int, String>('failed');

      expect(success.isSuccess, isTrue);
      expect(success.isFailure, isFalse);
      expect(failure.isSuccess, isFalse);
      expect(failure.isFailure, isTrue);
    });

    test('fold transforms either branch', () {
      const Result<int, String> success = Success(2);
      const Result<int, String> failure = FailureResult('failed');

      expect(
        success.fold(onSuccess: (value) => value * 2, onFailure: (_) => 0),
        4,
      );
      expect(
        failure.fold(onSuccess: (value) => value * 2, onFailure: (_) => 0),
        0,
      );
    });

    test('map transforms only success', () {
      const Result<int, String> success = Success(2);
      const Result<int, String> failure = FailureResult('failed');

      expect(
        success.map((value) => '$value!'),
        const Success<String, String>('2!'),
      );
      expect(
        failure.map((value) => '$value!'),
        const FailureResult<String, String>('failed'),
      );
    });

    test('mapAsync transforms only success', () async {
      const Result<int, String> success = Success(2);
      const Result<int, String> failure = FailureResult('failed');

      expect(
        await success.mapAsync((value) async => value * 2),
        const Success<int, String>(4),
      );
      expect(
        await failure.mapAsync((value) async => value * 2),
        const FailureResult<int, String>('failed'),
      );
    });

    test('mapError transforms only failure', () {
      const Result<int, String> success = Success(2);
      const Result<int, String> failure = FailureResult('failed');

      expect(
        success.mapError((error) => error.length),
        const Success<int, int>(2),
      );
      expect(
        failure.mapError((error) => error.length),
        const FailureResult<int, int>(6),
      );
    });

    test('flatMap avoids nested results and short-circuits failure', () {
      const Result<int, String> success = Success(2);
      const Result<int, String> failure = FailureResult('failed');

      expect(
        success.flatMap((value) => Success(value * 2)),
        const Success<int, String>(4),
      );
      expect(
        failure.flatMap((value) => Success(value * 2)),
        const FailureResult<int, String>('failed'),
      );
    });

    test(
      'flatMapAsync avoids nested results and short-circuits failure',
      () async {
        const Result<int, String> success = Success(2);
        const Result<int, String> failure = FailureResult('failed');

        expect(
          await success.flatMapAsync((value) async => Success(value * 2)),
          const Success<int, String>(4),
        );
        expect(
          await failure.flatMapAsync((value) async => Success(value * 2)),
          const FailureResult<int, String>('failed'),
        );
      },
    );

    test('extractors return values, errors, and fallbacks', () {
      const Result<int, String> success = Success(2);
      const Result<int, String> failure = FailureResult('failed');

      expect(success.getOrNull(), 2);
      expect(success.errorOrNull(), isNull);
      expect(failure.getOrNull(), isNull);
      expect(failure.errorOrNull(), 'failed');
      expect(failure.getOrElse((error) => error.length), 6);
    });

    test('guard captures synchronous exceptions with stack traces', () {
      final result = Result.guard<int, String>(
        () => throw StateError('failed'),
        onError: (error, stackTrace) =>
            '${error.runtimeType}:${stackTrace.runtimeType}',
      );

      expect(result, isA<FailureResult<int, String>>());
      expect(result.errorOrNull(), startsWith('StateError:'));
    });

    test('guardAsync captures asynchronous exceptions', () async {
      final result = await Result.guardAsync<int, String>(
        () async => throw StateError('failed'),
        onError: (error, _) => error.runtimeType.toString(),
      );

      expect(result, const FailureResult<int, String>('StateError'));
    });
  });
}
