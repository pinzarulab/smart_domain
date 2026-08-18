// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_repository.dart';

// **************************************************************************
// UseCaseGenerator
// **************************************************************************

final class GetOrderParams {
  const GetOrderParams({required this.id});

  final int id;
}

final class GetOrderUseCase extends UseCase<Order, GetOrderParams> {
  const GetOrderUseCase(this.repository);

  final OrdersRepository repository;

  @override
  Future<Result<Order, Failure>> execute(GetOrderParams params) =>
      repository.getOrder(params.id);
}

final class GetOrdersUseCase extends NoParamsUseCase<List<Order>> {
  const GetOrdersUseCase(this.repository);

  final OrdersRepository repository;

  @override
  Future<Result<List<Order>, Failure>> execute() => repository.getOrders();
}

final class CreateOrderUseCase extends UseCase<Order, CreateOrderParams> {
  const CreateOrderUseCase(this.repository);

  final OrdersRepository repository;

  @override
  Future<Result<Order, Failure>> execute(CreateOrderParams params) =>
      repository.createOrder(params);
}
