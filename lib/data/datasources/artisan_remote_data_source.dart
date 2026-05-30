import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/dio_client.dart';
import '../models/user_model.dart';
import '../models/artisan_model.dart';

abstract class ArtisanRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<List<SubCategoryModel>> getSubcategories(String categoryId);
  Future<List<ArtisanModel>> getArtisans({int page = 1, int limit = 20});
  Future<List<ArtisanModel>> getArtisansByLocation({
    required double latitude,
    required double longitude,
    int page = 1,
    int limit = 20,
  });
  Future<ArtisanModel> getArtisanDetail(String artisanId);
  Future<List<dynamic>> getProducts({int page = 1, int limit = 20});
  Future<List<dynamic>> getPublicApprenticeshipAds();
  Future<dynamic> getProductDetail(String productId);
  Future<List<ArtisanModel>> searchArtisans(String query);
  Future<List<ArtisanModel>> filterArtisans({
    String? category,
    String? location,
    double? minRating,
  });
}

class ArtisanRemoteDataSourceImpl implements ArtisanRemoteDataSource {
  final Dio dio;

  ArtisanRemoteDataSourceImpl(this.dio);

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.categoriesEndpoint}',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final list =
            (data is List ? data : data['data'] ?? []) as List<dynamic>;
        return list
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Erreur lors du chargement des catégories');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<List<SubCategoryModel>> getSubcategories(String categoryId) async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.categoriesEndpoint}/$categoryId/subcategories',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final list =
            (data is List ? data : data['data'] ?? []) as List<dynamic>;
        return list
            .map((e) => SubCategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Erreur lors du chargement des sous-catégories');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<List<ArtisanModel>> getArtisans({int page = 1, int limit = 20}) async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.artisansEndpoint}',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final list =
            (data is List ? data : data['data'] ?? []) as List<dynamic>;
        return list
            .map((e) => ArtisanModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Erreur lors du chargement des artisans');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<List<ArtisanModel>> getArtisansByLocation({
    required double latitude,
    required double longitude,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.artisansEndpoint}',
        queryParameters: {
          'lat': latitude,
          'lng': longitude,
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final list =
            (data is List ? data : data['data'] ?? []) as List<dynamic>;
        final artisans = list
            .map((e) => ArtisanModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // Sort by distance if available
        artisans.sort((a, b) {
          final distA = a.distance ?? double.infinity;
          final distB = b.distance ?? double.infinity;
          return distA.compareTo(distB);
        });

        return artisans;
      }
      throw Exception(
        'Erreur lors du chargement des artisans par localisation',
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<ArtisanModel> getArtisanDetail(String artisanId) async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.artisansEndpoint}/$artisanId',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final json =
            (data is Map ? data : data['data'] ?? {}) as Map<String, dynamic>;
        return ArtisanModel.fromJson(json);
      }
      throw Exception('Artisan non trouvé');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<List<dynamic>> getProducts({int page = 1, int limit = 20}) async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.productsEndpoint}',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        return _extractList(response.data);
      }
      throw Exception('Erreur lors du chargement des produits');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<List<dynamic>> getPublicApprenticeshipAds() async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.apprenticeshipAdsEndpoint}',
      );

      if (response.statusCode == 200) {
        return _extractList(response.data);
      }
      throw Exception('Erreur lors du chargement des cours');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<dynamic> getProductDetail(String productId) async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.productsEndpoint}/$productId',
      );

      if (response.statusCode == 200) {
        return _extractJson(response.data);
      }
      throw Exception('Produit non trouvé');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<List<ArtisanModel>> searchArtisans(String query) async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.artisansEndpoint}/search',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final list =
            (data is List ? data : data['data'] ?? []) as List<dynamic>;
        return list
            .map((e) => ArtisanModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Erreur lors de la recherche');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<List<ArtisanModel>> filterArtisans({
    String? category,
    String? location,
    double? minRating,
  }) async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.artisansEndpoint}',
        queryParameters: {
          if (category != null) 'category': category,
          if (location != null) 'location': location,
          if (minRating != null) 'minRating': minRating,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final list =
            (data is List ? data : data['data'] ?? []) as List<dynamic>;
        return list
            .map((e) => ArtisanModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Erreur lors du filtrage');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) {
      return List<dynamic>.from(data);
    }
    if (data is Map) {
      final nestedData = data['data'];
      if (nestedData is List) {
        return List<dynamic>.from(nestedData);
      }
      if (nestedData is Map) {
        return [nestedData];
      }
    }
    return const [];
  }

  dynamic _extractJson(dynamic data) {
    if (data is Map) {
      final nestedData = data['data'];
      if (nestedData is Map) {
        return nestedData;
      }
    }
    return data;
  }

  Exception _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Délai d\'attente dépassé');
    }
    if (e.type == DioExceptionType.unknown) {
      return Exception('Erreur réseau');
    }
    if (e.response?.statusCode == 404) {
      return Exception('Ressource non trouvée');
    }
    if (e.response?.statusCode == 500) {
      return Exception('Erreur serveur');
    }
    return Exception(e.message ?? 'Erreur inconnue');
  }
}
