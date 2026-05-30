import 'package:riverpod/riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../core/service_locator.dart';

// Auth State Notifier
class AuthState {
  final bool isAuthenticated;
  final User? user;
  final String? error;
  final bool isLoading;

  AuthState({
    this.isAuthenticated = false,
    this.user,
    this.error,
    this.isLoading = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    String? error,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    checkAuthentication();
  }

  Future<bool> login(String identifier, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await getIt<LoginUseCase>().call(identifier, password);
    return await result.fold(
      (failure) async {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          isAuthenticated: false,
        );
        return false;
      },
      (token) async {
        // Get user from API with the new token
        final userResult = await getIt<UserRepository>().getCurrentUser();
        return userResult.fold(
          (_) {
            // If getting user fails, login still succeeded but we don't have user data
            // This is acceptable for token-based auth
            state = state.copyWith(
              isLoading: false,
              isAuthenticated: true,
              error: null,
              user: null,
            );
            return true;
          },
          (user) {
            state = state.copyWith(
              isLoading: false,
              isAuthenticated: true,
              error: null,
              user: user,
            );
            return true;
          },
        );
      },
    );
  }

  Future<bool> register({
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
    state = state.copyWith(isLoading: true, error: null);

    final result = await getIt<RegisterUseCase>().call(
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

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(isLoading: false, error: null, user: user);
        return true;
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    final result = await getIt<LogoutUseCase>().call();

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (_) {
        state = AuthState();
      },
    );
  }

  Future<void> checkAuthentication() async {
    final result = await getIt<IsAuthenticatedUseCase>().call();

    await result.fold(
      (failure) async {
        state = state.copyWith(isAuthenticated: false);
      },
      (isAuth) async {
        if (!isAuth) {
          state = state.copyWith(isAuthenticated: false);
          return;
        }

        final userResult = await getIt<UserRepository>().getCurrentUser();
        userResult.fold(
          (_) => state = state.copyWith(isAuthenticated: true),
          (user) => state = state.copyWith(isAuthenticated: true, user: user),
        );
      },
    );
  }

  void setError(String error) {
    state = state.copyWith(error: error);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Riverpod Providers
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});
