/// Streaming operation that emits plain values instead of `Result` values.
///
/// Prefer `StreamUseCase` or `ResultStreamUseCase` when stream errors should
/// become typed values.
abstract class ValueStreamUseCase<Output, Params> {
  const ValueStreamUseCase();

  Stream<Output> execute(Params params);

  Stream<Output> call(Params params) => execute(params);
}

/// Parameterless streaming operation that emits plain values.
abstract class NoParamsValueStreamUseCase<Output> {
  const NoParamsValueStreamUseCase();

  Stream<Output> execute();

  Stream<Output> call() => execute();
}
