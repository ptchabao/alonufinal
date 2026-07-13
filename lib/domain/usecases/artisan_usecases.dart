import 'package:dartz/dartz.dart';
import '../../core/errors/failure.dart';
import '../entities/artisan.dart';
import '../repositories/artisan_repository.dart';

class GetCategoriesUseCase {
  final ArtisanRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<Either<Failure, List<Category>>> call() {
    return repository.getCategories();
  }
}

class GetSubcategoriesUseCase {
  final ArtisanRepository repository;

  GetSubcategoriesUseCase(this.repository);

  Future<Either<Failure, List<SubCategory>>> call(String categoryId) {
    return repository.getSubcategories(categoryId);
  }
}

class GetNearbyArtisansUseCase {
  final ArtisanRepository repository;

  GetNearbyArtisansUseCase(this.repository);

  Future<Either<Failure, List<Artisan>>> call({
    required double latitude,
    required double longitude,
    required double distanceKm,
    String? categoryId,
    String? subCategoryId,
  }) {
    return repository.getArtisansNearby(
      latitude: latitude,
      longitude: longitude,
      distanceKm: distanceKm,
      categoryId: categoryId,
      subCategoryId: subCategoryId,
    );
  }
}

class GetArtisanDetailsUseCase {
  final ArtisanRepository repository;

  GetArtisanDetailsUseCase(this.repository);

  Future<Either<Failure, Artisan>> call(String artisanId) {
    return repository.getArtisan(artisanId);
  }
}

class CreateArtisanProfileUseCase {
  final ArtisanRepository repository;

  CreateArtisanProfileUseCase(this.repository);

  Future<Either<Failure, Artisan>> call(Artisan artisan) {
    return repository.createArtisan(artisan);
  }
}

class UpdateArtisanProfileUseCase {
  final ArtisanRepository repository;

  UpdateArtisanProfileUseCase(this.repository);

  Future<Either<Failure, Artisan>> call(Artisan artisan) {
    return repository.updateArtisan(artisan);
  }
}

class GetRealisationsUseCase {
  final ArtisanRepository repository;

  GetRealisationsUseCase(this.repository);

  Future<Either<Failure, List<Realisation>>> call(String artisanId) {
    return repository.getRealisations(artisanId);
  }
}

class AddRealisationUseCase {
  final ArtisanRepository repository;

  AddRealisationUseCase(this.repository);

  Future<Either<Failure, Realisation>> call(String artisanId, Realisation realisation) {
    return repository.addRealisation(artisanId, realisation);
  }
}

class DeleteRealisationUseCase {
  final ArtisanRepository repository;

  DeleteRealisationUseCase(this.repository);

  Future<Either<Failure, void>> call(String artisanId, String realisationId) {
    return repository.deleteRealisation(artisanId, realisationId);
  }
}

// Product Use Cases
class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  Future<Either<Failure, List<Product>>> call({
    String? artisanId,
    bool? activeOnly,
    int? page,
    int? pageSize,
  }) {
    return repository.getProducts(
      artisanId: artisanId,
      activeOnly: activeOnly,
      page: page,
      pageSize: pageSize,
    );
  }
}

class GetProductDetailsUseCase {
  final ProductRepository repository;

  GetProductDetailsUseCase(this.repository);

  Future<Either<Failure, Product>> call(String productId) {
    return repository.getProduct(productId);
  }
}

class CreateProductUseCase {
  final ProductRepository repository;

  CreateProductUseCase(this.repository);

  Future<Either<Failure, Product>> call(String artisanId, Product product) {
    return repository.createProduct(artisanId, product);
  }
}

class UpdateProductUseCase {
  final ProductRepository repository;

  UpdateProductUseCase(this.repository);

  Future<Either<Failure, Product>> call(Product product) {
    return repository.updateProduct(product);
  }
}

class DeleteProductUseCase {
  final ProductRepository repository;

  DeleteProductUseCase(this.repository);

  Future<Either<Failure, void>> call(String productId) {
    return repository.deleteProduct(productId);
  }
}

class ToggleProductActiveUseCase {
  final ProductRepository repository;

  ToggleProductActiveUseCase(this.repository);

  Future<Either<Failure, void>> call(String productId) {
    return repository.toggleProductActive(productId);
  }
}

class GetArtisanProductsUseCase {
  final ProductRepository repository;

  GetArtisanProductsUseCase(this.repository);

  Future<Either<Failure, List<Product>>> call(String artisanId) {
    return repository.getArtisanProducts(artisanId);
  }
}
