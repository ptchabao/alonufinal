import 'package:equatable/equatable.dart';

enum NotificationType {
  NEW_ORDER,
  ORDER_STATUS_CHANGED,
  ARTISAN_VALIDATED,
  NEW_DONATION,
  NEW_APPRENTICE,
  PROMOTION,
  PAYMENT,
}

class Notification extends Equatable {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data; // For deep linking

  Notification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  @override
  List<Object?> get props => [id, userId, type, title, message, isRead, createdAt, data];

  Notification copyWith({bool? isRead}) {
    return Notification(
      id: id,
      userId: userId,
      type: type,
      title: title,
      message: message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      data: data,
    );
  }
}

enum DonationType { ARTISAN, STUDENT, PLATFORM }

class Donation extends Equatable {
  final String id;
  final String donorId;
  final DonationType type;
  final String? recipientId; // artisan/student ID if not platform
  final double amount;
  final String currency;
  final String? message;
  final bool isAnonymous;
  final DateTime createdAt;

  Donation({
    required this.id,
    required this.donorId,
    required this.type,
    this.recipientId,
    required this.amount,
    required this.currency,
    this.message,
    required this.isAnonymous,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    donorId,
    type,
    recipientId,
    amount,
    currency,
    message,
    isAnonymous,
    createdAt,
  ];
}

class ReferralCode extends Equatable {
  final String code;
  final String userId;
  final int referredCount;
  final int activeReferrals;
  final double rewardsAccumulated;
  final DateTime createdAt;

  ReferralCode({
    required this.code,
    required this.userId,
    required this.referredCount,
    required this.activeReferrals,
    required this.rewardsAccumulated,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    code,
    userId,
    referredCount,
    activeReferrals,
    rewardsAccumulated,
    createdAt,
  ];
}

class Advertisement extends Equatable {
  final String id;
  final String title;
  final String? subtitle;
  final String description;
  final List<String> imageUrls;
  final String? actionUrl;
  final DateTime expiresAt;
  final int clicks;
  final int views;

  Advertisement({
    required this.id,
    required this.title,
    this.subtitle,
    required this.description,
    required this.imageUrls,
    this.actionUrl,
    required this.expiresAt,
    required this.clicks,
    required this.views,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    subtitle,
    description,
    imageUrls,
    actionUrl,
    expiresAt,
    clicks,
    views,
  ];
}
