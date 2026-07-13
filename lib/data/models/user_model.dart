import '../../core/constants/app_constants.dart';
import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.nom,
    required super.prenom,
    required super.telephone,
    required super.role,
    required super.status,
    super.avatar,
    super.countryId,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle missing, null or non-string payloads gracefully
    return UserModel(
      id: _parseString(json['id']) ?? '',
      username: _parseString(json['username']) ?? '',
      email: _parseString(json['email']) ?? '',
      nom: _parseString(json['nom']) ?? '',
      prenom: _parseString(json['prenom']) ?? '',
      telephone: _parseString(json['telephone']) ?? '',
      role: _parseRole(json['role']),
      status: _parseStatus(json['status']),
      avatar: AppConstants.resolveMediaUrl(_parseString(json['avatar'])),
      countryId: _parseString(json['countryId']),
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'username': username,
    'email': email,
    'nom': nom,
    'prenom': prenom,
    'telephone': telephone,
    'role': role.name,
    'status': status.name,
    'avatar': avatar,
    'countryId': countryId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      username: user.username,
      email: user.email,
      nom: user.nom,
      prenom: user.prenom,
      telephone: user.telephone,
      role: user.role,
      status: user.status,
      avatar: user.avatar,
      countryId: user.countryId,
      createdAt: user.createdAt,
    );
  }

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is List && value.isNotEmpty) {
      return value.first.toString();
    }
    return value.toString();
  }

  static UserRole _parseRole(dynamic value) {
    if (value == null) return UserRole.CLIENT;
    if (value is UserRole) return value;
    final roleStr = _parseString(value)?.toUpperCase() ?? '';
    return UserRole.values.firstWhere(
      (e) => e.name == roleStr,
      orElse: () => UserRole.CLIENT,
    );
  }

  static UserStatus _parseStatus(dynamic value) {
    if (value == null) return UserStatus.PENDING;
    if (value is UserStatus) return value;
    final statusStr = _parseString(value)?.toUpperCase() ?? '';
    return UserStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => UserStatus.PENDING,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }
}

class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final UserModel user;

  AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    // If expiresAt is missing, calculate it (24 hours from now)
    DateTime expiresAt;
    final expiresAtValue = json['expiresAt'];
    if (expiresAtValue is String) {
      expiresAt =
          DateTime.tryParse(expiresAtValue) ??
          DateTime.now().add(const Duration(hours: 24));
    } else {
      expiresAt = DateTime.now().add(const Duration(hours: 24));
    }

    final userData = json['user'];
    final userJson = userData is Map<String, dynamic>
        ? userData
        : (userData is Map
              ? Map<String, dynamic>.from(userData)
              : <String, dynamic>{});

    return AuthResponseModel(
      accessToken: UserModel._parseString(json['accessToken']) ?? '',
      refreshToken: UserModel._parseString(json['refreshToken']) ?? '',
      expiresAt: expiresAt,
      user: UserModel.fromJson(userJson),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresAt': expiresAt.toIso8601String(),
    'user': user.toJson(),
  };
}

class LoginRequestModel {
  final String identifier;
  final String password;
  final bool? rememberMe;

  LoginRequestModel({
    required this.identifier,
    required this.password,
    this.rememberMe,
  });

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) {
    return LoginRequestModel(
      identifier: json['identifier'] as String? ?? '',
      password: json['password'] as String? ?? '',
      rememberMe: json['rememberMe'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'identifier': identifier,
    'password': password,
    'rememberMe': rememberMe,
  };
}

class RegisterRequestModel {
  final String username;
  final String email;
  final String password;
  final String nom;
  final String prenom;
  final String telephone;
  final String role;
  final String countryId;
  final String? referralCode;
  final String? workshopLocation;

  RegisterRequestModel({
    required this.username,
    required this.email,
    required this.password,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.role,
    required this.countryId,
    this.referralCode,
    this.workshopLocation,
  });

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) {
    return RegisterRequestModel(
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      telephone: json['telephone'] as String? ?? '',
      role: json['role'] as String? ?? '',
      countryId: json['countryId'] as String? ?? '',
      referralCode: json['referralCode'] as String?,
      workshopLocation: json['workshopLocation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'username': username,
      'email': email,
      'password': password,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'role': role,
      'countryId': countryId,
    };

    if (referralCode != null && referralCode!.isNotEmpty) {
      data['referralCode'] = referralCode;
    }

    // The auth/register endpoint does not accept a workshopLocation property.
    // Location is handled later in the artisan profile flow.
    return data;
  }
}
