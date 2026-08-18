import 'package:smart_domain/smart_domain.dart';

part 'orders_repository.g.dart';

final class Order {
  const Order({required this.id, required this.description});

  final int id;
  final String description;
}

final class CreateOrderParams {
  const CreateOrderParams({required this.description});

  final String description;
}

@GenerateUseCases()
abstract interface class OrdersRepository {
  Future<Result<Order, Failure>> getOrder(int id);

  Future<Result<List<Order>, Failure>> getOrders();

  Future<Result<Order, Failure>> createOrder(CreateOrderParams params);

  Future<Result<Order, Failure>> deleteOrder(Strin);
}
