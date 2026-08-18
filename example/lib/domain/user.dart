import 'package:smart_domain/smart_domain.dart';

final class User {
  const User({required this.id, required this.name, required this.email});

  const User.guest() : id = 0, name = 'Guest user', email = 'guest@example.com';

  final int id;
  final String name;
  final String email;

  @override
  String toString() => '$name <$email>';
}

abstract interface class UserRepository {
  Future<Result<User, Failure>> getUser(int id);

  Future<Result<void, Failure>> saveUser(User user);
}
