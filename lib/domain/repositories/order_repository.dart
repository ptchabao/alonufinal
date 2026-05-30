import 'package:dartz/dartz.dart' show Either;
import '../../core/errors/failure.dart';
import '../entities/order.dart';

abstract class OrderRepository {
  Future<Either<Failure, Order>> createOrder(Order order);
  Future<Either<Failure, List<Order>>> getMyOrders({required bool isArtisan, int? page});
  Future<Either<Failure, Order>> getOrder(String orderId);
  Future<Either<Failure, Order>> updateOrderStatus(String orderId, OrderStatus status);
  Future<Either<Failure, void>> cancelOrder(String orderId, String reason);
}

abstract class PaymentRepository {
  Future<Either<Failure, Payment>> initiateOrderPayment({
    required String orderId,
    required String phoneNumber,
    required PaymentOperator operator,
  });
  Future<Either<Failure, Payment>> checkPaymentStatus(String paymentId);
  Future<Either<Failure, List<Payment>>> getPaymentHistory({int? page});
  Future<Either<Failure, Payment>> initiateDonationPayment({
    required String donationId,
    required String phoneNumber,
    required PaymentOperator operator,
  });
  Future<Either<Failure, Payment>> initiateSubscriptionPayment({
    required String userId,
    required String phoneNumber,
    required PaymentOperator operator,
  });
}
