import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';

abstract class ReferralRemoteDataSource {
  // POST /referrals/generate
  Future<Map<String, dynamic>> generateCode();
  // POST /referrals/validate
  Future<Map<String, dynamic>> validateCode(String referralCode);
  // GET /referrals/me
  Future<List<dynamic>> getMyReferrals();
  // GET /referrals/stats
  Future<Map<String, dynamic>> getStats();
}

class ReferralRemoteDataSourceImpl implements ReferralRemoteDataSource {
  final Dio dio;

  ReferralRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> generateCode() async {
    try {
      final response = await dio.post(
        '${AppConstants.apiBaseUrl}${AppConstants.referralsEndpoint}/generate',
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Erreur lors de la génération du code de parrainage');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> validateCode(String referralCode) async {
    try {
      final response = await dio.post(
        '${AppConstants.apiBaseUrl}${AppConstants.referralsEndpoint}/validate',
        data: {'referralCode': referralCode},
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Code de parrainage invalide');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<List<dynamic>> getMyReferrals() async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.referralsEndpoint}/me',
      );
      if (response.statusCode == 200) {
        return List<dynamic>.from(response.data ?? []);
      }
      throw Exception('Erreur lors du chargement des parrainages');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.referralsEndpoint}/stats',
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Erreur lors du chargement des statistiques de parrainage');
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
    if (e.response?.statusCode == 400) {
      return Exception('Code invalide');
    }
    if (e.response?.statusCode == 401) {
      return Exception('Non authentifié');
    }
    if (e.response?.statusCode == 500) {
      return Exception('Erreur serveur');
    }
    return Exception(e.message ?? 'Erreur inconnue');
  }
}
