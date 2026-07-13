import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';

abstract class OrderRemoteDataSource {
  // GET /orders/me ou /orders/artisan selon le rôle de l'utilisateur connecté
  Future<List<dynamic>> getOrders({required bool isArtisan, String? status});
  Future<dynamic> getOrderDetail(String orderId);
  Future<dynamic> createOrder(Map<String, dynamic> orderData);
  // PUT /orders/{id}/status
  Future<dynamic> updateOrderStatus(String orderId, String status);
  // PUT /orders/{id}/cancel
  Future<dynamic> cancelOrder(String orderId);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final Dio dio;

  OrderRemoteDataSourceImpl(this.dio);

  @override
  Future<List<dynamic>> getOrders({required bool isArtisan, String? status}) async {
    try {
      final path = isArtisan
          ? '${AppConstants.ordersEndpoint}/artisan'
          : '${AppConstants.ordersEndpoint}/me';
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}$path',
        queryParameters: {
          if (status != null) 'status': status,
        },
      );

      if (response.statusCode == 200) {
        return List<dynamic>.from(response.data['data'] ?? response.data ?? []);
      }
      throw Exception('Erreur lors du chargement des commandes');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<dynamic> getOrderDetail(String orderId) async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.ordersEndpoint}/$orderId',
      );

      if (response.statusCode == 200) {
        return response.data['data'] ?? response.data;
      }
      throw Exception('Commande non trouvée');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<dynamic> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await dio.post(
        '${AppConstants.apiBaseUrl}${AppConstants.ordersEndpoint}',
        data: orderData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data['data'] ?? response.data;
      }
      throw Exception('Erreur lors de la création de la commande');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<dynamic> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await dio.put(
        '${AppConstants.apiBaseUrl}${AppConstants.ordersEndpoint}/$orderId/status',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        return response.data['data'] ?? response.data;
      }
      throw Exception('Erreur lors de la mise à jour de la commande');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<dynamic> cancelOrder(String orderId) async {
    try {
      final response = await dio.put(
        '${AppConstants.apiBaseUrl}${AppConstants.ordersEndpoint}/$orderId/cancel',
      );

      if (response.statusCode == 200) {
        return response.data['data'] ?? response.data;
      }
      throw Exception('Erreur lors de l\'annulation');
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
