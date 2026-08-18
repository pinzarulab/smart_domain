import 'package:flutter_test/flutter_test.dart';
import 'package:smart_domain/smart_domain.dart';
import 'package:smart_domain_example/data/in_memory_user_repository.dart';
import 'package:smart_domain_example/domain/user.dart';

void main() {
  late InMemoryUserRepository repository;

  setUp(() {
    repository = InMemoryUserRepository(Duration.zero);
  });

  test('returns typed success and not-found results', () async {
    final found = await repository.getUser(1);
    final missing = await repository.getUser(99);

    expect(found.getOrNull()?.name, 'Ada Lovelace');
    expect(missing.errorOrNull(), isA<NotFoundFailure>());
  });

  test('save returns unit and persists user', () async {
    const user = User(id: 4, name: 'Barbara', email: 'barbara@example.com');

    final saved = await repository.saveUser(user);
    final loaded = await repository.getUser(4);

    expect(saved, isA<Success<void, Failure>>());
    expect(loaded.getOrNull()?.name, 'Barbara');
  });

  test('guarded exception becomes UnknownFailure', () async {
    final result = await repository.getUser(13);

    expect(result.errorOrNull(), isA<UnknownFailure>());
    expect(result.errorOrNull()?.cause, isA<StateError>());
  });
}
