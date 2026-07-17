import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../pages/pages.dart';
import '../bloc/auth_provider.dart';

enum AppRoute {
  splash,
  onboarding,
  login,
  register,
  home,
  search,
  tv,
  categoryDetail,
  orders,
  orderDetail,
  payment,
  checkout,
  profile,
  catalog,
  artisanDetail,
  productDetail,
  artisanProfile,
  studentProfile,
  donation,
  referral,
  courseDetail,
  artisanDashboard,
}

class AppRouter {
  static GoRouter createRouter(bool isLoggedIn) {
    final rootNavigatorKey = GlobalKey<NavigatorState>();
    final shellNavigatorKey = GlobalKey<NavigatorState>();

    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/home',
      redirect: (context, state) {
        bool loggedIn = isLoggedIn;

        try {
          final container = ProviderScope.containerOf(context, listen: false);
          loggedIn = container.read(authProvider).isAuthenticated;
        } catch (_) {
          // Fall back to the router's provided auth state when no ProviderScope is available.
        }

        final location = state.matchedLocation;

        if (location == '/splash') {
          return '/home';
        }

        // Navigation libre (sans compte) : accueil, recherche, catalogue,
        // fiches artisan/produit/cours, publicités. Routes ci-dessous
        // réservées aux utilisateurs connectés (actions ou données propres
        // à un compte) : redirection vers /login avec retour automatique.
        const authRequiredPrefixes = [
          '/checkout',
          '/orders',
          '/donation',
          '/referral',
          '/artisan-dashboard',
          '/student-profile',
        ];
        final requiresAuth =
            authRequiredPrefixes.any((prefix) => location.startsWith(prefix));
        if (requiresAuth && !loggedIn) {
          final redirect = Uri.encodeComponent(state.uri.toString());
          return '/login?redirect=$redirect';
        }

        if (loggedIn && (location == '/login' || location == '/register')) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          name: AppRoute.splash.name,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          name: AppRoute.onboarding.name,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          name: AppRoute.login.name,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          name: AppRoute.register.name,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/catalog',
          name: AppRoute.catalog.name,
          builder: (context, state) => const ProductCatalogScreen(),
        ),
        GoRoute(
          path: '/category/:categoryId',
          name: AppRoute.categoryDetail.name,
          builder: (context, state) {
            final categoryId = state.pathParameters['categoryId']!;
            final subCategoryId = state.uri.queryParameters['subCategoryId'];
            return CategoryDetailScreen(
              categoryId: categoryId,
              initialSubcategoryId: subCategoryId,
            );
          },
        ),
        GoRoute(
          path: '/artisan/:artisanId',
          name: AppRoute.artisanDetail.name,
          builder: (context, state) {
            final artisanId = state.pathParameters['artisanId']!;
            return ArtisanDetailScreen(artisanId: artisanId);
          },
        ),
        GoRoute(
          path: '/product/:productId',
          name: AppRoute.productDetail.name,
          builder: (context, state) {
            final productId = state.pathParameters['productId']!;
            return ProductDetailScreen(productId: productId);
          },
        ),
        GoRoute(
          path: '/course/:courseId',
          name: AppRoute.courseDetail.name,
          builder: (context, state) {
            final courseId = state.pathParameters['courseId']!;
            return CourseDetailScreen(courseId: courseId);
          },
        ),
        GoRoute(
          path: '/checkout/:productId',
          name: AppRoute.checkout.name,
          builder: (context, state) {
            final productId = state.pathParameters['productId']!;
            return CheckoutScreen(productId: productId);
          },
        ),
        GoRoute(
          path: '/artisan-profile',
          name: AppRoute.artisanProfile.name,
          builder: (context, state) {
            final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
            final artisanId = state.uri.queryParameters['artisanId'];
            return ArtisanProfileEditScreen(artisanId: artisanId, initialTabIndex: tab);
          },
        ),
        GoRoute(
          path: '/student-profile',
          name: AppRoute.studentProfile.name,
          builder: (context, state) => const StudentProfileScreen(),
        ),
        GoRoute(
          path: '/donation',
          name: AppRoute.donation.name,
          builder: (context, state) {
            final params = state.uri.queryParameters;
            return DonationScreen(
              recipientType: params['recipientType'],
              recipientId: params['recipientId'],
              recipientLabel: params['recipientLabel'],
            );
          },
        ),
        GoRoute(
          path: '/referral',
          name: AppRoute.referral.name,
          builder: (context, state) => const ReferralScreen(),
        ),
        GoRoute(
          path: '/artisan-dashboard',
          name: AppRoute.artisanDashboard.name,
          builder: (context, state) => const ArtisanDashboardScreen(),
        ),
        ShellRoute(
          navigatorKey: shellNavigatorKey,
          builder: (context, state, child) {
            return MainBottomNavBar(child: child);
          },
          routes: [
            GoRoute(
              path: '/home',
              name: AppRoute.home.name,
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/tv',
              name: AppRoute.tv.name,
              builder: (context, state) => const TvScreen(),
            ),
            GoRoute(
              path: '/search',
              name: AppRoute.search.name,
              builder: (context, state) => const SearchScreen(),
            ),
            GoRoute(
              path: '/orders/:orderId',
              name: AppRoute.orderDetail.name,
              builder: (context, state) {
                final orderId = state.pathParameters['orderId']!;
                return OrderDetailScreen(orderId: orderId);
              },
            ),
            GoRoute(
              path: '/orders',
              name: AppRoute.orders.name,
              builder: (context, state) => const OrdersScreen(),
            ),
            GoRoute(
              path: '/payment/:orderId',
              name: AppRoute.payment.name,
              builder: (context, state) {
                final orderId = state.pathParameters['orderId']!;
                return PaymentScreen(orderId: orderId);
              },
            ),
            GoRoute(
              path: '/profile',
              name: AppRoute.profile.name,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    );
  }
}

final routerProvider = Provider((ref) {
  final isLoggedIn = ref.watch(authProvider).isAuthenticated;
  return AppRouter.createRouter(isLoggedIn);
});
