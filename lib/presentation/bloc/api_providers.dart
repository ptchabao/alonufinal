import 'package:riverpod/riverpod.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/app_constants.dart';
import '../../data/datasources/artisan_remote_data_source.dart';
import '../../data/datasources/order_remote_data_source.dart';
import '../../data/datasources/payment_remote_data_source.dart';
import '../../data/datasources/donation_remote_data_source.dart';
import '../../data/datasources/referral_remote_data_source.dart';
import '../../data/datasources/student_remote_data_source.dart';
import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/datasources/preferences_remote_data_source.dart';
import '../../data/models/artisan_model.dart';
import '../../domain/entities/artisan.dart' show Realisation;
import '../../core/services/location_service.dart';
import 'auth_provider.dart';

// Dio Client Provider
final dioProvider = Provider((ref) {
  final secureStorage = const FlutterSecureStorage();
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      sendTimeout: const Duration(milliseconds: AppConstants.sendTimeout),
    ),
  );

  dio.interceptors.add(AuthInterceptor(secureStorage));
  dio.interceptors.add(LoggingInterceptor());

  return dio;
});

// Artisan DataSource Provider
final artisanDataSourceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return ArtisanRemoteDataSourceImpl(dio);
});

// Order DataSource Provider
final orderDataSourceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return OrderRemoteDataSourceImpl(dio);
});

// Payment DataSource Provider
final paymentDataSourceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return PaymentRemoteDataSourceImpl(dio);
});

// Donation DataSource Provider
final donationDataSourceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return DonationRemoteDataSourceImpl(dio);
});

// Referral DataSource Provider
final referralDataSourceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return ReferralRemoteDataSourceImpl(dio);
});

// Student DataSource Provider
final studentDataSourceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return StudentRemoteDataSourceImpl(dio);
});

// Dashboard DataSource Provider
final dashboardDataSourceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return DashboardRemoteDataSourceImpl(dio);
});

// Preferences DataSource Provider
final preferencesDataSourceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return PreferencesRemoteDataSourceImpl(dio);
});

// Categories Provider
final categoriesProvider = FutureProvider.autoDispose<List<CategoryModel>>((
  ref,
) async {
  final dataSource = ref.watch(artisanDataSourceProvider);
  try {
    return await dataSource.getCategories();
  } catch (e) {
    throw Exception('Erreur: ${e.toString()}');
  }
});

final subcategoriesProvider = FutureProvider.autoDispose
    .family<List<SubCategoryModel>, String>((ref, categoryId) async {
      final dataSource = ref.watch(artisanDataSourceProvider);
      try {
        return await dataSource.getSubcategories(categoryId);
      } catch (e) {
        throw Exception('Erreur: ${e.toString()}');
      }
    });

// ⭐ Nearby Artisans Provider - Utilise GPS pour récupérer les artisans proches (NOUVEAU)
final nearbyArtisansProvider = FutureProvider.autoDispose<List<ArtisanModel>>((
  ref,
) async {
  final dataSource = ref.watch(artisanDataSourceProvider);

  try {
    // Obtenir la position actuelle
    final locationService = LocationService();
    final position = await locationService.getCurrentPosition();

    // Récupérer artisans proches avec les coordonnées GPS
    return await dataSource.getArtisansByLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      limit: 50,
    );
  } catch (e) {
    // En cas d'erreur (permission GPS refusée, etc.), récupérer tous les artisans
    print('Erreur géolocalisation, récupération de tous les artisans: $e');
    return await dataSource.getArtisans();
  }
});

// Artisans Provider - Wrapper qui utilise le nearbyArtisansProvider (avec GPS)
final artisansProvider = FutureProvider.autoDispose<List<ArtisanModel>>((
  ref,
) async {
  // Cette ligne retourne directement le Future du nearbyArtisansProvider
  // via le mécanisme de watch qui gère l'attente automatiquement
  return ref
      .watch(nearbyArtisansProvider)
      .when(
        data: (data) => data,
        loading: () => Future.value([]),
        error: (err, st) => Future.error(err),
      );
});

// Artisan Detail Provider
final artisanDetailProvider = FutureProvider.autoDispose
    .family<dynamic, String>((ref, artisanId) async {
      final dataSource = ref.watch(artisanDataSourceProvider);
      try {
        return await dataSource.getArtisanDetail(artisanId);
      } catch (e) {
        throw Exception('Erreur: ${e.toString()}');
      }
    });

