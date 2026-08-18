## 0.3.0

- Added `Result.success`, `Result.failure`, and `Result.unit` factories.
- Added recovery, side-effect, and throwing helpers.
- Added `Future<Result<T, E>>` mapping, flat-mapping, and folding extensions.
- Allowed synchronous or asynchronous callbacks in async transformations.
- Added `Result.sequence`, `Result.traverse`, and `Result.partition` collection
  helpers.
- Added a complete multi-platform Flutter example application.

## 0.2.0

- Added `FutureUseCase` and `NoParamsFutureUseCase` for operations that return
  plain future values.
- Added `ValueStreamUseCase` and `NoParamsValueStreamUseCase` for operations
  that return plain streams.
- Kept nullable outputs generic: use `FutureUseCase<T?, P>` or
  `ValueStreamUseCase<T?, P>` without separate nullable abstractions.
- Added `Result.guardStream` for converting synchronous and asynchronous stream
  errors into typed results.
- Added standard and custom-error stream use-case abstractions.
- Added no-parameter stream use-case helpers.

## 0.1.0

- Added generic `Result<T, E>` with transformation, folding, extraction, and
  exception-guard helpers.
- Added an extensible `Failure` base class and common technical failures.
- Added `FailureMapper<E>` for boundary-specific error conversion.
- Added standard and custom-error use-case abstractions.
- Added no-parameter use-case helpers.
