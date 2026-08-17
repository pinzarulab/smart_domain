import '../failure/failure.dart';
import '../result/result.dart';

/// Standard-failure streaming use case invoked without a parameter object.
abstract class NoParamsStreamUseCase<Output> {
  const NoParamsStreamUseCase();

  Stream<Result<Output, Failure>> execute();

  Stream<Result<Output, Failure>> call() => execute();
}

/// Custom-error streaming use case invoked without a parameter object.
abstract class NoParamsResultStreamUseCase<Output, E> {
  const NoParamsResultStreamUseCase();

  Stream<Result<Output, E>> execute();

  Stream<Result<Output, E>> call() => execute();
}
