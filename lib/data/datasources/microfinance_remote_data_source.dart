import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';

/// Conforme à ALONU_API_Documentation.md — module Microfinance, partie
/// utilisateur uniquement (CRUD partenaire, export CSV et reporting sont
/// réservés à l'Admin, hors scope ici).
abstract class MicrofinanceRemoteDataSource {
  // GET /microfinance/partners — partenaires actifs pour un utilisateur normal
  Future<List<dynamic>> getPartners();

  // POST /microfinance/adhesions — adhésion de l'utilisateur connecté
  Future<Map<String, dynamic>> createAdhesion(String partnerId);
}

class MicrofinanceRemoteDataSourceImpl implements MicrofinanceRemoteDataSource {
  final Dio dio;

  MicrofinanceRemoteDataSourceImpl(this.dio);

  @override
  Future<List<dynamic>> getPartners() async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}/microfinance/partners',
      );
      return _extractList(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> createAdhesion(String partnerId) async {
    try {
      final response = await dio.post(
        '${AppConstants.apiBaseUrl}/microfinance/adhesions',
        data: {'partnerId': partnerId},
      );
      return _extractJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return List<dynamic>.from(data);
    if (data is Map && data['data'] is List) {
      return List<dynamic>.from(data['data']);
    }
    return const [];
  }

  Map<String, dynamic> _extractJson(dynamic data) {
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
      return Exception('Partenaire introuvable ou inactif');
    }
    if (e.response?.statusCode == 409) {
      return Exception('Vous avez déjà une adhésion pour ce partenaire');
    }
    if (e.response?.statusCode == 500) {
      return Exception('Erreur serveur');
    }
    return Exception(e.message ?? 'Erreur inconnue');
  }
}
