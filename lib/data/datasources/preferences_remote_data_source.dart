import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';

abstract class PreferencesRemoteDataSource {
  // GET /preferences
  Future<Map<String, dynamic>> getPreferences();
  // PUT /preferences
  Future<Map<String, dynamic>> updatePreferences(Map<String, dynamic> data);
  // POST /preferences/reset
  Future<Map<String, dynamic>> resetPreferences();
}

class PreferencesRemoteDataSourceImpl implements PreferencesRemoteDataSource {
  final Dio dio;

  PreferencesRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> getPreferences() async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.preferencesEndpoint}',
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Erreur lors du chargement des préférences');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> updatePreferences(Map<String, dynamic> data) async {
    try {
      final response = await dio.put(
        '${AppConstants.apiBaseUrl}${AppConstants.preferencesEndpoint}',
        data: data,
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Erreur lors de la mise à jour des préférences');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> resetPreferences() async {
    try {
      final response = await dio.post(
        '${AppConstants.apiBaseUrl}${AppConstants.preferencesEndpoint}/reset',
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Erreur lors de la réinitialisation des préférences');
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
    if (e.response?.statusCode == 500) {
      return Exception('Erreur serveur');
    }
    return Exception(e.message ?? 'Erreur inconnue');
  }
}