// Artisan Realisations Provider (portfolio) — GET /artisans/{id}/realisations
final artisanRealisationsProvider = FutureProvider.autoDispose
    .family<List<Realisation>, String>((ref, artisanId) async {
      final dataSource = ref.watch(artisanDataSourceProvider);
      try {
        final list = await dataSource.getRealisations(artisanId);
        return list.map((m) => m.toEntity()).toList();
      } catch (e) {
        throw Exception('Erreur: ${e.toString()}');
      }
    });

// Products Provider
final productsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dataSource = ref.watch(artisanDataSourceProvider);
  try {
    return await dataSource.getProducts();
  } catch (e) {
    throw Exception('Erreur: ${e.toString()}');
  }
});

// Public apprenticeship ads / courses provider
final apprenticeshipAdsProvider = FutureProvider.autoDispose<List<dynamic>>((
  ref,
) async {
  final dataSource = ref.watch(artisanDataSourceProvider);
  try {
    final countryId = ref.watch(authProvider).user?.countryId;
    return await dataSource.getPublicApprenticeshipAds(countryId: countryId);
  } catch (e) {
    throw Exception('Erreur: ${e.toString()}');
  }
});

final advertisementsCarouselProvider = FutureProvider.autoDispose<List<dynamic>>(
  (ref) async {
    final dataSource = ref.watch(artisanDataSourceProvider);
    final countryId = ref.watch(authProvider).user?.countryId;

    try {
      return await dataSource.getCarouselAdvertisements(countryId: countryId);
    } catch (e) {
      throw Exception('Erreur: ${e.toString()}');
    }
  },
);

final apprenticeshipAdDetailProvider = FutureProvider.autoDispose
    .family<dynamic, String>((ref, adId) async {
      final ads = await ref.watch(apprenticeshipAdsProvider.future);
      final match = ads.where((item) => (item['id'] ?? '').toString() == adId);
      if (match.isEmpty) {
        throw Exception('Cours introuvable');
      }
      return match.first;
    });

// Product Detail Provider
final productDetailProvider = FutureProvider.autoDispose
    .family<dynamic, String>((ref, productId) async {
      final dataSource = ref.watch(artisanDataSourceProvider);
      try {
        return await dataSource.getProductDetail(productId);
      } catch (e) {
        throw Exception('Erreur: ${e.toString()}');
      }
    });

// Search Artisans Provider
final searchArtisansProvider = FutureProvider.autoDispose
    .family<List<dynamic>, String>((ref, query) async {
      if (query.isEmpty) {
        return [];
      }
      final dataSource = ref.watch(artisanDataSourceProvider);
      try {
        return await dataSource.searchArtisans(query);
      } catch (e) {
        throw Exception('Erreur: ${e.toString()}');
      }
    });

// Order Detail Provider
final orderDetailProvider = FutureProvider.autoDispose.family<dynamic, String>((
  ref,
  orderId,
) async {
  final dataSource = ref.watch(orderDataSourceProvider);
  try {
    return await dataSource.getOrderDetail(orderId);
  } catch (e) {
    throw Exception('Erreur: ${e.toString()}');
  }
});

// Payment Methods Provider
final paymentMethodsProvider = FutureProvider.autoDispose<List<dynamic>>((
  ref,
) async {
  final dataSource = ref.watch(paymentDataSourceProvider);
  try {
    return await dataSource.getPaymentMethods();
  } catch (e) {
    throw Exception('Erreur: ${e.toString()}');
  }
});

// Create Order Provider (StateNotifierProvider)
class CreateOrderNotifier extends StateNotifier<AsyncValue<dynamic>> {
  final OrderRemoteDataSource _dataSource;

  CreateOrderNotifier(this._dataSource) : super(const AsyncValue.data(null));

