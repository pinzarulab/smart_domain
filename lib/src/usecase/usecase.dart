import '../failure/failure.dart';
import '../result/result.dart';

/// Domain operation using the package's standard [Failure] type.
abstract class UseCase<Output, Params> {
  const UseCase();

  Future<Result<Output, Failure>> execute(Params params);

  Future<Result<Output, Failure>> call(Params params) => execute(params);
}
