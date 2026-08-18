import 'package:smart_domain/smart_domain.dart';
import 'package:smart_domain_generator_example/orders_repository.dart';
import 'package:test/test.dart';

void main() {
  final repository = _FakeOrdersRepository();

  test('GetOrderUseCase forwards generated params', () async {
    final result = await GetOrderUseCase(repository)(
      const GetOrderParams(id: 7),
    );

    expect(result.getOrThrow().id, 7);
  });

  test('GetOrdersUseCase has no params', () async {
    final result = await GetOrdersUseCase(repository)();

    expect(result.getOrThrow(), hasLength(2));
  });

  test('CreateOrderUseCase reuses existing params', () async {
    final result = await CreateOrderUseCase(repository)(
      const CreateOrderParams(description: 'Generated'),
    );

    expect(result.getOrThrow().description, 'Generated');
  });
}

final class _FakeOrdersRepository implements OrdersRepository {
  @override
  Future<Result<Order, Failure>> createOrder(CreateOrderParams params) async {
    return Result.success(Order(id: 3, description: params.description));
  }

  @override
  Future<Result<Order, Failure>> getOrder(int id) async {
    return Result.success(Order(id: id, description: 'Order $id'));
  }

  @override
  Future<Result<List<Order>, Failure>> getOrders() async {
    return Result.success(const [
      Order(id: 1, description: 'First'),
      Order(id: 2, description: 'Second'),
    ]);
  }
}
