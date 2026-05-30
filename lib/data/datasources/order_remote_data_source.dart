import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';

abstract class OrderRemoteDataSource {
  Future<List<dynamic>> getOrders({int page = 1, int limit = 20});
  Future<dynamic> getOrderDetail(String orderId);
  Future<dynamic> createOrder(Map<String, dynamic> orderData);
  Future<dynamic> updateOrder(String orderId, Map<String, dynamic> updateData);
  Future<dynamic> cancelOrder(String orderId);
  Future<dynamic> trackOrder(String orderId);
  Future<dynamic> downloadInvoice(String orderId);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final Dio dio;

  OrderRemoteDataSourceImpl(this.dio);

  @override
  Future<List<dynamic>> getOrders({int page = 1, int limit = 20}) async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.ordersEndpoint}',
        queryParameters: {
          'page': page,
          'limit': limit,
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
  Future<dynamic> updateOrder(String orderId, Map<String, dynamic> updateData) async {
    try {
      final response = await dio.put(
        '${AppConstants.apiBaseUrl}${AppConstants.ordersEndpoint}/$orderId',
        data: updateData,
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
      final response = await dio.post(
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

  @override
  Future<dynamic> trackOrder(String orderId) async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.ordersEndpoint}/$orderId/track',
      );

      if (response.statusCode == 200) {
        return response.data['data'] ?? response.data;
      }
      throw Exception('Erreur lors du suivi');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<dynamic> downloadInvoice(String orderId) async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.ordersEndpoint}/$orderId/invoice',
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Erreur lors du téléchargement');
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
