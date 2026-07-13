import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';

abstract class DashboardRemoteDataSource {
  // GET /dashboard/artisan
  Future<Map<String, dynamic>> getMyArtisanDashboard();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio dio;

  DashboardRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> getMyArtisanDashboard() async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.dashboardEndpoint}/artisan',
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Erreur lors du chargement du dashboard');
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
      return Exception('Profil artisan introuvable');
    }
    if (e.response?.statusCode == 500) {
      return Exception('Erreur serveur');
    }
    return Exception(e.message ?? 'Erreur inconnue');
  }
}
