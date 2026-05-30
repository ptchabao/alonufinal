import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final int artisanCount;

  Category({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.artisanCount,
  });

  @override
  List<Object?> get props => [id, name, imageUrl, artisanCount];
}

class SubCategory extends Equatable {
  final String id;
  final String categoryId;
  final String name;
  final String? imageUrl;
  final int artisanCount;

  SubCategory({
    required this.id,
    required this.categoryId,
    required this.name,
    this.imageUrl,
    required this.artisanCount,
  });

  @override
  List<Object?> get props => [id, categoryId, name, imageUrl, artisanCount];
}

// Utilisateur imbriqué dans Artisan
class ArtisanUser extends Equatable {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String? avatar;

  ArtisanUser({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    this.avatar,
  });

  @override
  List<Object?> get props => [id, nom, prenom, email, telephone, avatar];
}

// Sous-catégorie imbriquée dans ArtisanSubCategory
class ArtisanSubCategoryItem extends Equatable {
  final String id;
  final String libelle;
  final String libelleFr;
  final String? libelleEn;
  final String categoryId;
  final String categoryLibelleFr;

  ArtisanSubCategoryItem({
    required this.id,
    required this.libelle,
    required this.libelleFr,
    this.libelleEn,
    required this.categoryId,
    required this.categoryLibelleFr,
  });

  @override
  List<Object?> get props =>
      [id, libelle, libelleFr, libelleEn, categoryId, categoryLibelleFr];
}

// Wrapper artisan <-> sous-catégorie
class ArtisanSubCategory extends Equatable {
  final String id;
  final String artisanId;
  final String subCategoryId;
  final ArtisanSubCategoryItem subCategory;

  ArtisanSubCategory({
    required this.id,
    required this.artisanId,
    required this.subCategoryId,
    required this.subCategory,
  });

  @override
  List<Object?> get props => [id, artisanId, subCategoryId, subCategory];
}

enum ArtisanStatus { PENDING, ACTIVE, INACTIVE, BLOCKED }

class Artisan extends Equatable {
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
  final double? distance;
  final ArtisanUser user;
  final List<ArtisanSubCategory> subCategories;
  final ArtisanStatus status;
  final int? apprenticeCount;

  Artisan({
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
    this.distance,
    required this.user,
    required this.subCategories,
    this.status = ArtisanStatus.PENDING,
    this.apprenticeCount,
  });

  @override
  List<Object?> get props => [
        id, userId, numeroEnr, telephone, adresse,
        latitude, longitude, countryId, facebook,
        whatsapp, twitter, instagram, actif,
        distance, user, subCategories, status, apprenticeCount,
      ];
}

enum ProductType { PRODUCT, SERVICE }

class Product extends Equatable {
  final String id;
  final String artisanId;
  final String title;
  final String? description;
  final double price;
  final String currency;
  final ProductType type;
  final bool active;
  final List<String> imageUrls;
  final int views;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.artisanId,
    required this.title,
    this.description,
    required this.price,
    required this.currency,
    required this.type,
    required this.active,
    required this.imageUrls,
    required this.views,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id, artisanId, title, description, price,
        currency, type, active, imageUrls, views, createdAt,
      ];
}

class Realisation extends Equatable {
  final String id;
  final String artisanId;
  final String title;
  final String? description;
  final List<String> imageUrls;
  final DateTime createdAt;

  Realisation({
    required this.id,
    required this.artisanId,
    required this.title,
    this.description,
    required this.imageUrls,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, artisanId, title, description, imageUrls, createdAt];
}