import 'package:dartz/dartz.dart';
import '../../core/errors/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, AuthToken>> call(String identifier, String password) {
    return repository.login(identifier, password);
  }
}

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, User>> call({
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
  }) {
    return repository.register(
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
  }
}

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.logout();
  }
}

class IsAuthenticatedUseCase {
  final AuthRepository repository;

  IsAuthenticatedUseCase(this.repository);

  Future<Either<Failure, bool>> call() {
    return repository.isAuthenticated();
  }
}

class GetCachedTokenUseCase {
  final AuthRepository repository;

  GetCachedTokenUseCase(this.repository);

  Future<Either<Failure, AuthToken?>> call() {
    return repository.getCachedToken();
  }
}

class ChangePasswordUseCase {
  final AuthRepository repository;

  ChangePasswordUseCase(this.repository);

  Future<Either<Failure, void>> call(
    String currentPassword,
    String newPassword,
  ) {
    return repository.changePassword(currentPassword, newPassword);
  }
}
