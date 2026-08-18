import 'package:smart_domain/smart_domain.dart';
import 'package:smart_domain_example/domain/user.dart';

final class GetUserUseCase extends UseCase<User, int> {
  const GetUserUseCase(this._repository);

  final UserRepository _repository;

  @override
  Future<Result<User, Failure>> execute(int id) => _repository.getUser(id);
}

final class GetUserNameUseCase extends UseCase<String, int> {
  const GetUserNameUseCase(this._repository);

  final UserRepository _repository;

  @override
  Future<Result<String, Failure>> execute(int id) {
    return _repository.getUser(id).mapResult((user) => user.name);
  }
}

final class SaveUserUseCase extends UseCase<void, User> {
  const SaveUserUseCase(this._repository);

  final UserRepository _repository;

  @override
  Future<Result<void, Failure>> execute(User user) {
    return _repository.saveUser(user);
  }
}

final class LoadUsersUseCase extends UseCase<List<User>, List<int>> {
  const LoadUsersUseCase(this._repository);

  final UserRepository _repository;

  @override
  Future<Result<List<User>, Failure>> execute(List<int> ids) {
    return Result.traverse(ids, _repository.getUser);
  }
}
