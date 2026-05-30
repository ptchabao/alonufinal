import 'package:dartz/dartz.dart' show Either, Left, Right;

import '../../core/errors/failure.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final List<Order> _orders = [
    Order(
      id: 'order1',
      clientId: 'client1',
      artisanId: 'artisan1',
      items: [
        OrderItem(productId: 'prod1', quantity: 1, pricePerUnit: 2500, productTitle: 'Réparation de robinet'),
      ],
      status: OrderStatus.CONFIRMED,
      deliveryAddress: 'Lomé, Togo',
      deliveryLatitude: 6.1725,
      deliveryLongitude: 1.2314,
      totalAmount: 2500,
      currency: 'XOF',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Order(
      id: 'order2',
      clientId: 'client1',
      artisanId: 'artisan2',
      items: [
        OrderItem(productId: 'prod2', quantity: 1, pricePerUnit: 12000, productTitle: 'Table sur mesure'),
      ],
      status: OrderStatus.IN_PROGRESS,
      deliveryAddress: 'Kara, Togo',
      deliveryLatitude: 9.5511,
      deliveryLongitude: 1.1840,
      totalAmount: 12000,
      currency: 'XOF',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  @override
  Future<Either<Failure, Order>> createOrder(Order order) async {
    _orders.add(order);
    return Right(order);
  }

  @override
  Future<Either<Failure, void>> cancelOrder(String orderId, String reason) async {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index < 0) {
      return Left(NotFoundFailure(message: 'Commande introuvable.'));
    }
    _orders[index] = _orders[index].copyWith(status: OrderStatus.CANCELLED, cancellationReason: reason, updatedAt: DateTime.now());
    return const Right(null);
  }

  @override
  Future<Either<Failure, Order>> getOrder(String orderId) async {
    try {
      final order = _orders.firstWhere((item) => item.id == orderId);
      return Right(order);
    } catch (_) {
      return Left(NotFoundFailure(message: 'Commande introuvable.'));
    }
  }

  @override
  Future<Either<Failure, List<Order>>> getMyOrders({required bool isArtisan, int? page}) async {
    final orders = _orders.where((order) {
      if (isArtisan) {
        return order.artisanId == 'artisan1';
      }
      return order.clientId == 'client1';
    }).toList();
    return Right(orders);
  }

  @override
  Future<Either<Failure, Order>> updateOrderStatus(String orderId, OrderStatus status) async {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index < 0) {
      return Left(NotFoundFailure(message: 'Commande introuvable.'));
    }
    _orders[index] = _orders[index].copyWith(status: status, updatedAt: DateTime.now());
    return Right(_orders[index]);
  }
}

class PaymentRepositoryImpl implements PaymentRepository {
  final List<Payment> _payments = [];

  @override
  Future<Either<Failure, List<Payment>>> getPaymentHistory({int? page}) async {
    return Right(_payments);
  }

  @override
  Future<Either<Failure, Payment>> initiateDonationPayment({required String donationId, required String phoneNumber, required PaymentOperator operator}) async {
    return Left(NotFoundFailure(message: 'Paiement de donation non implémenté.'));
  }

  @override
  Future<Either<Failure, Payment>> initiateOrderPayment({required String orderId, required String phoneNumber, required PaymentOperator operator}) async {
    final payment = Payment(
      id: 'payment_${_payments.length + 1}',
      orderId: orderId,
      amount: 0,
      currency: 'XOF',
      operator: operator,
      phoneNumber: phoneNumber,
      status: PaymentStatus.PENDING,
      createdAt: DateTime.now(),
    );
    _payments.add(payment);
    return Right(payment);
  }

  @override
  Future<Either<Failure, Payment>> initiateSubscriptionPayment({required String userId, required String phoneNumber, required PaymentOperator operator}) async {
    return Left(NotFoundFailure(message: 'Paiement d’abonnement non implémenté.'));
  }

  @override
  Future<Either<Failure, Payment>> checkPaymentStatus(String paymentId) async {
    try {
      final payment = _payments.firstWhere((item) => item.id == paymentId);
      return Right(payment);
    } catch (_) {
      return Left(NotFoundFailure(message: 'Paiement introuvable.'));
    }
  }
}
