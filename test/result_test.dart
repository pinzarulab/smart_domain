import 'package:smart_domain/smart_domain.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    test('factories create success, failure, and unit results', () {
      final Result<int, String> success = Result.success(1);
      final Result<int, String> failure = Result.failure('failed');
      final unit = Result.unit<String>();

      expect(success, const Success<int, String>(1));
      expect(failure, const FailureResult<int, String>('failed'));
      expect(unit, const Success<void, String>(null));
    });

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

    test('mapAsync accepts synchronous transforms', () async {
      const Result<int, String> success = Success(2);

      expect(
        await success.mapAsync((value) => value * 2),
        const Success<int, String>(4),
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

    test('flatMapAsync accepts synchronous transforms', () async {
      const Result<int, String> success = Success(2);

      expect(
        await success.flatMapAsync((value) => Success(value * 2)),
        const Success<int, String>(4),
      );
    });

    test('extractors return values, errors, and fallbacks', () {
      const Result<int, String> success = Success(2);
      const Result<int, String> failure = FailureResult('failed');

      expect(success.getOrNull(), 2);
      expect(success.errorOrNull(), isNull);
      expect(failure.getOrNull(), isNull);
      expect(failure.errorOrNull(), 'failed');
      expect(failure.getOrElse((error) => error.length), 6);
      expect(success.getOrThrow(), 2);
      expect(() => failure.getOrThrow(), throwsA('failed'));
    });

    test('getOrThrow reports nullable null errors explicitly', () {
      const Result<int, String?> failure = FailureResult(null);

      expect(
        () => failure.getOrThrow(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'Cannot throw a null Result error.',
          ),
        ),
      );
    });

    test('recover transforms only failures into successes', () {
      const Result<int, String> success = Success(2);
      const Result<int, String> failure = FailureResult('failed');

      expect(identical(success.recover((_) => 0), success), isTrue);
      expect(failure.recover((error) => error.length), const Success(6));
    });

    test('recoverAsync accepts synchronous and asynchronous fallbacks',
        () async {
      const Result<int, String> failure = FailureResult('failed');

      expect(
        await failure.recoverAsync((error) => error.length),
        const Success<int, String>(6),
      );
      expect(
        await failure.recoverAsync((error) async => error.length * 2),
        const Success<int, String>(12),
      );
    });

    test('tap and tapError run only matching effects and preserve identity',
        () {
      const Result<int, String> success = Success(2);
      const Result<int, String> failure = FailureResult('failed');
      int? tappedValue;
      String? tappedError;

      final tappedSuccess = success
          .tap((value) => tappedValue = value)
          .tapError((error) => tappedError = error);
      final tappedFailure = failure
          .tap((value) => tappedValue = value * 2)
          .tapError((error) => tappedError = error);

      expect(identical(tappedSuccess, success), isTrue);
      expect(identical(tappedFailure, failure), isTrue);
      expect(tappedValue, 2);
      expect(tappedError, 'failed');
    });

    test('sequence preserves order and accepts sync or async results',
        () async {
      final result = await Result.sequence<int, String>([
        const Success(1),
        Future.value(const Success(2)),
        const Success(3),
      ]);

      expect(result, isA<Success<List<int>, String>>());
      expect(result.getOrNull(), [1, 2, 3]);
    });

    test('sequence returns first failure', () async {
      final result = await Result.sequence<int, String>([
        const Success(1),
        const FailureResult('first'),
        const FailureResult('second'),
      ]);

      expect(result, const FailureResult<List<int>, String>('first'));
    });

    test('traverse maps sequentially and stops at first failure', () async {
      final visited = <int>[];
      final result = await Result.traverse<int, int, String>([1, 2, 3], (
        value,
      ) {
        visited.add(value);
        return value == 2 ? const FailureResult('failed') : Success(value * 2);
      });

      expect(result, const FailureResult<List<int>, String>('failed'));
      expect(visited, [1, 2]);
    });

    test('partition collects every success and failure', () {
      final partition = Result.partition<int, String>(const [
        Success(1),
        FailureResult('first'),
        Success(2),
        FailureResult('second'),
      ]);

      expect(partition.successes, [1, 2]);
      expect(partition.failures, ['first', 'second']);
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

    test('guardStream maps values to successes', () async {
      final results = await Result.guardStream<int, String>(
        () => Stream.fromIterable([1, 2]),
        onError: (error, _) => error.toString(),
      ).toList();

      expect(results, const [Success<int, String>(1), Success<int, String>(2)]);
    });

    test('guardStream captures errors emitted after subscription', () async {
      final results = await Result.guardStream<int, String>(
        () => Stream<int>.error(StateError('failed')),
        onError: (error, _) => error.runtimeType.toString(),
      ).toList();

      expect(results, const [FailureResult<int, String>('StateError')]);
    });

    test('guardStream captures synchronous stream creation errors', () async {
      final results = await Result.guardStream<int, String>(
        () => throw StateError('failed'),
        onError: (error, _) => error.runtimeType.toString(),
      ).toList();

      expect(results, const [FailureResult<int, String>('StateError')]);
    });
  });
}
