# smart_domain Flutter example

Runnable Material app demonstrating:

- `Result.success`, `Result.failure`, and `Result.unit`
- `guardAsync`, `recoverAsync`, `tap`, `tapError`, and `getOrThrow`
- `mapResult`, `sequence`, `traverse`, and `partition`
- `UseCase` and repository boundaries
- success, validation, not-found, and unexpected failures

## Run

```sh
cd example
flutter pub get
flutter run
```

Choose any available Flutter device. Android, iOS, web, macOS, Windows, and
Linux scaffolding is included.

Useful IDs in lookup demo:

- `1`, `2`, `3`: successful users
- `0` or negative: validation failure
- `13`: guarded exception converted to `UnknownFailure`
- any other ID: `NotFoundFailure`

## Test

```sh
flutter test
flutter analyze
```
