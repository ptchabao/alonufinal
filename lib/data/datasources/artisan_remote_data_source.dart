import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
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
  Future<List<dynamic>> getPublicApprenticeshipAds({String? countryId});
  Future<List<dynamic>> getCarouselAdvertisements({String? countryId});
  Future<dynamic> getProductDetail(String productId);
  Future<List<ArtisanModel>> searchArtisans(String query);
  Future<List<ArtisanModel>> filterArtisans({
    String? category,
    String? location,
    double? minRating,
  });
  // New endpoints
  Future<ArtisanModel> updateArtisan(String artisanId, Map<String, dynamic> updateData);
  Future<List<dynamic>> getStudentsByArtisan(String artisanId);
  Future<dynamic> getStudentDetail(String studentId);
  Future<dynamic> publishProduct(String artisanId, Map<String, dynamic> productData);
  Future<List<dynamic>> getArtisanProducts(String artisanId, {int page = 1, int limit = 20});
  // GET /orders/artisan — commandes de l'artisan connecté (JWT), filtrable par statut
  Future<List<dynamic>> getArtisanOrders({String? status});
  // PUT /orders/{id}/status
  Future<Map<String, dynamic>> updateOrderStatus(String orderId, String status);
  // POST /orders/{id}/mark-delivered
  Future<Map<String, dynamic>> markOrderDelivered(String orderId);
  // PUT /artisans/{id}/location
  Future<ArtisanModel> updateArtisanLocation(String artisanId, double latitude, double longitude);

  // POST /artisans
  Future<ArtisanModel> createArtisan(Map<String, dynamic> data);
  // GET /artisans/{id}/realisations
  Future<List<RealisationModel>> getRealisations(String artisanId);
  // POST /artisans/{id}/realisations
  Future<RealisationModel> addRealisation(String artisanId, Map<String, dynamic> data);
  // PUT /artisans/{id}/realisations/{realisationId}
  Future<RealisationModel> updateRealisation(String artisanId, String realisationId, Map<String, dynamic> data);
  // DELETE /artisans/{id}/realisations/{realisationId}
  Future<void> deleteRealisation(String artisanId, String realisationId);
  // PUT /products/{id}
  Future<Map<String, dynamic>> updateProduct(String productId, Map<String, dynamic> data);
  // DELETE /products/{id}
  Future<void> deleteProduct(String productId);
  // PATCH /products/{id}/toggle-active
  Future<Map<String, dynamic>> toggleProductActive(String productId);
  // POST /advertisements (Admin/Artisan) — auto-promotion d'un produit
  Future<Map<String, dynamic>> createAdvertisement(Map<String, dynamic> data);
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
  Future<List<dynamic>> getPublicApprenticeshipAds({String? countryId}) async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.apprenticeshipAdsEndpoint}',
        queryParameters: {
          if (countryId != null && countryId.isNotEmpty) 'countryId': countryId,
        },
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
  Future<List<dynamic>> getCarouselAdvertisements({String? countryId}) async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.advertisementsCarouselEndpoint}',
        queryParameters: {
          if (countryId != null && countryId.isNotEmpty) 'countryId': countryId,
        },
      );

      if (response.statusCode == 200) {
        return _extractList(response.data);
      }
      throw Exception('Erreur lors du chargement des publicités du carousel');
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

  @override
  Future<ArtisanModel> updateArtisan(
      String artisanId, Map<String, dynamic> updateData) async {
    try {
      final response = await dio.put(
        '${AppConstants.apiBaseUrl}${AppConstants.artisansEndpoint}/$artisanId',
        data: updateData,
      );

      if (response.statusCode == 200) {
        final json = _extractJson(response.data) as Map<String, dynamic>?
            ?? (response.data as Map<String, dynamic>);
        return ArtisanModel.fromJson(json);
      }
      throw Exception('Erreur lors de la mise à jour de l\'artisan');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<List<dynamic>> getStudentsByArtisan(String artisanId) async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}/students/artisan/$artisanId',
      );

      if (response.statusCode == 200) {
        return _extractList(response.data);
      }
      throw Exception('Erreur lors du chargement des apprentis');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<dynamic> getStudentDetail(String studentId) async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}/students/$studentId',
      );

      if (response.statusCode == 200) {
        return _extractJson(response.data);
      }
      throw Exception('Apprenti non trouvé');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<dynamic> publishProduct(
      String artisanId, Map<String, dynamic> productData) async {
    try {
      final response = await dio.post(
        '${AppConstants.apiBaseUrl}${AppConstants.productsEndpoint}/artisan/$artisanId',
        data: productData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return _extractJson(response.data) ?? response.data;
      }
      throw Exception('Erreur lors de la publication du produit');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<List<dynamic>> getArtisanProducts(String artisanId,
      {int page = 1, int limit = 20}) async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.productsEndpoint}/artisan/$artisanId',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        return _extractList(response.data);
      }
      throw Exception('Erreur lors du chargement des produits de l\'artisan');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<List<dynamic>> getArtisanOrders({String? status}) async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.ordersEndpoint}/artisan',
        queryParameters: {
          if (status != null && status.isNotEmpty) 'status': status,
        },
      );

      if (response.statusCode == 200) {
        return _extractList(response.data);
      }
      throw Exception('Erreur lors du chargement des commandes de l\'artisan');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await dio.put(
        '${AppConstants.apiBaseUrl}${AppConstants.ordersEndpoint}/$orderId/status',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        return _extractJson(response.data) as Map<String, dynamic>?
            ?? (response.data as Map<String, dynamic>);
      }
      throw Exception('Erreur lors de la mise à jour du statut de la commande');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<ArtisanModel> updateArtisanLocation(
      String artisanId, double latitude, double longitude) async {
    try {
      final response = await dio.put(
        '${AppConstants.apiBaseUrl}${AppConstants.artisansEndpoint}/$artisanId/location',
        data: {'latitude': latitude, 'longitude': longitude},
      );

      if (response.statusCode == 200) {
        final json = _extractJson(response.data) as Map<String, dynamic>?
            ?? (response.data as Map<String, dynamic>);
        return ArtisanModel.fromJson(json);
      }
      throw Exception('Erreur lors de la mise à jour de la position');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> markOrderDelivered(String orderId) async {
    try {
      final response = await dio.post(
        '${AppConstants.apiBaseUrl}${AppConstants.ordersEndpoint}/$orderId/mark-delivered',
      );

      if (response.statusCode == 200) {
        return _extractJson(response.data) as Map<String, dynamic>?
            ?? (response.data as Map<String, dynamic>);
      }
      throw Exception('Erreur lors du passage en livrée');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<ArtisanModel> createArtisan(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        '${AppConstants.apiBaseUrl}${AppConstants.artisansEndpoint}',
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final json = _extractJson(response.data) as Map<String, dynamic>?
            ?? (response.data as Map<String, dynamic>);
        return ArtisanModel.fromJson(json);
      }
      throw Exception('Erreur lors de la création de l\'artisan');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<List<RealisationModel>> getRealisations(String artisanId) async {
    try {
      final response = await dio.get(
        '${AppConstants.apiBaseUrl}${AppConstants.artisansEndpoint}/$artisanId/realisations',
      );

      if (response.statusCode == 200) {
        return _extractList(response.data)
            .map((e) => RealisationModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Erreur lors du chargement des réalisations');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<RealisationModel> addRealisation(String artisanId, Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        '${AppConstants.apiBaseUrl}${AppConstants.artisansEndpoint}/$artisanId/realisations',
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final json = _extractJson(response.data) as Map<String, dynamic>?
            ?? (response.data as Map<String, dynamic>);
        return RealisationModel.fromJson(json);
      }
      throw Exception('Erreur lors de la création de la réalisation');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<RealisationModel> updateRealisation(
      String artisanId, String realisationId, Map<String, dynamic> data) async {
    try {
      final response = await dio.put(
        '${AppConstants.apiBaseUrl}${AppConstants.artisansEndpoint}/$artisanId/realisations/$realisationId',
        data: data,
      );

      if (response.statusCode == 200) {
        final json = _extractJson(response.data) as Map<String, dynamic>?
            ?? (response.data as Map<String, dynamic>);
        return RealisationModel.fromJson(json);
      }
      throw Exception('Erreur lors de la mise à jour de la réalisation');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<void> deleteRealisation(String artisanId, String realisationId) async {
    try {
      final response = await dio.delete(
        '${AppConstants.apiBaseUrl}${AppConstants.artisansEndpoint}/$artisanId/realisations/$realisationId',
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        return;
      }
      throw Exception('Erreur lors de la suppression de la réalisation');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> updateProduct(String productId, Map<String, dynamic> data) async {
    try {
      final response = await dio.put(
        '${AppConstants.apiBaseUrl}${AppConstants.productsEndpoint}/$productId',
        data: data,
      );

      if (response.statusCode == 200) {
        return _extractJson(response.data) as Map<String, dynamic>?
            ?? (response.data as Map<String, dynamic>);
      }
      throw Exception('Erreur lors de la mise à jour du produit');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      final response = await dio.delete(
        '${AppConstants.apiBaseUrl}${AppConstants.productsEndpoint}/$productId',
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        return;
      }
      throw Exception('Erreur lors de la suppression du produit');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> toggleProductActive(String productId) async {
    try {
      final response = await dio.patch(
        '${AppConstants.apiBaseUrl}${AppConstants.productsEndpoint}/$productId/toggle-active',
      );

      if (response.statusCode == 200) {
        return _extractJson(response.data) as Map<String, dynamic>?
            ?? (response.data as Map<String, dynamic>);
      }
      throw Exception('Erreur lors du changement de statut du produit');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> createAdvertisement(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        '${AppConstants.apiBaseUrl}/advertisements',
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return _extractJson(response.data) as Map<String, dynamic>?
            ?? (response.data as Map<String, dynamic>);
      }
      throw Exception('Erreur lors de la création de l\'annonce');
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
