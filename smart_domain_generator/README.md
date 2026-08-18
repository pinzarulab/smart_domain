# smart_domain_generator

Generates `UseCase` classes from repository interfaces annotated with
`@GenerateUseCases()`.

## Setup

```yaml
dependencies:
  smart_domain: ^0.3.0

dev_dependencies:
  build_runner: ^2.16.0
  smart_domain_generator: ^0.1.0
```

Add a part directive and annotate the repository:

```dart
import 'package:smart_domain/smart_domain.dart';

part 'orders_repository.g.dart';

@GenerateUseCases()
abstract interface class OrdersRepository {
  Future<Result<Order, Failure>> getOrder(int id);

  Future<Result<List<Order>, Failure>> getOrders();

  Future<Result<Order, Failure>> createOrder(CreateOrderParams params);
}
```

Generate the code:

```sh
dart run build_runner build
```

The generator creates `GetOrderUseCase`, `GetOrderParams`,
`GetOrdersUseCase`, and `CreateOrderUseCase`. A parameter type ending in
`Params` is reused. Other method parameters are wrapped in a generated params
class.
