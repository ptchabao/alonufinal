import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';

abstract class StudentRemoteDataSource {
  // POST /students
  Future<Map<String, dynamic>> createStudent(Map<String, dynamic> data);
  // GET /students/me
  Future<Map<String, dynamic>?> getMyStudentProfile();
  // PUT /students/{id}
  Future<Map<String, dynamic>> updateStudent(String studentId, Map<String, dynamic> data);
}

class StudentRemoteDataSourceImpl implements StudentRemoteDataSource {
  final Dio dio;

  StudentRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> createStudent(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        '${AppConstants.apiBaseUrl}${AppConstants.studentsEndpoint}',
        data: data,
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Erreur lors de la création du profil étudiant');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>?> getMyStudentProfile() async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.studentsEndpoint}/me',
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw _handleDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> updateStudent(String studentId, Map<String, dynamic> data) async {
    try {
      final response = await dio.put(
        '${AppConstants.apiBaseUrl}${AppConstants.studentsEndpoint}/$studentId',
        data: data,
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Erreur lors de la mise à jour du profil étudiant');
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
    if (e.response?.statusCode == 409) {
      return Exception('Un profil étudiant existe déjà');
    }
    if (e.response?.statusCode == 500) {
      return Exception('Erreur serveur');
    }
    return Exception(e.message ?? 'Erreur inconnue');
  }
}
