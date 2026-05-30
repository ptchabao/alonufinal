import 'package:dartz/dartz.dart';

import '../../core/errors/failure.dart';
import '../../domain/entities/artisan.dart';
import '../../domain/repositories/artisan_repository.dart';
import '../../data/datasources/artisan_remote_data_source.dart';

class ArtisanRemoteRepositoryImpl implements ArtisanRepository {
  final ArtisanRemoteDataSource remote;

  ArtisanRemoteRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, Artisan>> createArtisan(Artisan artisan) async {
    // Not implemented on remote yet
    return Left(NotFoundFailure(message: 'Création d\'artisan non prise en charge'));
  }

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final list = await remote.getCategories();
      final mapped = list.map((m) => Category(id: m.id, name: m.libelleFr, imageUrl: m.image, artisanCount: m.subCategories.length)).toList();
      return Right(mapped);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SubCategory>>> getSubcategories(String categoryId) async {
    try {
      final list = await remote.getSubcategories(categoryId);
      final mapped = list.map((m) => SubCategory(id: m.id, categoryId: m.categoryId, name: m.libelleFr, imageUrl: m.image, artisanCount: 0)).toList();
      return Right(mapped);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Artisan>> getArtisan(String artisanId) async {
    try {
      final model = await remote.getArtisanDetail(artisanId);
      return Right(model.toEntity());
    } catch (e) {
      return Left(NotFoundFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Artisan>>> getArtisansNearby({required double latitude, required double longitude, required double distanceKm, String? categoryId, String? subCategoryId}) async {
    try {
      final list = await remote.getArtisansByLocation(latitude: latitude, longitude: longitude, page: 1, limit: 50);
      final mapped = list.map((m) => m.toEntity()).toList();
      return Right(mapped);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Realisation>> addRealisation(String artisanId, Realisation realisation) async {
    // Not implemented remote
    return Left(NotFoundFailure(message: 'Ajout de réalisation non disponible')); 
  }

  @override
  Future<Either<Failure, List<Realisation>>> getRealisations(String artisanId) async {
    // Not implemented remote
    return Right([]);
  }

  @override
  Future<Either<Failure, Artisan>> updateArtisan(Artisan artisan) async {
    try {
      final payload = {
        'user': {'nom': artisan.user.nom, 'prenom': artisan.user.prenom},
        'telephone': artisan.telephone,
        'adresse': artisan.adresse,
      };
      final updated = await remote.updateArtisan(artisan.id, payload);
      return Right(updated.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRealisation(String artisanId, String realisationId) async {
    // Not implemented remote
    return const Right(null);
  }
}

class RemoteProductRepositoryImpl implements ProductRepository {
  final ArtisanRemoteDataSource remote;

  RemoteProductRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, Product>> createProduct(String artisanId, Product product) async {
    try {
      final resp = await remote.publishProduct(artisanId, {
        'title': product.title,
        'price': product.price,
        'description': product.description,
      });
      final map = resp as Map<String, dynamic>? ?? {};
      final created = _mapToProduct(map);
      return Right(created);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String productId) async {
    // Not implemented remote
    return const Right(null);
  }

  @override
  Future<Either<Failure, Product>> getProduct(String productId) async {
    try {
      final data = await remote.getProductDetail(productId);
      final map = data as Map<String, dynamic>? ?? {};
      return Right(_mapToProduct(map));
    } catch (e) {
      return Left(NotFoundFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProducts({String? artisanId, bool? activeOnly, int? page, int? pageSize}) async {
    try {
      if (artisanId != null) {
        final list = await remote.getArtisanProducts(artisanId, page: page ?? 1, limit: pageSize ?? 20);
        final mapped = (list).map((e) => _mapToProduct(e as Map<String,dynamic>)).toList();
        return Right(mapped);
      }
      final list = await remote.getProducts(page: page ?? 1, limit: pageSize ?? 20);
      final mapped = (list).map((e) => _mapToProduct(e as Map<String,dynamic>)).toList();
      return Right(mapped);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getArtisanProducts(String artisanId) async {
    return getProducts(artisanId: artisanId);
  }

  @override
  Future<Either<Failure, Product>> updateProduct(Product product) async {
    // Not implemented remote
    return Left(NotFoundFailure(message: 'Mise à jour produit non implémentée'));
  }

  @override
  Future<Either<Failure, void>> toggleProductActive(String productId) async {
    // Not implemented
    return const Right(null);
  }

  Product _mapToProduct(Map<String, dynamic> map) {
    return Product(
      id: map['id']?.toString() ?? '',
      artisanId: map['artisanId']?.toString() ?? map['artisan']?.toString() ?? '',
      title: map['title']?.toString() ?? map['name']?.toString() ?? '',
      description: map['description']?.toString(),
      price: double.tryParse(map['price']?.toString() ?? '0') ?? 0,
      currency: map['currency']?.toString() ?? 'XOF',
      type: (() {
        final t = map['type']?.toString();
        return (t != null && t.toLowerCase() == 'service') ? ProductType.SERVICE : ProductType.PRODUCT;
      })(),
      active: map['active'] as bool? ?? true,
        imageUrls: (map['images'] is List)
          ? List<String>.from((map['images'] as List).map((e) => e.toString()))
          : (map['imageUrls'] is List)
            ? List<String>.from((map['imageUrls'] as List).map((e) => e.toString()))
            : [],
      views: map['views'] as int? ?? 0,
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
