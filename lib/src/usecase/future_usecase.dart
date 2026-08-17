/// Async operation whose failures remain exception-based.
///
/// Prefer `UseCase` or `ResultUseCase` for fallible domain operations. This
/// abstraction remains useful for infallible storage or platform operations.
abstract class FutureUseCase<Output, Params> {
  const FutureUseCase();

  Future<Output> execute(Params params);

  Future<Output> call(Params params) => execute(params);
}

/// Parameterless async operation whose failures remain exception-based.
abstract class NoParamsFutureUseCase<Output> {
  const NoParamsFutureUseCase();

  Future<Output> execute();

  Future<Output> call() => execute();
}
