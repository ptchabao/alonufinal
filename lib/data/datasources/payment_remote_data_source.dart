import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';

abstract class PaymentRemoteDataSource {
  Future<dynamic> initializePayment(Map<String, dynamic> paymentData);
  Future<dynamic> verifyPayment(String transactionId);
  Future<dynamic> getPaymentStatus(String orderId);
  Future<List<dynamic>> getPaymentMethods();
  Future<dynamic> processRefund(String orderId, {String? reason});
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final Dio dio;

  PaymentRemoteDataSourceImpl(this.dio);

  @override
  Future<dynamic> initializePayment(Map<String, dynamic> paymentData) async {
    try {
      final response = await dio.post(
        '${AppConstants.apiBaseUrl}${AppConstants.paymentsEndpoint}/initialize',
        data: paymentData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['data'] ?? response.data;
      }
      throw Exception('Erreur lors de l\'initialisation du paiement');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<dynamic> verifyPayment(String transactionId) async {
    try {
      final response = await dio.post(
        '${AppConstants.apiBaseUrl}${AppConstants.paymentsEndpoint}/verify',
        data: {'transactionId': transactionId},
      );

      if (response.statusCode == 200) {
        return response.data['data'] ?? response.data;
      }
      throw Exception('Erreur lors de la vérification du paiement');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<dynamic> getPaymentStatus(String orderId) async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.paymentsEndpoint}/status/$orderId',
      );

      if (response.statusCode == 200) {
        return response.data['data'] ?? response.data;
      }
      throw Exception('Erreur lors de la récupération du statut');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<List<dynamic>> getPaymentMethods() async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.paymentsEndpoint}/methods',
      );

      if (response.statusCode == 200) {
        return List<dynamic>.from(response.data['data'] ?? response.data ?? []);
      }
      throw Exception('Erreur lors du chargement des méthodes de paiement');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<dynamic> processRefund(String orderId, {String? reason}) async {
    try {
      final response = await dio.post(
        '${AppConstants.apiBaseUrl}${AppConstants.paymentsEndpoint}/refund',
        data: {
          'orderId': orderId,
          if (reason != null) 'reason': reason,
        },
      );

      if (response.statusCode == 200) {
        return response.data['data'] ?? response.data;
      }
      throw Exception('Erreur lors du remboursement');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
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
