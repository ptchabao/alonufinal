import 'dart:math';

import 'package:dartz/dartz.dart';

import '../../core/errors/failure.dart';
import '../../domain/entities/artisan.dart';
import '../../domain/repositories/artisan_repository.dart';

// Helpers pour construire des ArtisanUser et ArtisanSubCategory mock
ArtisanUser _mockUser({
  required String id,
  required String nom,
  required String prenom,
  String? avatar,
}) {
  return ArtisanUser(
    id: id,
    nom: nom,
    prenom: prenom,
    email: '$id@alonu.com',
    telephone: '+228 90 000 000',
    avatar: avatar,
  );
}

ArtisanSubCategory _mockSubCat({
  required String id,
  required String artisanId,
  required String subCategoryId,
  required String libelle,
  required String categoryId,
  required String categoryLibelle,
}) {
  return ArtisanSubCategory(
    id: '${artisanId}_$subCategoryId',
    artisanId: artisanId,
    subCategoryId: subCategoryId,
    subCategory: ArtisanSubCategoryItem(
      id: subCategoryId,
      libelle: libelle,
      libelleFr: libelle,
      categoryId: categoryId,
      categoryLibelleFr: categoryLibelle,
    ),
  );
}

class ArtisanRepositoryImpl implements ArtisanRepository {
  final List<Category> _categories = [
    Category(id: 'cat1', name: 'Plomberie', imageUrl: null, artisanCount: 18),
    Category(id: 'cat2', name: 'Menuiserie', imageUrl: null, artisanCount: 12),
    Category(id: 'cat3', name: 'Électricité', imageUrl: null, artisanCount: 25),
    Category(id: 'cat4', name: 'Maçonnerie', imageUrl: null, artisanCount: 14),
    Category(id: 'cat5', name: 'Peinture', imageUrl: null, artisanCount: 10),
    Category(id: 'cat6', name: 'Couture', imageUrl: null, artisanCount: 9),
  ];

  final List<SubCategory> _subCategories = [
    SubCategory(id: 'sub1', categoryId: 'cat1', name: 'Réparation de fuites', imageUrl: null, artisanCount: 8),
    SubCategory(id: 'sub2', categoryId: 'cat1', name: 'Installation sanitaire', imageUrl: null, artisanCount: 6),
    SubCategory(id: 'sub3', categoryId: 'cat2', name: 'Mobilier sur mesure', imageUrl: null, artisanCount: 7),
    SubCategory(id: 'sub4', categoryId: 'cat3', name: 'Installation électrique', imageUrl: null, artisanCount: 12),
    SubCategory(id: 'sub5', categoryId: 'cat4', name: 'Fondations & murs', imageUrl: null, artisanCount: 10),
    SubCategory(id: 'sub6', categoryId: 'cat5', name: 'Revêtement & peinture', imageUrl: null, artisanCount: 5),
    SubCategory(id: 'sub7', categoryId: 'cat6', name: 'Retouches couture', imageUrl: null, artisanCount: 4),
  ];

