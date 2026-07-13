import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/datasources/artisan_remote_data_source.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/artisan_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/services/location_service.dart';
import '../bloc/auth_provider.dart';
import 'package:geolocator/geolocator.dart';

// Provider for DIO client. Doit porter baseUrl + AuthInterceptor, sans quoi
// tous les appels authentifiés (create/update artisan, produits, réalisations)
// échouent silencieusement en 401 en environnement de prod.
final dioProvider = Provider<Dio>((ref) {
  const secureStorage = FlutterSecureStorage();
  final dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
    receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
    sendTimeout: const Duration(milliseconds: AppConstants.sendTimeout),
  ));
  dio.interceptors.add(AuthInterceptor(secureStorage));
  dio.interceptors.add(LoggingInterceptor());
  return dio;
});

// Provider for the auth remote data source (mise à jour nom/prénom via PUT /users/{id})
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRemoteDataSourceImpl(dio);
});

// Provider for location service
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// Provider for artisan remote data source
final artisanRemoteDataSourceProvider =
    Provider<ArtisanRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return ArtisanRemoteDataSourceImpl(dio);
});

// Provider for getting user's current location
final currentLocationProvider = FutureProvider<Position>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return locationService.getCurrentPosition();
});

// Provider for getting categories
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final dataSource = ref.watch(artisanRemoteDataSourceProvider);
  return dataSource.getCategories();
});

// Provider for getting artisans by location with parameters
final artisansByLocationProvider = FutureProvider.family<
    List<ArtisanModel>,
    ({double latitude, double longitude, int page, int limit})>((ref, params) async {
  final dataSource = ref.watch(artisanRemoteDataSourceProvider);
  return dataSource.getArtisansByLocation(
    latitude: params.latitude,
    longitude: params.longitude,
    page: params.page,
    limit: params.limit,
  );
});

// Simpler version - provider for getting artisans near current location
final nearbyArtisansProvider =
    FutureProvider<List<ArtisanModel>>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  final dataSource = ref.watch(artisanRemoteDataSourceProvider);

  try {
    final position = await locationService.getCurrentPosition();
    return dataSource.getArtisansByLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      page: 1,
      limit: 20,
    );
  } catch (e) {
    throw Exception('Impossible de récupérer les artisans à proximité: $e');
  }
});

// Provider for getting all artisans (without location filtering)
final allArtisansProvider = FutureProvider<List<ArtisanModel>>((ref) async {
  final dataSource = ref.watch(artisanRemoteDataSourceProvider);
  return dataSource.getArtisans(page: 1, limit: 20);
});

// Provider for searching artisans
final searchArtisansProvider =
    FutureProvider.family<List<ArtisanModel>, String>((ref, query) async {
  if (query.isEmpty) {
    return [];
  }
  final dataSource = ref.watch(artisanRemoteDataSourceProvider);
  return dataSource.searchArtisans(query);
});

// Provider for artisan detail
final artisanDetailProvider =
    FutureProvider.family<ArtisanModel, String>((ref, artisanId) async {
  final dataSource = ref.watch(artisanRemoteDataSourceProvider);
  return dataSource.getArtisanDetail(artisanId);
});

// Provider for updating artisan (returns a callable function)
final updateArtisanActionProvider = Provider<Future<ArtisanModel> Function(String, Map<String, dynamic>)>((ref) {
  final dataSource = ref.watch(artisanRemoteDataSourceProvider);
  return (String artisanId, Map<String, dynamic> data) => dataSource.updateArtisan(artisanId, data);
});

// Provider for getting students for an artisan
final studentsByArtisanProvider = FutureProvider.family<List<dynamic>, String>((ref, artisanId) async {
  final dataSource = ref.watch(artisanRemoteDataSourceProvider);
  return dataSource.getStudentsByArtisan(artisanId);
});

// Provider for a single student detail
final studentDetailProvider = FutureProvider.family<dynamic, String>((ref, studentId) async {
  final dataSource = ref.watch(artisanRemoteDataSourceProvider);
  return dataSource.getStudentDetail(studentId);
});

// Provider for publishing a product (callable)
final publishProductActionProvider = Provider<Future<dynamic> Function(String, Map<String, dynamic>)>((ref) {
  final dataSource = ref.watch(artisanRemoteDataSourceProvider);
  return (String artisanId, Map<String, dynamic> productData) => dataSource.publishProduct(artisanId, productData);
});

// Provider for getting artisan products
final artisanProductsProvider = FutureProvider.family<List<dynamic>, String>((ref, artisanId) async {
  final dataSource = ref.watch(artisanRemoteDataSourceProvider);
  return dataSource.getArtisanProducts(artisanId);
});

// Provider for getting artisan orders
final artisanOrdersProvider = FutureProvider.family<List<dynamic>, String>((ref, artisanId) async {
  final dataSource = ref.watch(artisanRemoteDataSourceProvider);
  return dataSource.getArtisanOrders(artisanId);
});

// L'API n'expose pas de /artisans/me : on retrouve le profil artisan de
// l'utilisateur connecté dans la liste des artisans actifs (GET /artisans).
// Limite connue : un artisan en attente de validation (non "actif") ne
// remontera pas ici tant qu'un admin ne l'a pas validé via /artisans/{id}/validate.
final myArtisanProvider = FutureProvider<ArtisanModel?>((ref) async {
  final userId = ref.watch(authProvider).user?.id;
  if (userId == null) return null;
  final dataSource = ref.watch(artisanRemoteDataSourceProvider);
  final list = await dataSource.getArtisans(page: 1, limit: 100);
  for (final artisan in list) {
    if (artisan.userId == userId) return artisan;
  }
  return null;
});

