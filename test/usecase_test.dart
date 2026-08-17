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
}
