import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';

abstract class DonationRemoteDataSource {
  // POST /donations
  Future<Map<String, dynamic>> createDonation(Map<String, dynamic> data);
  // GET /donations/me
  Future<List<dynamic>> getMyDonations();
  // GET /donations/stats
  Future<Map<String, dynamic>> getDonationStats({String? recipientType, String? recipientId});
}

class DonationRemoteDataSourceImpl implements DonationRemoteDataSource {
  final Dio dio;

  DonationRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> createDonation(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        '${AppConstants.apiBaseUrl}${AppConstants.donationsEndpoint}',
        data: data,
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Erreur lors de la création du don');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<List<dynamic>> getMyDonations() async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.donationsEndpoint}/me',
      );
      if (response.statusCode == 200) {
        return List<dynamic>.from(response.data ?? []);
      }
      throw Exception('Erreur lors du chargement des dons');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getDonationStats({String? recipientType, String? recipientId}) async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.donationsEndpoint}/stats',
        queryParameters: {
          if (recipientType != null) 'recipientType': recipientType,
          if (recipientId != null) 'recipientId': recipientId,
        },
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Erreur lors du chargement des statistiques de dons');
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
    if (e.response?.statusCode == 401) {
      return Exception('Non authentifié');
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
