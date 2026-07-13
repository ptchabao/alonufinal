import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/artisan.dart';

class CountryModel extends Equatable {
  final String id;
  final String code;
  final String name;
  final String nameFr;
  final String flagEmoji;
  final String? flagImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CountryModel({
    required this.id,
    required this.code,
    required this.name,
    required this.nameFr,
    required this.flagEmoji,
    this.flagImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameFr: json['nameFr'] as String? ?? '',
      flagEmoji: json['flagEmoji'] as String? ?? '',
      flagImageUrl: json['flagImageUrl'] as String?,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'nameFr': nameFr,
    'flagEmoji': flagEmoji,
    'flagImageUrl': flagImageUrl,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  @override
  List<Object?> get props =>
      [id, code, name, nameFr, flagEmoji, flagImageUrl, createdAt, updatedAt];
}

class ArtisanUserModel extends Equatable {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String? avatar;
  final CountryModel country;

  const ArtisanUserModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    this.avatar,
    required this.country,
  });

  factory ArtisanUserModel.fromJson(Map<String, dynamic> json) {
    return ArtisanUserModel(
      id: json['id'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      email: json['email'] as String? ?? '',
      telephone: json['telephone'] as String? ?? '',
      avatar: AppConstants.resolveMediaUrl(json['avatar'] as String?),
      country: CountryModel.fromJson(
          json['country'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'prenom': prenom,
    'email': email,
    'telephone': telephone,
    'avatar': avatar,
    'country': country.toJson(),
  };

  @override
  List<Object?> get props =>
      [id, nom, prenom, email, telephone, avatar, country];
}

class SubCategoryModel extends Equatable {
  final String id;
  final String categoryId;
  final String libelle;
  final String libelleFr;
  final String? libelleEn;
  final String? description;
  final String? image;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final CategoryModel? category;

  const SubCategoryModel({
    required this.id,
    required this.categoryId,
    required this.libelle,
    required this.libelleFr,
    this.libelleEn,
    this.description,
    this.image,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.category,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      libelle: json['libelle'] as String? ?? '',
      libelleFr: json['libelleFr'] as String? ?? '',
      libelleEn: json['libelleEn'] as String?,
      description: json['description'] as String?,
      image: AppConstants.resolveMediaUrl(json['image'] as String?),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'categoryId': categoryId,
    'libelle': libelle,
    'libelleFr': libelleFr,
    'libelleEn': libelleEn,
    'description': description,
    'image': image,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'deletedAt': deletedAt?.toIso8601String(),
    'category': category?.toJson(),
  };

  @override
  List<Object?> get props => [
    id,
    categoryId,
    libelle,
    libelleFr,
    libelleEn,
    description,
    image,
    createdAt,
    updatedAt,
    deletedAt,
    category,
  ];
}

class ArtisanSubCategoryModel extends Equatable {
  final String id;
  final String artisanId;
  final String subCategoryId;
  final DateTime createdAt;
  final SubCategoryModel subCategory;

  const ArtisanSubCategoryModel({
    required this.id,
    required this.artisanId,
    required this.subCategoryId,
    required this.createdAt,
    required this.subCategory,
  });

  factory ArtisanSubCategoryModel.fromJson(Map<String, dynamic> json) {
    return ArtisanSubCategoryModel(
      id: json['id'] as String? ?? '',
      artisanId: json['artisanId'] as String? ?? '',
      subCategoryId: json['subCategoryId'] as String? ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      subCategory: SubCategoryModel.fromJson(
          json['subCategory'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'artisanId': artisanId,
    'subCategoryId': subCategoryId,
    'createdAt': createdAt.toIso8601String(),
    'subCategory': subCategory.toJson(),
  };

  @override
  List<Object?> get props =>
      [id, artisanId, subCategoryId, createdAt, subCategory];
}

class ArtisanModel extends Equatable {
  final String id;
  final String userId;
  final String numeroEnr;
  final String telephone;
  final String? adresse;
  final double? latitude;
  final double? longitude;
  final String countryId;
  final String? facebook;
  final String? whatsapp;
  final String? twitter;
  final String? instagram;
  final bool actif;
  final bool subscriptionPaid;
  final DateTime? subscriptionExpiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final ArtisanUserModel user;
  final CountryModel country;
  final List<ArtisanSubCategoryModel> subCategories;
  final double? distance;

  const ArtisanModel({
    required this.id,
    required this.userId,
    required this.numeroEnr,
    required this.telephone,
    this.adresse,
    this.latitude,
    this.longitude,
    required this.countryId,
    this.facebook,
    this.whatsapp,
    this.twitter,
    this.instagram,
    required this.actif,
    required this.subscriptionPaid,
    this.subscriptionExpiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.user,
    required this.country,
    required this.subCategories,
    this.distance,
  });

  factory ArtisanModel.fromJson(Map<String, dynamic> json) {
    return ArtisanModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      numeroEnr: json['numeroEnr'] as String? ?? '',
      telephone: json['telephone'] as String? ?? '',
      adresse: json['adresse'] as String?,
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      countryId: json['countryId'] as String? ?? '',
      facebook: json['facebook'] as String?,
      whatsapp: json['whatsapp'] as String?,
      twitter: json['twitter'] as String?,
      instagram: json['instagram'] as String?,
      actif: json['actif'] as bool? ?? false,
      subscriptionPaid: json['subscriptionPaid'] as bool? ?? false,
      subscriptionExpiresAt: json['subscriptionExpiresAt'] != null
          ? DateTime.parse(json['subscriptionExpiresAt'] as String)
          : null,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
      user: ArtisanUserModel.fromJson(
          json['user'] as Map<String, dynamic>? ?? {}),
      country: CountryModel.fromJson(
          json['country'] as Map<String, dynamic>? ?? {}),
      subCategories: (json['subCategories'] as List<dynamic>?)
          ?.map((e) =>
              ArtisanSubCategoryModel.fromJson(
                  e as Map<String, dynamic>))
          .toList() ??
          [],
      distance: json['distance'] != null
          ? double.tryParse(json['distance'].toString())
          : (json['distanceKm'] != null
              ? double.tryParse(json['distanceKm'].toString())
              : null),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'numeroEnr': numeroEnr,
    'telephone': telephone,
    'adresse': adresse,
    'latitude': latitude,
    'longitude': longitude,
    'countryId': countryId,
    'facebook': facebook,
    'whatsapp': whatsapp,
    'twitter': twitter,
    'instagram': instagram,
    'actif': actif,
    'subscriptionPaid': subscriptionPaid,
    'subscriptionExpiresAt': subscriptionExpiresAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'deletedAt': deletedAt?.toIso8601String(),
    'user': user.toJson(),
    'country': country.toJson(),
    'subCategories': subCategories.map((e) => e.toJson()).toList(),
    'distance': distance,
  };

  Artisan toEntity() {
  return Artisan(
    id: id,
    userId: userId,
    numeroEnr: numeroEnr,
    telephone: telephone,
    adresse: adresse,
    latitude: latitude,
    longitude: longitude,
    countryId: countryId,
    facebook: facebook,
    whatsapp: whatsapp,
    twitter: twitter,
    instagram: instagram,
    actif: actif,
    distance: distance,
    user: ArtisanUser(
      id: user.id,
      nom: user.nom,
      prenom: user.prenom,
      email: user.email,
      telephone: user.telephone,
      avatar: user.avatar,
    ),
    subCategories: subCategories.map((sc) {
      return ArtisanSubCategory(
        id: sc.id,
        artisanId: sc.artisanId,
        subCategoryId: sc.subCategoryId,
        subCategory: ArtisanSubCategoryItem(
          id: sc.subCategory.id,
          libelle: sc.subCategory.libelle,
          libelleFr: sc.subCategory.libelleFr,
          libelleEn: sc.subCategory.libelleEn,
          categoryId: sc.subCategory.categoryId,
          categoryLibelleFr: sc.subCategory.category?.libelleFr ?? '',
        ),
      );
    }).toList(),
    apprenticeCount: null,
  );
}

  @override
  List<Object?> get props => [
    id,
    userId,
    numeroEnr,
    telephone,
    adresse,
    latitude,
    longitude,
    countryId,
    facebook,
    whatsapp,
    twitter,
    instagram,
    actif,
    subscriptionPaid,
    subscriptionExpiresAt,
    createdAt,
    updatedAt,
    deletedAt,
    user,
    country,
    subCategories,
    distance,
  ];
}

class CategoryModel extends Equatable {
  final String id;
  final String libelle;
  final String libelleFr;
  final String? libelleEn;
  final String? description;
  final String? image;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final List<SubCategoryModel> subCategories;

  const CategoryModel({
    required this.id,
    required this.libelle,
    required this.libelleFr,
    this.libelleEn,
    this.description,
    this.image,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.subCategories,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String? ?? '',
      libelle: json['libelle'] as String? ?? '',
      libelleFr: json['libelleFr'] as String? ?? '',
      libelleEn: json['libelleEn'] as String?,
      description: json['description'] as String?,
      image: AppConstants.resolveMediaUrl(json['image'] as String?),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
      subCategories: (json['subCategories'] as List<dynamic>?)
          ?.map((e) =>
              SubCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'libelle': libelle,
    'libelleFr': libelleFr,
    'libelleEn': libelleEn,
    'description': description,
    'image': image,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'deletedAt': deletedAt?.toIso8601String(),
    'subCategories': subCategories.map((e) => e.toJson()).toList(),
  };

  @override
  List<Object?> get props => [
    id,
    libelle,
    libelleFr,
    libelleEn,
    description,
    image,
    createdAt,
    updatedAt,
    deletedAt,
    subCategories,
  ];
}

class RealisationModel extends Equatable {
  final String id;
  final String artisanId;
  final String libelle;
  final String? description;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RealisationModel({
    required this.id,
    required this.artisanId,
    required this.libelle,
    this.description,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RealisationModel.fromJson(Map<String, dynamic> json) {
    return RealisationModel(
      id: json['id'] as String? ?? '',
      artisanId: json['artisanId'] as String? ?? '',
      libelle: json['libelle'] as String? ?? '',
      description: json['description'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => AppConstants.resolveMediaUrl(e.toString()) ?? '')
              .toList() ??
          [],
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'artisanId': artisanId,
    'libelle': libelle,
    'description': description,
    'images': images,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  Realisation toEntity() => Realisation(
    id: id,
    artisanId: artisanId,
    title: libelle,
    description: description,
    imageUrls: images,
    createdAt: createdAt,
  );

  @override
  List<Object?> get props =>
      [id, artisanId, libelle, description, images, createdAt, updatedAt];
}

DateTime _parseDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  if (value is String) {
    try {
      return DateTime.parse(value);
    } catch (e) {
      return DateTime.now();
    }
  }
  return DateTime.now();
}
