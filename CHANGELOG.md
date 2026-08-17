## 0.2.0

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
