import 'package:smart_domain/smart_domain.dart';
import 'package:smart_domain_example/domain/user.dart';

final class InMemoryUserRepository implements UserRepository {
  InMemoryUserRepository([this._latency = const Duration(milliseconds: 250)]);

  final Duration _latency;
  final Map<int, User> _users = {
    1: const User(id: 1, name: 'Ada Lovelace', email: 'ada@example.com'),
    2: const User(id: 2, name: 'Grace Hopper', email: 'grace@example.com'),
    3: const User(id: 3, name: 'Edsger Dijkstra', email: 'edsger@example.com'),
  };

  @override
  Future<Result<User, Failure>> getUser(int id) async {
    if (id <= 0) {
      return Result.failure(
        const ValidationFailure(
          message: 'User ID must be greater than zero.',
          fields: {'id': 'Enter a positive integer.'},
        ),
      );
    }

    if (id == 13) {
      return Result.guardAsync(
        () async {
          await Future<void>.delayed(_latency);
          throw StateError('Simulated data-source crash');
        },
        onError: (error, stackTrace) => UnknownFailure(
          message: 'Unexpected data-source failure.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }

    await Future<void>.delayed(_latency);
    final user = _users[id];
    return user == null
        ? Result.failure(
            NotFoundFailure(message: 'No user exists with ID $id.'),
          )
        : Result.success(user);
  }

  @override
  Future<Result<void, Failure>> saveUser(User user) async {
    await Future<void>.delayed(_latency);
    _users[user.id] = user;
    return Result.unit();
  }
}
