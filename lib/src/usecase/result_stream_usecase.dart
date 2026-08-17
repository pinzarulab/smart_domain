import '../result/result.dart';

/// Streaming domain operation using an application-defined error type.
abstract class ResultStreamUseCase<Output, Params, E> {
  const ResultStreamUseCase();

  Stream<Result<Output, E>> execute(Params params);

  Stream<Result<Output, E>> call(Params params) => execute(params);
}
