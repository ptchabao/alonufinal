import 'package:dartz/dartz.dart';
import '../../core/errors/failure.dart';
import '../entities/artisan.dart';

abstract class ArtisanRepository {
  Future<Either<Failure, List<Category>>> getCategories();
  Future<Either<Failure, List<SubCategory>>> getSubcategories(String categoryId);
  Future<Either<Failure, List<Artisan>>> getArtisansNearby({
    required double latitude,
    required double longitude,
    required double distanceKm,
    String? categoryId,
    String? subCategoryId,
  });
  Future<Either<Failure, Artisan>> getArtisan(String artisanId);
  Future<Either<Failure, Artisan>> createArtisan(Artisan artisan);
  Future<Either<Failure, Artisan>> updateArtisan(Artisan artisan);
  Future<Either<Failure, List<Realisation>>> getRealisations(String artisanId);
  Future<Either<Failure, Realisation>> addRealisation(String artisanId, Realisation realisation);
  Future<Either<Failure, void>> deleteRealisation(String artisanId, String realisationId);
}

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts({
    String? artisanId,
    bool? activeOnly,
    int? page,
    int? pageSize,
  });
  Future<Either<Failure, Product>> getProduct(String productId);
  Future<Either<Failure, Product>> createProduct(String artisanId, Product product);
  Future<Either<Failure, Product>> updateProduct(Product product);
  Future<Either<Failure, void>> deleteProduct(String productId);
  Future<Either<Failure, void>> toggleProductActive(String productId);
  Future<Either<Failure, List<Product>>> getArtisanProducts(String artisanId);
}
