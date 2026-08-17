import 'package:smart_domain/smart_domain.dart';

final class User {
  const User(this.name);

  final String name;
}

final class LoadUser extends UseCase<User, int> {
  const LoadUser();

  @override
  Future<Result<User, Failure>> execute(int id) async {
    if (id <= 0) {
      return const FailureResult(NotFoundFailure(message: 'Invalid user ID'));
    }
    return const Success(User('Ada'));
  }
}

Future<void> main() async {
  final result = await const LoadUser()(42);
  print(
    result.fold(
      onSuccess: (user) => user.name,
      onFailure: (failure) => failure,
    ),
  );
}