// Provider for creating an artisan profile (callable) — POST /artisans
final createArtisanActionProvider = Provider<Future<ArtisanModel> Function(Map<String, dynamic>)>((ref) {
  final dataSource = ref.watch(artisanRemoteDataSourceProvider);
  return (Map<String, dynamic> data) => dataSource.createArtisan(data);
});

// Provider for updating the current user's nom/prénom/avatar — PUT /users/{id}
final updateUserActionProvider = Provider<Future<void> Function(String, Map<String, dynamic>)>((ref) {
  final dataSource = ref.watch(authRemoteDataSourceProvider);
  return (String userId, Map<String, dynamic> data) => dataSource.updateUser(userId, data);
});

// Provider for listing an artisan's réalisations
final realisationsProvider = FutureProvider.family<List<RealisationModel>, String>((ref, artisanId) async {
  final dataSource = ref.watch(artisanRemoteDataSourceProvider);
  return dataSource.getRealisations(artisanId);
});

// Provider for adding a réalisation (callable)
final addRealisationActionProvider = Provider<Future<RealisationModel> Function(String, Map<String, dynamic>)>((ref) {
  final dataSource = ref.watch(artisanRemoteDataSourceProvider);
  return (String artisanId, Map<String, dynamic> data) => dataSource.addRealisation(artisanId, data);
});

// Provider for deleting a réalisation (callable)
final deleteRealisationActionProvider = Provider<Future<void> Function(String, String)>((ref) {
  final dataSource = ref.watch(artisanRemoteDataSourceProvider);
  return (String artisanId, String realisationId) => dataSource.deleteRealisation(artisanId, realisationId);
});

// Provider for updating a product (callable) — PUT /products/{id}
final updateProductActionProvider = Provider<Future<Map<String, dynamic>> Function(String, Map<String, dynamic>)>((ref) {
  final dataSource = ref.watch(artisanRemoteDataSourceProvider);
  return (String productId, Map<String, dynamic> data) => dataSource.updateProduct(productId, data);
});

// Provider for deleting a product (callable) — DELETE /products/{id}
final deleteProductActionProvider = Provider<Future<void> Function(String)>((ref) {
  final dataSource = ref.watch(artisanRemoteDataSourceProvider);
  return (String productId) => dataSource.deleteProduct(productId);
});

// Provider for toggling a product's active status (callable) — PATCH /products/{id}/toggle-active
final toggleProductActiveActionProvider = Provider<Future<Map<String, dynamic>> Function(String)>((ref) {
  final dataSource = ref.watch(artisanRemoteDataSourceProvider);
  return (String productId) => dataSource.toggleProductActive(productId);
});

// State notifier for managing filtering/sorting state
class ArtisanFilterState {
  final String? selectedCategory;
  final double? maxDistance;
  final String? searchQuery;
  final bool sortByDistance;

  ArtisanFilterState({
    this.selectedCategory,
    this.maxDistance,
    this.searchQuery,
    this.sortByDistance = true,
  });

  ArtisanFilterState copyWith({
    String? selectedCategory,
    double? maxDistance,
    String? searchQuery,
    bool? sortByDistance,
  }) {
    return ArtisanFilterState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      maxDistance: maxDistance ?? this.maxDistance,
      searchQuery: searchQuery ?? this.searchQuery,
      sortByDistance: sortByDistance ?? this.sortByDistance,
    );
  }
}

// State notifier for artisan filtering
class ArtisanFilterNotifier extends StateNotifier<ArtisanFilterState> {
  ArtisanFilterNotifier() : super(ArtisanFilterState());

  void setCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setMaxDistance(double? distance) {
    state = state.copyWith(maxDistance: distance);
  }

  void setSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleSortByDistance() {
    state = state.copyWith(sortByDistance: !state.sortByDistance);
  }

  void reset() {
    state = ArtisanFilterState();
  }
}

// Provider for artisan filter state
final artisanFilterProvider =
    StateNotifierProvider<ArtisanFilterNotifier, ArtisanFilterState>((ref) {
  return ArtisanFilterNotifier();
});

// Computed provider for filtered artisans
final filteredArtisansProvider =
    FutureProvider<List<ArtisanModel>>((ref) async {
  final filterState = ref.watch(artisanFilterProvider);
  final artisans = await ref.watch(nearbyArtisansProvider.future);

  var filtered = artisans;

  // Filter by distance
  if (filterState.maxDistance != null) {
    filtered = filtered
        .where((a) =>
            a.distance == null || a.distance! <= filterState.maxDistance!)
        .toList();
  }

  // Filter by category
  if (filterState.selectedCategory != null) {
    filtered = filtered
        .where((a) => a.subCategories.any((sc) =>
            sc.subCategory.categoryId == filterState.selectedCategory))
        .toList();
  }

  // Filter by search query
  if (filterState.searchQuery != null && filterState.searchQuery!.isNotEmpty) {
    final query = filterState.searchQuery!.toLowerCase();
    filtered = filtered
        .where((a) =>
            a.user.nom.toLowerCase().contains(query) ||
            a.user.prenom.toLowerCase().contains(query) ||
            a.numeroEnr.toLowerCase().contains(query))
        .toList();
  }

  // Sort by distance if enabled and available
  if (filterState.sortByDistance) {
    filtered.sort((a, b) {
      final distA = a.distance ?? double.infinity;
      final distB = b.distance ?? double.infinity;
      return distA.compareTo(distB);
    });
  }

  return filtered;
});