  final List<Artisan> _artisans = [
    Artisan(
      id: 'artisan1',
      userId: 'user1',
      numeroEnr: 'PL-001',
      telephone: '+228 90 000 001',
      adresse: 'Lomé, Togo',
      latitude: 6.1725,
      longitude: 1.2314,
      countryId: 'TG',
      actif: true,
      status: ArtisanStatus.ACTIVE,
      apprenticeCount: 2,
      user: _mockUser(id: 'user1', nom: 'Kofi', prenom: 'Amédé'),
      subCategories: [
        _mockSubCat(
          id: 'artisan1_sub1',
          artisanId: 'artisan1',
          subCategoryId: 'sub1',
          libelle: 'Réparation de fuites',
          categoryId: 'cat1',
          categoryLibelle: 'Plomberie',
        ),
        _mockSubCat(
          id: 'artisan1_sub4',
          artisanId: 'artisan1',
          subCategoryId: 'sub4',
          libelle: 'Installation électrique',
          categoryId: 'cat3',
          categoryLibelle: 'Électricité',
        ),
      ],
    ),
    Artisan(
      id: 'artisan2',
      userId: 'user2',
      numeroEnr: 'ME-002',
      telephone: '+228 90 000 002',
      adresse: 'Kara, Togo',
      latitude: 9.5511,
      longitude: 1.1840,
      countryId: 'TG',
      actif: true,
      status: ArtisanStatus.ACTIVE,
      apprenticeCount: 1,
      user: _mockUser(id: 'user2', nom: 'Atchou', prenom: 'Kossi'),
      subCategories: [
        _mockSubCat(
          id: 'artisan2_sub3',
          artisanId: 'artisan2',
          subCategoryId: 'sub3',
          libelle: 'Mobilier sur mesure',
          categoryId: 'cat2',
          categoryLibelle: 'Menuiserie',
        ),
        _mockSubCat(
          id: 'artisan2_sub5',
          artisanId: 'artisan2',
          subCategoryId: 'sub5',
          libelle: 'Fondations & murs',
          categoryId: 'cat4',
          categoryLibelle: 'Maçonnerie',
        ),
      ],
    ),
    Artisan(
      id: 'artisan3',
      userId: 'user3',
      numeroEnr: 'EL-003',
      telephone: '+228 90 000 003',
      adresse: 'Aného, Togo',
      latitude: 6.2028,
      longitude: 1.6136,
      countryId: 'TG',
      actif: true,
      status: ArtisanStatus.ACTIVE,
      apprenticeCount: 0,
      user: _mockUser(id: 'user3', nom: 'Agbéko', prenom: 'Mawuli'),
      subCategories: [
        _mockSubCat(
          id: 'artisan3_sub4',
          artisanId: 'artisan3',
          subCategoryId: 'sub4',
          libelle: 'Installation électrique',
          categoryId: 'cat3',
          categoryLibelle: 'Électricité',
        ),
      ],
    ),
    Artisan(
      id: 'artisan4',
      userId: 'user4',
      numeroEnr: 'MA-004',
      telephone: '+228 90 000 004',
      adresse: 'Sokodé, Togo',
      latitude: 8.9824,
      longitude: 1.1338,
      countryId: 'TG',
      actif: true,
      status: ArtisanStatus.ACTIVE,
      apprenticeCount: 3,
      user: _mockUser(id: 'user4', nom: 'Dossou', prenom: 'Koffi'),
      subCategories: [
        _mockSubCat(
          id: 'artisan4_sub5',
          artisanId: 'artisan4',
          subCategoryId: 'sub5',
          libelle: 'Fondations & murs',
          categoryId: 'cat4',
          categoryLibelle: 'Maçonnerie',
        ),
        _mockSubCat(
          id: 'artisan4_sub6',
          artisanId: 'artisan4',
          subCategoryId: 'sub6',
          libelle: 'Revêtement & peinture',
          categoryId: 'cat5',
          categoryLibelle: 'Peinture',
        ),
      ],
    ),
  ];

  final List<Realisation> _realisations = [
    Realisation(
      id: 'real1',
      artisanId: 'artisan1',
      title: 'Réparation cuisine',
      description: 'Installation de plomberie et finitions.',
      imageUrls: [],
      createdAt: DateTime.now().subtract(const Duration(days: 18)),
    ),
  ];

  @override
  Future<Either<Failure, Realisation>> addRealisation(
      String artisanId, Realisation realisation) async {
    try {
      _artisans.firstWhere((item) => item.id == artisanId);
      _realisations.add(realisation);
      return Right(realisation);
    } catch (_) {
      return Left(NotFoundFailure(
          message: 'Artisan introuvable pour ajouter une réalisation.'));
    }
  }

  @override
  Future<Either<Failure, List<SubCategory>>> getSubcategories(
      String categoryId) async {
    final subcategories =
        _subCategories.where((sub) => sub.categoryId == categoryId).toList();
    return Right(subcategories);
  }

  @override
  Future<Either<Failure, Artisan>> createArtisan(Artisan artisan) async {
    _artisans.add(artisan);
    return Right(artisan);
  }

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    return Right(_categories);
  }

  @override
  Future<Either<Failure, Artisan>> getArtisan(String artisanId) async {
    try {
      final artisan = _artisans.firstWhere((item) => item.id == artisanId);
      return Right(artisan);
    } catch (_) {
      return Left(NotFoundFailure(message: 'Artisan introuvable.'));
    }
  }

  @override
  Future<Either<Failure, List<Artisan>>> getArtisansNearby({
    required double latitude,
    required double longitude,
    required double distanceKm,
    String? categoryId,
    String? subCategoryId,
  }) async {
    final artisans = _artisans.where((artisan) {
      // Distance : utilise les coordonnées si disponibles, sinon inclut l'artisan
      final double? artLat = artisan.latitude;
      final double? artLon = artisan.longitude;
      final bool withinDistance = (artLat != null && artLon != null)
          ? _calculateDistance(latitude, longitude, artLat, artLon) <= distanceKm
          : true;

      // Filtre par catégorie via subCategories imbriquées
      final bool matchesCategory = categoryId == null ||
          artisan.subCategories.any(
            (sc) => sc.subCategory.categoryId == categoryId,
          );

      // Filtre par sous-catégorie
      final bool matchesSubcategory = subCategoryId == null ||
          artisan.subCategories.any(
            (sc) => sc.subCategoryId == subCategoryId,
          );

      return withinDistance && matchesCategory && matchesSubcategory;
    }).toList();

    return Right(artisans);
  }

  @override
  Future<Either<Failure, List<Realisation>>> getRealisations(
      String artisanId) async {
    final result =
        _realisations.where((item) => item.artisanId == artisanId).toList();
    return Right(result);
  }

  @override
  Future<Either<Failure, Artisan>> updateArtisan(Artisan artisan) async {
    final index = _artisans.indexWhere((item) => item.id == artisan.id);
    if (index < 0) {
      return Left(NotFoundFailure(
          message: 'Artisan introuvable pour mise à jour.'));
    }
    _artisans[index] = artisan;
    return Right(artisan);
  }

  @override
  Future<Either<Failure, void>> deleteRealisation(
      String artisanId, String realisationId) async {
    _realisations.removeWhere(
        (item) => item.id == realisationId && item.artisanId == artisanId);
    return const Right(null);
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371;
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) => degrees * pi / 180;
}

