import '../failure/failure.dart';
import '../result/result.dart';

/// Streaming domain operation using the package's standard [Failure] type.
abstract class StreamUseCase<Output, Params> {
  const StreamUseCase();

  Stream<Result<Output, Failure>> execute(Params params);

  Stream<Result<Output, Failure>> call(Params params) => execute(params);
}
