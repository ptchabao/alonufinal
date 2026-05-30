import 'package:riverpod/riverpod.dart';
import '../../domain/entities/artisan.dart';
import '../../domain/usecases/artisan_usecases.dart';
import '../../core/service_locator.dart';

// States for artisan/product management
class ArtisanState {
  final List<Category> categories;
  final List<Artisan> artisans;
  final List<Product> products;
  final bool isLoading;
  final String? error;

  ArtisanState({
    this.categories = const [],
    this.artisans = const [],
    this.products = const [],
    this.isLoading = false,
    this.error,
  });

  ArtisanState copyWith({
    List<Category>? categories,
    List<Artisan>? artisans,
    List<Product>? products,
    bool? isLoading,
    String? error,
  }) {
    return ArtisanState(
      categories: categories ?? this.categories,
      artisans: artisans ?? this.artisans,
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ArtisanNotifier extends StateNotifier<ArtisanState> {
  ArtisanNotifier() : super(ArtisanState());

  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await getIt<GetCategoriesUseCase>().call();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (categories) => state = state.copyWith(
        isLoading: false,
        categories: categories,
      ),
    );
  }

  Future<void> loadNearbyArtisans({
    required double latitude,
    required double longitude,
    required double distanceKm,
    String? categoryId,
    String? subCategoryId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await getIt<GetNearbyArtisansUseCase>().call(
      latitude: latitude,
      longitude: longitude,
      distanceKm: distanceKm,
      categoryId: categoryId,
      subCategoryId: subCategoryId,
    );
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (artisans) => state = state.copyWith(
        isLoading: false,
        artisans: artisans,
      ),
    );
  }

  Future<void> loadProducts({String? artisanId}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await getIt<GetProductsUseCase>().call(
      artisanId: artisanId,
      activeOnly: true,
    );
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (products) => state = state.copyWith(
        isLoading: false,
        products: products,
      ),
    );
  }
}

final artisanProvider = StateNotifierProvider<ArtisanNotifier, ArtisanState>((ref) {
  return ArtisanNotifier();
});

// Category provider
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final result = await getIt<GetCategoriesUseCase>().call();
  return result.fold((l) => [], (r) => r);
});

final allProductsProvider = FutureProvider<List<Product>>((ref) async {
  final result = await getIt<GetProductsUseCase>().call();
  return result.fold((failure) => [], (products) => products);
});

final artisanDetailsProvider = FutureProvider.family<Artisan?, String>((ref, artisanId) async {
  final result = await getIt<GetArtisanDetailsUseCase>().call(artisanId);
  return result.fold((failure) => throw Exception(failure.message), (artisan) => artisan);
});

final artisanProductsProvider = FutureProvider.family<List<Product>, String>((ref, artisanId) async {
  final result = await getIt<GetArtisanProductsUseCase>().call(artisanId);
  return result.fold((failure) => [], (products) => products);
});

final artisanRealisationsProvider = FutureProvider.family<List<Realisation>, String>((ref, artisanId) async {
  final result = await getIt<GetRealisationsUseCase>().call(artisanId);
  return result.fold((failure) => [], (realisations) => realisations);
});

final productDetailsProvider = FutureProvider.family<Product?, String>((ref, productId) async {
  final result = await getIt<GetProductDetailsUseCase>().call(productId);
  return result.fold((failure) => throw Exception(failure.message), (product) => product);
});
