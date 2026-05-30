import 'package:dartz/dartz.dart';
import '../../core/errors/failure.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthToken>> login(String identifier, String password);
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
  });
  Future<Either<Failure, AuthToken>> refreshToken(String refreshToken);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> changePassword(
    String currentPassword,
    String newPassword,
  );
  Future<Either<Failure, bool>> isAuthenticated();
  Future<Either<Failure, AuthToken?>> getCachedToken();
}

abstract class UserRepository {
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, User>> updateUser(User user);
  Future<Either<Failure, bool>> checkEmailExists(String email);
  Future<Either<Failure, bool>> checkUsernameExists(String username);
  Future<Either<Failure, bool>> checkPhoneExists(String phone);
}
