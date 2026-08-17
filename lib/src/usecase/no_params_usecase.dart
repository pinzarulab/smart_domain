import '../failure/failure.dart';
import '../result/result.dart';

/// Standard-failure use case invoked without a parameter object.
abstract class NoParamsUseCase<Output> {
  const NoParamsUseCase();

  Future<Result<Output, Failure>> execute();

  Future<Result<Output, Failure>> call() => execute();
}
