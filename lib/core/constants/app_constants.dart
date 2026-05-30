class AppConstants {
  static const String appName = 'ALONU';
  static const String apiBaseUrl = 'https://api.alonu.shop/api';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String getUserEndpoint = '/users/me';
  static const String categoriesEndpoint = '/categories';
  static const String artisansEndpoint = '/artisans';
  static const String productsEndpoint = '/products';
  static const String ordersEndpoint = '/orders';
  static const String paymentsEndpoint = '/payments';
  static const String advertisementsCarouselEndpoint = '/advertisements/carousel';
  static const String apprenticeshipAdsEndpoint =
      '/advertisements/apprenticeship/public';
  static const String countriesEndpoint = '/countries';

  // Pagination
  static const int pageSize = 20;

  // Network timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  // Local storage keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String onboardingCompleteKey = 'onboarding_complete';

  // Feature flags
  static const bool enableOfflineMode = false; // DISABLED - security critical
  static const bool enableNotifications = true;
}
