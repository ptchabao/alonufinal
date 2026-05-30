import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final FlutterSecureStorage secureStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.secureStorage,
  });

  @override
  Future<Either<Failure, AuthToken>> login(
    String identifier,
    String password,
  ) async {
    try {
      final result = await remoteDataSource.login(identifier, password);

      await secureStorage.write(
        key: AppConstants.tokenKey,
        value: result.accessToken,
      );
      await secureStorage.write(
        key: AppConstants.refreshTokenKey,
        value: result.refreshToken,
      );
      await localDataSource.saveUser(result.user);

      final authToken = AuthToken(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        expiresAt: result.expiresAt,
      );

      return Right(authToken);
    } catch (e) {
      // NEVER use offline mode for authentication errors - security critical!
      // 400 = bad credentials, 401 = unauthorized, 409 = conflict
      if (e is DioException &&
          (e.response?.statusCode == 400 ||
              e.response?.statusCode == 401 ||
              e.response?.statusCode == 409)) {
        return Left(_mapExceptionToFailure(e));
      }

      // Only use offline mode for network errors, NOT authentication failures
      if (AppConstants.enableOfflineMode &&
          e is DioException &&
          (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.connectionError)) {
        // Could implement proper offline login here with stored credentials
        return Left(NetworkFailure(message: 'Pas de connexion internet'));
      }

      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, User>> register({
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
      final result = await remoteDataSource.register(
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
      );

      await secureStorage.write(
        key: AppConstants.tokenKey,
        value: result.accessToken,
      );
      await secureStorage.write(
        key: AppConstants.refreshTokenKey,
        value: result.refreshToken,
      );
      await localDataSource.saveUser(result.user);

      return Right(result.user);
    } catch (e) {
      // NEVER use offline mode for registration - security critical!
      // 400 = validation error, 409 = email/username already exists
      if (e is DioException &&
          (e.response?.statusCode == 400 || e.response?.statusCode == 409)) {
        return Left(_mapExceptionToFailure(e));
      }

      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, AuthToken>> refreshToken(String refreshToken) async {
    try {
      final result = await remoteDataSource.refreshToken(refreshToken);

      await secureStorage.write(
        key: AppConstants.tokenKey,
        value: result.accessToken,
      );
      await secureStorage.write(
        key: AppConstants.refreshTokenKey,
        value: result.refreshToken,
      );

      final authToken = AuthToken(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        expiresAt: result.expiresAt,
      );

      return Right(authToken);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await secureStorage.delete(key: AppConstants.tokenKey);
      await secureStorage.delete(key: AppConstants.refreshTokenKey);
      return Right(null);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await remoteDataSource.changePassword(currentPassword, newPassword);
      return Right(null);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final token = await secureStorage.read(key: AppConstants.tokenKey);
      return Right(token != null);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, AuthToken?>> getCachedToken() async {
    try {
      final token = await secureStorage.read(key: AppConstants.tokenKey);
      final refreshToken = await secureStorage.read(
        key: AppConstants.refreshTokenKey,
      );

      if (token == null || refreshToken == null) {
        return Right(null);
      }

      return Right(
        AuthToken(
          accessToken: token,
          refreshToken: refreshToken,
          expiresAt: DateTime.now().add(
            const Duration(hours: 1),
          ), // Approximate
        ),
      );
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }
}

Failure _mapExceptionToFailure(dynamic exception) {
  if (exception is AuthenticationFailure) {
    return exception;
  }
  if (exception is NetworkFailure) {
    return exception;
  }
  if (exception is ServerFailure) {
    return exception;
  }
  if (exception is DioException) {
    if (exception.response?.statusCode == 401) {
      return AuthenticationFailure(
        message: 'Identifiants invalides',
        originalError: exception,
      );
    }
    if (exception.response?.statusCode == 400) {
      final responseData = exception.response?.data;
      String message = 'Données invalides';
      if (responseData is Map) {
        message = responseData['message'] ?? responseData['error'] ?? message;
      }
      return ServerFailure(
        message: message,
        statusCode: 400,
        originalError: exception,
      );
    }
    if (exception.response?.statusCode == 409) {
      return ServerFailure(
        message: 'Email ou username déjà utilisé',
        statusCode: 409,
        originalError: exception,
      );
    }
    if (exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.receiveTimeout ||
        exception.type == DioExceptionType.connectionError) {
      return NetworkFailure(
        message: 'Connexion perdue',
        originalError: exception,
      );
    }
  }
  return ServerFailure(message: exception.toString(), originalError: exception);
}

class UserRepositoryImpl implements UserRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // First try to get user from API
      final user = await remoteDataSource.getCurrentUser();
      // Also save to local storage
      await localDataSource.saveUser(user);
      return Right(user);
    } catch (e) {
      // If API fails, try local storage as fallback
      try {
        final user = await localDataSource.getUser();
        if (user == null) {
          return Left(ServerFailure(message: 'Utilisateur introuvable'));
        }
        return Right(user);
      } catch (_) {
        return Left(_mapExceptionToFailure(e));
      }
    }
  }

  @override
  Future<Either<Failure, User>> updateUser(User user) async {
    try {
      await localDataSource.saveUser(UserModel.fromEntity(user));
      return Right(user);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, bool>> checkEmailExists(String email) async {
    try {
      final user = await localDataSource.getUser();
      if (user == null) return const Right(false);
      return Right(user.email.toLowerCase() == email.toLowerCase());
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, bool>> checkUsernameExists(String username) async {
    try {
      final user = await localDataSource.getUser();
      if (user == null) return const Right(false);
      return Right(user.username.toLowerCase() == username.toLowerCase());
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, bool>> checkPhoneExists(String phone) async {
    try {
      final user = await localDataSource.getUser();
      if (user == null) return const Right(false);
      return Right(user.telephone == phone);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }
}