class ProductRepositoryImpl implements ProductRepository {
  final List<Product> _products = [
    Product(
      id: 'prod1',
      artisanId: 'artisan1',
      title: 'Réparation de robinet',
      description: 'Remplacement et étanchéité de robinetterie.',
      price: 2500,
      currency: 'XOF',
      type: ProductType.SERVICE,
      active: true,
      imageUrls: [],
      views: 24,
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    Product(
      id: 'prod2',
      artisanId: 'artisan2',
      title: 'Table sur mesure',
      description: 'Table en bois massif adaptée à votre espace.',
      price: 12000,
      currency: 'XOF',
      type: ProductType.PRODUCT,
      active: true,
      imageUrls: [],
      views: 40,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    Product(
      id: 'prod3',
      artisanId: 'artisan3',
      title: 'Installation électrique',
      description: 'Câblage complet et sécurisation.',
      price: 18000,
      currency: 'XOF',
      type: ProductType.SERVICE,
      active: true,
      imageUrls: [],
      views: 35,
      createdAt: DateTime.now().subtract(const Duration(days: 21)),
    ),
    Product(
      id: 'prod4',
      artisanId: 'artisan4',
      title: 'Peinture intérieure',
      description: 'Peinture murale et finitions soignées.',
      price: 8500,
      currency: 'XOF',
      type: ProductType.SERVICE,
      active: true,
      imageUrls: [],
      views: 17,
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
    ),
  ];

  @override
  Future<Either<Failure, Product>> createProduct(
      String artisanId, Product product) async {
    _products.add(product);
    return Right(product);
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String productId) async {
    _products.removeWhere((item) => item.id == productId);
    return const Right(null);
  }

  @override
  Future<Either<Failure, Product>> getProduct(String productId) async {
    try {
      final product = _products.firstWhere((item) => item.id == productId);
      return Right(product);
    } catch (_) {
      return Left(NotFoundFailure(message: 'Produit introuvable.'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProducts({
    String? artisanId,
    bool? activeOnly,
    int? page,
    int? pageSize,
  }) async {
    final allProducts = _products.where((item) {
      final matchesArtisan = artisanId == null || item.artisanId == artisanId;
      final matchesActive = activeOnly == null || item.active == activeOnly;
      return matchesArtisan && matchesActive;
    }).toList();
    return Right(allProducts);
  }

  @override
  Future<Either<Failure, List<Product>>> getArtisanProducts(
      String artisanId) async {
    final artisanProducts =
        _products.where((item) => item.artisanId == artisanId).toList();
    return Right(artisanProducts);
  }

  @override
  Future<Either<Failure, void>> toggleProductActive(String productId) async {
    final index = _products.indexWhere((item) => item.id == productId);
    if (index < 0) {
      return Left(NotFoundFailure(
          message: 'Produit introuvable pour activation/désactivation.'));
    }
    final product = _products[index];
    _products[index] = Product(
      id: product.id,
      artisanId: product.artisanId,
      title: product.title,
      description: product.description,
      price: product.price,
      currency: product.currency,
      type: product.type,
      active: !product.active,
      imageUrls: product.imageUrls,
      views: product.views,
      createdAt: product.createdAt,
    );
    return const Right(null);
  }

  @override
  Future<Either<Failure, Product>> updateProduct(Product product) async {
    final index = _products.indexWhere((item) => item.id == product.id);
    if (index < 0) {
      return Left(
          NotFoundFailure(message: 'Produit introuvable pour mise à jour.'));
    }
    _products[index] = product;
    return Right(product);
  }
}