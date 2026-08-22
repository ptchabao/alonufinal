import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';

/// Conforme à ALONU_API_Documentation.md — module Payments. PayGate étant
/// asynchrone (push USSD), chaque `initiate*` retourne un `paymentId` à
/// suivre via [getPaymentStatus] (polling) jusqu'à COMPLETED/FAILED.
abstract class PaymentRemoteDataSource {
  // POST /payments/order/{orderId}/initiate
  Future<Map<String, dynamic>> initiateOrderPayment(
    String orderId, {
    required String phoneNumber,
    required String network,
    String? description,
  });

  // POST /payments/donation/{donationId}/initiate
  Future<Map<String, dynamic>> initiateDonationPayment(
    String donationId, {
    required String phoneNumber,
    required String network,
    String? description,
  });

  // POST /payments/subscription/initiate
  Future<Map<String, dynamic>> initiateSubscriptionPayment({
    required String targetType,
    required String targetId,
    required String phoneNumber,
    required String network,
    double? amount,
    String? description,
  });

  // POST /payments/microfinance-adhesion/{adhesionId}/initiate
  Future<Map<String, dynamic>> initiateMicrofinanceAdhesionPayment(
    String adhesionId, {
    required String phoneNumber,
    required String network,
    String? description,
  });

  // POST /payments/verify
  Future<Map<String, dynamic>> verifyPayment({
    String? txReference,
    String? identifier,
  });

  // GET /payments/{paymentId}/status
  Future<Map<String, dynamic>> getPaymentStatus(String paymentId);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final Dio dio;

  PaymentRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> initiateOrderPayment(
    String orderId, {
    required String phoneNumber,
    required String network,
    String? description,
  }) async {
    try {
      final response = await dio.post(
        '${AppConstants.apiBaseUrl}${AppConstants.paymentsEndpoint}/order/$orderId/initiate',
        data: {
          'phoneNumber': phoneNumber,
          'network': network,
          if (description != null) 'description': description,
        },
      );
      return _asMap(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> initiateDonationPayment(
    String donationId, {
    required String phoneNumber,
    required String network,
    String? description,
  }) async {
    try {
      final response = await dio.post(
        '${AppConstants.apiBaseUrl}${AppConstants.paymentsEndpoint}/donation/$donationId/initiate',
        data: {
          'phoneNumber': phoneNumber,
          'network': network,
          if (description != null) 'description': description,
        },
      );
      return _asMap(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> initiateSubscriptionPayment({
    required String targetType,
    required String targetId,
    required String phoneNumber,
    required String network,
    double? amount,
    String? description,
  }) async {
    try {
      final response = await dio.post(
        '${AppConstants.apiBaseUrl}${AppConstants.paymentsEndpoint}/subscription/initiate',
        data: {
          'targetType': targetType,
          'targetId': targetId,
          'phoneNumber': phoneNumber,
          'network': network,
          if (amount != null) 'amount': amount,
          if (description != null) 'description': description,
        },
      );
      return _asMap(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> initiateMicrofinanceAdhesionPayment(
    String adhesionId, {
    required String phoneNumber,
    required String network,
    String? description,
  }) async {
    try {
      final response = await dio.post(
        '${AppConstants.apiBaseUrl}${AppConstants.paymentsEndpoint}/microfinance-adhesion/$adhesionId/initiate',
        data: {
          'phoneNumber': phoneNumber,
          'network': network,
          if (description != null) 'description': description,
        },
      );
      return _asMap(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> verifyPayment({
    String? txReference,
    String? identifier,
  }) async {
    try {
      final response = await dio.post(
        '${AppConstants.apiBaseUrl}${AppConstants.paymentsEndpoint}/verify',
        data: {
          if (txReference != null) 'txReference': txReference,
          if (identifier != null) 'identifier': identifier,
        },
      );
      return _asMap(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getPaymentStatus(String paymentId) async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.paymentsEndpoint}/$paymentId/status',
      );
      return _asMap(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map) {
      final nested = data['data'];
      if (nested is Map) return Map<String, dynamic>.from(nested);
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }

  Exception _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Délai d\'attente dépassé');
    }
    if (e.type == DioExceptionType.unknown) {
      return Exception('Erreur réseau');
    }
    if (e.response?.statusCode == 404) {
      return Exception('Ressource non trouvée');
    }
    if (e.response?.statusCode == 500) {
      return Exception('Erreur serveur');
    }
    return Exception(e.message ?? 'Erreur inconnue');
  }
}
