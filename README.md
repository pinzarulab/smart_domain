# smart_domain

Dependency-free `Result`, `Failure`, and `UseCase` primitives for Clean
Architecture domain layers. Package has no knowledge of HTTP clients,
databases, state management, or repository implementations.

## Installation

```yaml
dependencies:
  smart_domain: ^0.3.0
```

## Result

`Result<T, E>` accepts any error type. Using `Failure` is optional.

```dart
import 'package:smart_domain/smart_domain.dart';

Future<Result<User, Failure>> getUser(int id) async {
  return Result.guardAsync(
    () => api.getUser(id),
    onError: (error, stackTrace) => NetworkFailure(
      cause: error,
      stackTrace: stackTrace,
    ),
  );
}

final result = await getUser(42);

result.fold(
  onSuccess: (user) => print(user.name),
  onFailure: (failure) => print(failure),
);
```

Transform success or error branches without throwing:

```dart
final Result<String, Failure> name = result.map((user) => user.name);

final Result<Profile, Failure> profile = await result.flatMapAsync(
  (user) => loadProfile(user.id),
);
```

Create each result branch without naming implementation classes:

```dart
final Result<User, Failure> user = Result.success(value);
final Result<User, Failure> failed = Result.failure(error);
final Result<void, Failure> saved = Result.unit();
```

Recover failures, observe branches, or cross an exception-based boundary:

```dart
final recovered = result.recover((failure) => fallbackUser);

result
    .tap((user) => cache.store(user))
    .tapError(logger.error);

final user = result.getOrThrow();
```

Transform a future result directly. Callbacks may be synchronous or
asynchronous:

```dart
final name = repository
    .getUser(42)
    .mapResult((user) => user.name);

final profile = repository
    .getUser(42)
    .flatMapResult((user) => repository.getProfile(user.id));

final label = repository.getUser(42).foldResult(
  onSuccess: (user) => user.name,
  onFailure: (failure) => failure.message ?? 'Unknown user',
);
```

Compose collections while preserving input order:

```dart
final users = await Result.sequence([
  repository.getUser(1),
  repository.getUser(2),
]);

final profiles = await Result.traverse(
  userIds,
  repository.getUser,
);

final partition = Result.partition(results);
print(partition.successes);
print(partition.failures);
```

`sequence` and `traverse` stop at first failure. `partition` processes every
result.

Available operations:

- `map`, `mapAsync`, `mapError`
- `flatMap`, `flatMapAsync`
- `fold`
- `recover`, `recoverAsync`
- `tap`, `tapError`
- `getOrNull`, `errorOrNull`, `getOrElse`, `getOrThrow`
- `guard`, `guardAsync`
- `guardStream`
- `sequence`, `traverse`, `partition`
- `mapResult`, `flatMapResult`, `foldResult` on future results

## Failures

Built-in failures cover common technical categories without encoding transport
details such as HTTP status codes:

- `NetworkFailure`, `TimeoutFailure`
- `UnauthorizedFailure`, `ForbiddenFailure`
- `NotFoundFailure`, `ValidationFailure`, `ConflictFailure`
- `CacheFailure`, `UnknownFailure`

Applications can define business failures directly:

```dart
final class PaymentDeclinedFailure extends Failure {
  const PaymentDeclinedFailure({super.message, super.cause});
}
```

Map external errors at data boundaries with `FailureMapper<E>`:

```dart
final class ApiFailureMapper implements FailureMapper<ApiException> {
  const ApiFailureMapper();

  @override
  Failure map(ApiException error, [StackTrace? stackTrace]) {
    return switch (error.statusCode) {
      401 => UnauthorizedFailure(cause: error, stackTrace: stackTrace),
      404 => NotFoundFailure(cause: error, stackTrace: stackTrace),
      _ => UnknownFailure(cause: error, stackTrace: stackTrace),
    };
  }
}
```

## Use cases

`UseCase<Output, Params>` standardizes on `Failure`:

```dart
abstract interface class UserRepository {
  Future<Result<User, Failure>> getUser(int id);
}

final class GetUserParams {
  const GetUserParams({required this.id});

  final int id;
}

final class GetUserUseCase extends UseCase<User, GetUserParams> {
  const GetUserUseCase(this.repository);

  final UserRepository repository;

  @override
  Future<Result<User, Failure>> execute(GetUserParams params) {
    return repository.getUser(params.id);
  }
}

final result = await GetUserUseCase(repository)(
  const GetUserParams(id: 42),
);
```

Use `ResultUseCase<Output, Params, Error>` for a custom error type.
`NoParamsUseCase<Output>` supports `await useCase()` calls. `NoParams` remains
available when uniform parameterized use cases are preferred.

For reactive repositories, use `StreamUseCase<Output, Params>` or
`ResultStreamUseCase<Output, Params, Error>`. `Result.guardStream` converts
both stream-creation errors and errors emitted after subscription:

```dart
Stream<Result<List<Message>, Failure>> execute(ChatParams params) {
  return Result.guardStream(
    () => repository.watchMessages(params.chatId),
    onError: (error, stackTrace) => UnknownFailure(
      cause: error,
      stackTrace: stackTrace,
    ),
  );
}
```

For deliberately exception-based or infallible operations, use
`FutureUseCase<Output, Params>` and `ValueStreamUseCase<Output, Params>`.
Parameterless variants are `NoParamsFutureUseCase` and
`NoParamsValueStreamUseCase`. Nullable output needs no extra abstraction:
`FutureUseCase<String?, Params>` works directly.

## Package boundary

`smart_domain` is standalone. It does not depend on or modify
`smart_repository`. A data-layer repository can return `Result<T, Failure>` or
adapt another result type at the application boundary.

## Roadmap

Middleware and typed use-case composition are candidates for later releases.
