import 'package:dartz/dartz.dart' show Either, Left, Right;

import '../../core/errors/failure.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remote;

  OrderRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, Order>> createOrder(Order order) async {
    try {
      final payload = {
        'artisanId': order.artisanId,
        'items': order.items
            .map((item) => {'productId': item.productId, 'quantity': item.quantity})
            .toList(),
        'deliveryAddress': order.deliveryAddress,
        if (order.deliveryLatitude != null) 'deliveryLatitude': order.deliveryLatitude,
        if (order.deliveryLongitude != null) 'deliveryLongitude': order.deliveryLongitude,
      };
      final data = await remote.createOrder(payload);
      return Right(_mapToOrder(data as Map<String, dynamic>));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelOrder(String orderId, String reason) async {
    try {
      await remote.cancelOrder(orderId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Order>> getOrder(String orderId) async {
    try {
      final data = await remote.getOrderDetail(orderId);
      return Right(_mapToOrder(data as Map<String, dynamic>));
    } catch (e) {
      return Left(NotFoundFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Order>>> getMyOrders({required bool isArtisan, int? page}) async {
    try {
      final list = await remote.getOrders(isArtisan: isArtisan);
      final orders = list.map((e) => _mapToOrder(e as Map<String, dynamic>)).toList();
      return Right(orders);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Order>> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final data = await remote.updateOrderStatus(orderId, status.name);
      return Right(_mapToOrder(data as Map<String, dynamic>));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Order _mapToOrder(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return Order(
      id: json['id']?.toString() ?? '',
      clientId: json['clientId']?.toString() ?? '',
      artisanId: json['artisanId']?.toString() ?? '',
      items: itemsJson.map((raw) {
        final item = raw as Map<String, dynamic>;
        return OrderItem(
          productId: item['productId']?.toString() ?? '',
          quantity: (item['quantity'] as num?)?.toInt() ?? 0,
          pricePerUnit: (item['unitPrice'] as num?)?.toDouble() ?? 0,
          productTitle: item['productTitle']?.toString() ?? 'Produit',
        );
      }).toList(),
      status: OrderStatus.values.firstWhere(
        (s) => s.name == (json['status']?.toString() ?? ''),
        orElse: () => OrderStatus.PENDING,
      ),
      deliveryAddress: json['deliveryAddress']?.toString() ?? '',
      deliveryLatitude: (json['deliveryLatitude'] as num?)?.toDouble(),
      deliveryLongitude: (json['deliveryLongitude'] as num?)?.toDouble(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString() ?? 'XOF',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
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
