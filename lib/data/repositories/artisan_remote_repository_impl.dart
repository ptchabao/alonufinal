import 'package:dartz/dartz.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/failure.dart';
import '../../domain/entities/artisan.dart';
import '../../domain/repositories/artisan_repository.dart';
import '../../data/datasources/artisan_remote_data_source.dart';

class ArtisanRemoteRepositoryImpl implements ArtisanRepository {
  final ArtisanRemoteDataSource remote;

  ArtisanRemoteRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, Artisan>> createArtisan(Artisan artisan) async {
    try {
      final payload = {
        'userId': artisan.userId,
        'numeroEnr': artisan.numeroEnr,
        'telephone': artisan.telephone,
        if (artisan.adresse != null) 'adresse': artisan.adresse,
        if (artisan.latitude != null) 'latitude': artisan.latitude,
        if (artisan.longitude != null) 'longitude': artisan.longitude,
        'countryId': artisan.countryId,
        if (artisan.facebook != null) 'facebook': artisan.facebook,
        if (artisan.whatsapp != null) 'whatsapp': artisan.whatsapp,
        if (artisan.twitter != null) 'twitter': artisan.twitter,
        if (artisan.instagram != null) 'instagram': artisan.instagram,
        'subCategoryIds': artisan.subCategories.map((sc) => sc.subCategoryId).toList(),
      };
      final created = await remote.createArtisan(payload);
      return Right(created.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
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
    try {
      final payload = {
        'libelle': realisation.title,
        if (realisation.description != null) 'description': realisation.description,
        'images': realisation.imageUrls,
      };
      final created = await remote.addRealisation(artisanId, payload);
      return Right(created.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Realisation>>> getRealisations(String artisanId) async {
    try {
      final list = await remote.getRealisations(artisanId);
      return Right(list.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Artisan>> updateArtisan(Artisan artisan) async {
    try {
      // UpdateArtisanDto ne porte que les champs artisan (nom/prénom vivent sur
      // l'utilisateur et se mettent à jour via PUT /users/{id}, cf. UserRepository.updateUser).
      final payload = {
        'telephone': artisan.telephone,
        if (artisan.adresse != null) 'adresse': artisan.adresse,
        if (artisan.latitude != null) 'latitude': artisan.latitude,
        if (artisan.longitude != null) 'longitude': artisan.longitude,
        if (artisan.facebook != null) 'facebook': artisan.facebook,
        if (artisan.whatsapp != null) 'whatsapp': artisan.whatsapp,
        if (artisan.twitter != null) 'twitter': artisan.twitter,
        if (artisan.instagram != null) 'instagram': artisan.instagram,
      };
      final updated = await remote.updateArtisan(artisan.id, payload);
      return Right(updated.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRealisation(String artisanId, String realisationId) async {
    try {
      await remote.deleteRealisation(artisanId, realisationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
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
    try {
      await remote.deleteProduct(productId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
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
    try {
      final payload = {
        'title': product.title,
        if (product.description != null) 'description': product.description,
        'price': product.price,
        'currency': product.currency,
        'isService': product.type == ProductType.SERVICE,
        'active': product.active,
        'imageUrls': product.imageUrls,
      };
      final updated = await remote.updateProduct(product.id, payload);
      return Right(_mapToProduct(updated));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleProductActive(String productId) async {
    try {
      await remote.toggleProductActive(productId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Product _mapToProduct(Map<String, dynamic> map) {
    return Product(
      id: map['id']?.toString() ?? '',
      artisanId: map['artisanId']?.toString() ?? map['artisan']?.toString() ?? '',
      title: map['title']?.toString() ?? map['name']?.toString() ?? '',
      description: map['description']?.toString(),
      price: double.tryParse(map['price']?.toString() ?? '0') ?? 0,
      currency: map['currency']?.toString() ?? 'XOF',
      type: (map['isService'] as bool? ?? false) ? ProductType.SERVICE : ProductType.PRODUCT,
      active: map['active'] as bool? ?? true,
      imageUrls: (map['images'] is List)
          ? List<String>.from((map['images'] as List).map((e) =>
              AppConstants.resolveMediaUrl(
                  e is Map ? (e['url']?.toString() ?? '') : e.toString()) ?? ''))
          : (map['imageUrls'] is List)
              ? List<String>.from((map['imageUrls'] as List)
                  .map((e) => AppConstants.resolveMediaUrl(e.toString()) ?? ''))
              : [],
      views: map['viewsCount'] as int? ?? map['views'] as int? ?? 0,
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
