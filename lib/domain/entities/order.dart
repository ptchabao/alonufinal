import 'package:equatable/equatable.dart';

enum OrderStatus { PENDING, CONFIRMED, IN_PROGRESS, DELIVERED, COMPLETED, DISPUTED, CANCELLED }

class OrderItem extends Equatable {
  final String productId;
  final int quantity;
  final double pricePerUnit;
  final String productTitle;

  OrderItem({
    required this.productId,
    required this.quantity,
    required this.pricePerUnit,
    required this.productTitle,
  });

  double get totalPrice => pricePerUnit * quantity;

  @override
  List<Object?> get props => [productId, quantity, pricePerUnit, productTitle];
}

class Order extends Equatable {
  final String id;
  final String clientId;
  final String artisanId;
  final List<OrderItem> items;
  final OrderStatus status;
  final String deliveryAddress;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final double totalAmount;
  final String currency;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? cancellationReason;

  Order({
    required this.id,
    required this.clientId,
    required this.artisanId,
    required this.items,
    required this.status,
    required this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    required this.totalAmount,
    required this.currency,
    required this.createdAt,
    this.updatedAt,
    this.cancellationReason,
  });

  @override
  List<Object?> get props => [
    id,
    clientId,
    artisanId,
    items,
    status,
    deliveryAddress,
    deliveryLatitude,
    deliveryLongitude,
    totalAmount,
    currency,
    createdAt,
    updatedAt,
    cancellationReason,
  ];

  Order copyWith({
    String? id,
    String? clientId,
    String? artisanId,
    List<OrderItem>? items,
    OrderStatus? status,
    String? deliveryAddress,
    double? deliveryLatitude,
    double? deliveryLongitude,
    double? totalAmount,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? cancellationReason,
  }) {
    return Order(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      artisanId: artisanId ?? this.artisanId,
      items: items ?? this.items,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryLatitude: deliveryLatitude ?? this.deliveryLatitude,
      deliveryLongitude: deliveryLongitude ?? this.deliveryLongitude,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }
}

enum PaymentStatus { PENDING, SUCCESS, FAILED, CANCELLED }

enum PaymentOperator { FLOOZ, TMONEY }

class Payment extends Equatable {
  final String id;
  final String orderId;
  final double amount;
  final String currency;
  final PaymentOperator operator;
  final String phoneNumber;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? errorMessage;

  Payment({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.operator,
    required this.phoneNumber,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
    id,
    orderId,
    amount,
    currency,
    operator,
    phoneNumber,
    status,
    createdAt,
    completedAt,
    errorMessage,
  ];
}
