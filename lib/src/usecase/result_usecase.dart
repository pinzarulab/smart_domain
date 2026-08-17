import '../result/result.dart';

/// Domain operation using an application-defined error type.
abstract class ResultUseCase<Output, Params, E> {
  const ResultUseCase();

  Future<Result<Output, E>> execute(Params params);

  Future<Result<Output, E>> call(Params params) => execute(params);
}
