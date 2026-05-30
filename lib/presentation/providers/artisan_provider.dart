import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../data/datasources/artisan_remote_data_source.dart';
import '../../data/models/artisan_model.dart';
import '../../core/network/dio_client.dart';
import '../../core/services/location_service.dart';
import 'package:geolocator/geolocator.dart';

// Provider for DIO client
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
  ));
  return dio;
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