  Future<dynamic> createOrder(Map<String, dynamic> orderData) async {
    state = const AsyncValue.loading();
    try {
      final result = await _dataSource.createOrder(orderData);
      state = AsyncValue.data(result);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
      rethrow;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final createOrderProvider =
    StateNotifierProvider.autoDispose<CreateOrderNotifier, AsyncValue<dynamic>>(
      (ref) => CreateOrderNotifier(ref.watch(orderDataSourceProvider)),
    );

// Payment Provider (StateNotifierProvider)
class PaymentNotifier extends StateNotifier<AsyncValue<dynamic>> {
  final PaymentRemoteDataSource _dataSource;

  PaymentNotifier(this._dataSource) : super(const AsyncValue.data(null));

  Future<dynamic> initializePayment(Map<String, dynamic> paymentData) async {
    state = const AsyncValue.loading();
    try {
      final result = await _dataSource.initializePayment(paymentData);
      state = AsyncValue.data(result);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
      rethrow;
    }
  }

  Future<dynamic> verifyPayment(String transactionId) async {
    state = const AsyncValue.loading();
    try {
      final result = await _dataSource.verifyPayment(transactionId);
      state = AsyncValue.data(result);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
      rethrow;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final paymentProvider =
    StateNotifierProvider.autoDispose<PaymentNotifier, AsyncValue<dynamic>>(
      (ref) => PaymentNotifier(ref.watch(paymentDataSourceProvider)),
    );

// ----- Donations (GET /donations/me, /donations/stats, POST /donations) -----

final myDonationsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dataSource = ref.watch(donationDataSourceProvider);
  return dataSource.getMyDonations();
});

final donationStatsProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, ({String? recipientType, String? recipientId})>(
        (ref, params) async {
  final dataSource = ref.watch(donationDataSourceProvider);
  return dataSource.getDonationStats(
    recipientType: params.recipientType,
    recipientId: params.recipientId,
  );
});

final createDonationActionProvider =
    Provider<Future<Map<String, dynamic>> Function(Map<String, dynamic>)>((ref) {
  final dataSource = ref.watch(donationDataSourceProvider);
  return (Map<String, dynamic> data) => dataSource.createDonation(data);
});

// ----- Referrals (GET /referrals/me, /referrals/stats, POST /referrals/generate|validate) -----

final myReferralsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dataSource = ref.watch(referralDataSourceProvider);
  return dataSource.getMyReferrals();
});

final referralStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final dataSource = ref.watch(referralDataSourceProvider);
  return dataSource.getStats();
});

final generateReferralCodeActionProvider =
    Provider<Future<Map<String, dynamic>> Function()>((ref) {
  final dataSource = ref.watch(referralDataSourceProvider);
  return () => dataSource.generateCode();
});

// L'API n'a pas de "get my code" séparé : /referrals/generate sert aussi de
// lecture (retourne le code existant côté backend). Mis en cache ici pour ne
// pas ré-appeler l'endpoint à chaque rebuild ; ref.invalidate() pour forcer.
final myReferralCodeProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final dataSource = ref.watch(referralDataSourceProvider);
  return dataSource.generateCode();
});

final validateReferralCodeActionProvider =
    Provider<Future<Map<String, dynamic>> Function(String)>((ref) {
  final dataSource = ref.watch(referralDataSourceProvider);
  return (String code) => dataSource.validateCode(code);
});

// ----- Students (GET /students/me, POST /students, PUT /students/{id}) -----

final myStudentProfileProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final dataSource = ref.watch(studentDataSourceProvider);
  return dataSource.getMyStudentProfile();
});

final createStudentActionProvider =
    Provider<Future<Map<String, dynamic>> Function(Map<String, dynamic>)>((ref) {
  final dataSource = ref.watch(studentDataSourceProvider);
  return (Map<String, dynamic> data) => dataSource.createStudent(data);
});

final updateStudentActionProvider =
    Provider<Future<Map<String, dynamic>> Function(String, Map<String, dynamic>)>((ref) {
  final dataSource = ref.watch(studentDataSourceProvider);
  return (String studentId, Map<String, dynamic> data) => dataSource.updateStudent(studentId, data);
});

// ----- Dashboard (GET /dashboard/artisan) -----

final myArtisanDashboardProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final dataSource = ref.watch(dashboardDataSourceProvider);
  return dataSource.getMyArtisanDashboard();
});

// ----- Preferences (GET/PUT /preferences, POST /preferences/reset) -----

final preferencesProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final dataSource = ref.watch(preferencesDataSourceProvider);
  return dataSource.getPreferences();
});

final updatePreferencesActionProvider =
    Provider<Future<Map<String, dynamic>> Function(Map<String, dynamic>)>((ref) {
  final dataSource = ref.watch(preferencesDataSourceProvider);
  return (Map<String, dynamic> data) => dataSource.updatePreferences(data);
});

final resetPreferencesActionProvider =
    Provider<Future<Map<String, dynamic>> Function()>((ref) {
  final dataSource = ref.watch(preferencesDataSourceProvider);
  return () => dataSource.resetPreferences();
});

// Thème effectif de l'app, initialisé à ThemeMode.system et mis à jour
// depuis les préférences (GET /preferences) ou la feuille de préférences.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
