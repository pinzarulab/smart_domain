import 'package:smart_domain/smart_domain.dart';
import 'package:test/test.dart';

final class DoubleUseCase extends UseCase<int, int> {
  const DoubleUseCase();

  @override
  Future<Result<int, Failure>> execute(int params) async => Success(params * 2);
}

final class CustomErrorUseCase extends ResultUseCase<int, int, String> {
  const CustomErrorUseCase();

  @override
  Future<Result<int, String>> execute(int params) async =>
      params >= 0 ? Success(params) : const FailureResult('negative');
}

final class CurrentValueUseCase extends NoParamsUseCase<int> {
  const CurrentValueUseCase();

  @override
  Future<Result<int, Failure>> execute() async => const Success(42);
}

final class CountUseCase extends ResultStreamUseCase<int, int, String> {
  const CountUseCase();

  @override
  Stream<Result<int, String>> execute(int params) => Stream.fromIterable([
        for (var value = 0; value < params; value++) Success(value),
      ]);
}

final class CurrentValuesUseCase
    extends NoParamsResultStreamUseCase<int, String> {
  const CurrentValuesUseCase();

  @override
  Stream<Result<int, String>> execute() => Stream.value(const Success(42));
}

final class DoubleValueUseCase extends FutureUseCase<int, int> {
  const DoubleValueUseCase();

  @override
  Future<int> execute(int params) async => params * 2;
}

final class CurrentNullableValueUseCase extends NoParamsFutureUseCase<String?> {
  const CurrentNullableValueUseCase();

  @override
  Future<String?> execute() async => null;
}

final class ValueSequenceUseCase extends ValueStreamUseCase<int, int> {
  const ValueSequenceUseCase();

  @override
  Stream<int> execute(int params) => Stream.fromIterable([
        for (var value = 0; value < params; value++) value,
      ]);
}

final class CurrentValueSequenceUseCase
    extends NoParamsValueStreamUseCase<int> {
  const CurrentValueSequenceUseCase();

  @override
  Stream<int> execute() => Stream.value(42);
}

void main() {
  test('UseCase call delegates to execute', () async {
    expect(await const DoubleUseCase()(4), const Success<int, Failure>(8));
  });

  test('ResultUseCase supports custom errors', () async {
    expect(
      await const CustomErrorUseCase()(-1),
      const FailureResult<int, String>('negative'),
    );
  });

  test('NoParamsUseCase is called without arguments', () async {
    expect(
      await const CurrentValueUseCase()(),
      const Success<int, Failure>(42),
    );
  });

  test('NoParams is a canonical constant', () {
    expect(identical(const NoParams(), const NoParams()), isTrue);
  });

  test('ResultStreamUseCase call delegates to execute', () async {
    expect(
      await const CountUseCase()(2).toList(),
      const [Success<int, String>(0), Success<int, String>(1)],
    );
  });

  test('NoParamsResultStreamUseCase is called without arguments', () async {
    expect(
      await const CurrentValuesUseCase()().single,
      const Success<int, String>(42),
    );
  });

  test('FutureUseCase call delegates to execute', () async {
    expect(await const DoubleValueUseCase()(4), 8);
  });

  test('NoParamsFutureUseCase supports nullable outputs', () async {
    expect(await const CurrentNullableValueUseCase()(), isNull);
  });

  test('ValueStreamUseCase call delegates to execute', () async {
    expect(await const ValueSequenceUseCase()(3).toList(), [0, 1, 2]);
  });

  test('NoParamsValueStreamUseCase is called without arguments', () async {
    expect(await const CurrentValueSequenceUseCase()().single, 42);
  });
}
