import 'package:dartz/dartz.dart' show Either;
import '../../core/errors/failure.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

class CreateOrderUseCase {
  final OrderRepository repository;

  CreateOrderUseCase(this.repository);

  Future<Either<Failure, Order>> call(Order order) {
    return repository.createOrder(order);
  }
}

class GetMyOrdersUseCase {
  final OrderRepository repository;

  GetMyOrdersUseCase(this.repository);

  Future<Either<Failure, List<Order>>> call({required bool isArtisan, int? page}) {
    return repository.getMyOrders(isArtisan: isArtisan, page: page);
  }
}

class GetOrderDetailsUseCase {
  final OrderRepository repository;

  GetOrderDetailsUseCase(this.repository);

  Future<Either<Failure, Order>> call(String orderId) {
    return repository.getOrder(orderId);
  }
}

class UpdateOrderStatusUseCase {
  final OrderRepository repository;

  UpdateOrderStatusUseCase(this.repository);

  Future<Either<Failure, Order>> call(String orderId, OrderStatus status) {
    return repository.updateOrderStatus(orderId, status);
  }
}

class CancelOrderUseCase {
  final OrderRepository repository;

  CancelOrderUseCase(this.repository);

  Future<Either<Failure, void>> call(String orderId, String reason) {
    return repository.cancelOrder(orderId, reason);
  }
}

// Payment Use Cases
class InitiateOrderPaymentUseCase {
  final PaymentRepository repository;

  InitiateOrderPaymentUseCase(this.repository);

  Future<Either<Failure, Payment>> call({
    required String orderId,
    required String phoneNumber,
    required PaymentOperator operator,
  }) {
    return repository.initiateOrderPayment(
      orderId: orderId,
      phoneNumber: phoneNumber,
      operator: operator,
    );
  }
}

class CheckPaymentStatusUseCase {
  final PaymentRepository repository;

  CheckPaymentStatusUseCase(this.repository);

  Future<Either<Failure, Payment>> call(String paymentId) {
    return repository.checkPaymentStatus(paymentId);
  }
}

class GetPaymentHistoryUseCase {
  final PaymentRepository repository;

  GetPaymentHistoryUseCase(this.repository);

  Future<Either<Failure, List<Payment>>> call({int? page}) {
    return repository.getPaymentHistory(page: page);
  }
}
