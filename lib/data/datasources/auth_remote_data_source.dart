import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../models/artisan_model.dart';
import '../../core/constants/app_constants.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String identifier, String password);
  Future<AuthResponseModel> register({
    required String username,
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required String telephone,
    required String role,
    required String countryId,
    String? referralCode,
    String? workshopLocation,
  });
  Future<List<CountryModel>> getCountries();
  Future<AuthResponseModel> refreshToken(String refreshToken);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<AuthResponseModel> login(String identifier, String password) async {
    try {
      // API expects 'username' field, not 'identifier'
      // identifier can be email or username, we'll try email first
      final requestData = {'username': identifier, 'password': password};

      final response = await dio.post(
        '${AppConstants.apiBaseUrl}${AppConstants.loginEndpoint}',
        data: requestData,
      );
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<AuthResponseModel> register({
    required String username,
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required String telephone,
    required String role,
    required String countryId,
    String? referralCode,
    String? workshopLocation,
  }) async {
    try {
      final response = await dio.post(
        '${AppConstants.apiBaseUrl}${AppConstants.registerEndpoint}',
        data: RegisterRequestModel(
          username: username,
          email: email,
          password: password,
          nom: nom,
          prenom: prenom,
          telephone: telephone,
          role: role,
          countryId: countryId,
          referralCode: referralCode,
          workshopLocation: workshopLocation,
        ).toJson(),
      );

      // Log server response for easier debugging
      try {
        debugPrint('>>> RESPONSE STATUS: ${response.statusCode}');
        debugPrint('>>> RESPONSE DATA: ${response.data}');
      } catch (_) {}

      return AuthResponseModel.fromJson(
        (response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<List<CountryModel>> getCountries() async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.countriesEndpoint}',
      );

      final responseData = response.data;
      List<dynamic> countriesData = [];

      if (responseData is List) {
        countriesData = responseData;
      } else if (responseData is Map) {
        if (responseData['data'] is List) {
          countriesData = responseData['data'] as List<dynamic>;
        } else if (responseData['countries'] is List) {
          countriesData = responseData['countries'] as List<dynamic>;
        } else if (responseData['items'] is List) {
          countriesData = responseData['items'] as List<dynamic>;
        }
      }

      return countriesData
          .whereType<Map>()
          .map(
            (country) =>
                CountryModel.fromJson(Map<String, dynamic>.from(country)),
          )
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    try {
      final response = await dio.post(
        '${AppConstants.apiBaseUrl}${AppConstants.refreshTokenEndpoint}',
        data: {'refreshToken': refreshToken},
      );
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await dio.post(
        '${AppConstants.apiBaseUrl}/auth/change-password',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.getUserEndpoint}',
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Exception _handleDioException(DioException e) {
    String errorMessage = 'Une erreur s\'est produite';

    if (e.response?.statusCode == 400) {
      // Try to get detailed error message from server
      final responseData = e.response?.data;
      if (responseData is Map) {
        errorMessage =
            responseData['message'] ??
            responseData['error'] ??
            'Données invalides';
      } else {
        errorMessage = 'Email/Username ou mot de passe invalides';
      }
    } else if (e.response?.statusCode == 401) {
      errorMessage = 'Identifiants invalides';
    } else if (e.response?.statusCode == 409) {
      errorMessage = 'Email ou username déjà utilisé';
    } else if (e.type == DioExceptionType.connectionTimeout) {
      errorMessage = 'Connexion expirée';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Délai d\'attente dépassé';
    }

    // Log the full error for debugging
    debugPrint('DioException: ${e.message}');
    debugPrint('Status Code: ${e.response?.statusCode}');
    debugPrint('Response Data: ${e.response?.data}');

    return Exception(errorMessage);
  }
}

abstract class AuthLocalDataSource {
  Future<void> saveTokens(String accessToken, String refreshToken);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearTokens();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _secureStorage.write(key: AppConstants.tokenKey, value: accessToken);
    await _secureStorage.write(
      key: AppConstants.refreshTokenKey,
      value: refreshToken,
    );
  }

  @override
  Future<String?> getAccessToken() async {
    return _secureStorage.read(key: AppConstants.tokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: AppConstants.refreshTokenKey);
  }

  @override
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await _secureStorage.write(
      key: AppConstants.userKey,
      value: jsonEncode(user.toJson()),
    );
  }

  @override
  Future<UserModel?> getUser() async {
    final storedUser = await _secureStorage.read(key: AppConstants.userKey);
    if (storedUser == null || storedUser.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(storedUser);
      return UserModel.fromJson(decoded as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    await _secureStorage.delete(key: AppConstants.userKey);
  }
}
