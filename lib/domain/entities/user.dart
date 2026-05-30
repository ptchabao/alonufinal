import 'package:equatable/equatable.dart';

enum UserRole { ADMIN, CLIENT, ARTISAN, STUDENT }

enum UserStatus { PENDING, ACTIVE, INACTIVE, BLOCKED }

class User extends Equatable {
  final String id;
  final String username;
  final String email;
  final String nom;
  final String prenom;
  final String telephone;
  final UserRole role;
  final UserStatus status;
  final String? avatar;
  final String? countryId;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.role,
    required this.status,
    this.avatar,
    this.countryId,
    required this.createdAt,
  });

  String get fullName => '$prenom $nom';

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    nom,
    prenom,
    telephone,
    role,
    status,
    avatar,
    countryId,
    createdAt,
  ];

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? nom,
    String? prenom,
    String? telephone,
    UserRole? role,
    UserStatus? status,
    String? avatar,
    String? countryId,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      telephone: telephone ?? this.telephone,
      role: role ?? this.role,
      status: status ?? this.status,
      avatar: avatar ?? this.avatar,
      countryId: countryId ?? this.countryId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AuthToken extends Equatable {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresAt];
}
