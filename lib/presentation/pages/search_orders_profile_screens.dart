import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../bloc/auth_provider.dart';
import '../bloc/api_providers.dart';
import '../bloc/order_provider.dart';
import '../widgets/widgets.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/artisan_model.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/user.dart';

// Lomé, utilisé comme centre de carte par défaut quand aucun artisan géolocalisé
// n'est disponible pour recentrer la vue.
const LatLng _defaultMapCenter = LatLng(6.1725, 1.2314);

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategoryId = '';
  String _searchQuery = '';
  bool _showMap = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSearchData();
    });
  }

  Future<void> _loadSearchData() async {
    await Future.wait([
      ref.refresh(categoriesProvider.future),
      ref.refresh(artisansProvider.future),
      ref.refresh(productsProvider.future),
    ]);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final artisansAsync = ref.watch(artisansProvider);
    final productsAsync = ref.watch(productsProvider);

    final artisans = artisansAsync.value ?? [];
    final artisanNamesById = {
      for (final artisan in artisans)
        artisan.id: '${artisan.user.prenom} ${artisan.user.nom}'.trim(),
    };

    final filteredArtisans = artisans.where((artisan) {
      final fullName = '${artisan.user.prenom} ${artisan.user.nom}'
          .toLowerCase();
      final specialty = artisan.subCategories
          .map((s) => s.subCategory.libelleFr.toLowerCase())
          .join(' ');
      final matchesSearch =
          fullName.contains(_searchQuery) ||
          specialty.contains(_searchQuery) ||
          (artisan.adresse ?? '').toLowerCase().contains(_searchQuery);
      final matchesCategory =
          _selectedCategoryId.isEmpty ||
          artisan.subCategories.any(
            (s) => s.subCategory.categoryId == _selectedCategoryId,
          );
      return matchesCategory && (_searchQuery.isEmpty || matchesSearch);
    }).toList();

    final filteredProducts = (productsAsync.value ?? []).where((product) {
      final productMap = product as Map<String, dynamic>;
      final titleMatch = (productMap['title'] ?? '')
          .toString()
          .toLowerCase()
          .contains(_searchQuery);
      final descriptionMatch = (productMap['description'] ?? '')
          .toString()
          .toLowerCase()
          .contains(_searchQuery);
      return _searchQuery.isEmpty || titleMatch || descriptionMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Découvrir',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: AppColors.background,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: ScalableButton(
                onPressed: () {
                  setState(() {
                    _showMap = !_showMap;
                  });
                },
                child: Tooltip(
                  message: _showMap ? 'Vue Liste' : 'Vue Carte',
                  child: Icon(
                    _showMap ? Icons.list : Icons.map,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: (artisansAsync.isLoading || productsAsync.isLoading)
          ? const Center(child: AppLoadingIndicator())
          : _showMap
          ? _buildMapView(filteredArtisans)
          : RefreshIndicator(
              onRefresh: _loadSearchData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ===== BARRE DE RECHERCHE =====
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppColors.cardShadows,
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Artisan, service, produit...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ===== FILTRES CATÉGORIQUES =====
                  Text(
                    'Catégories',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  categoriesAsync.when(
                    data: (categories) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: categories.map((category) {
                            final selected = category.id == _selectedCategoryId;
                            final categoryLabel = category.libelleFr.isNotEmpty
                                ? category.libelleFr
                                : category.libelle;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: AppFilterChip(
                                label: categoryLabel,
                                isSelected: selected,
                                onSelected: (value) {
                                  setState(() {
                                    _selectedCategoryId = value
                                        ? category.id
                                        : '';
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                    loading: () => const SizedBox(
                      height: 54,
                      child: Center(child: AppLoadingIndicator()),
                    ),
                    error: (_, __) => Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorGradient.colors[0].withOpacity(
                          0.15,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Impossible de charger les catégories'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ===== CATALOGUE COMPLET BUTTON =====
                  AppButton(
                    label: 'Voir le catalogue complet',
                    onPressed: () => context.push('/catalog'),
                    icon: Icons.shopping_bag,
                  ),
                  const SizedBox(height: 24),

                  // ===== ARTISANS =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Artisans recommandés',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      AppTextButton(
                        label: '${filteredArtisans.length}',
                        onPressed: () {},
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (filteredArtisans.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Aucun artisan trouvé',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Essayez une autre recherche ou catégorie',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: filteredArtisans.map((artisan) {
                        final distance =
                            (artisan.latitude != null &&
                                artisan.longitude != null)
                            ? _calculateDistance(
                                6.1725,
                                1.2314,
                                artisan.latitude!,
                                artisan.longitude!,
                              )
                            : artisan.distance;

                        final rating =
                            4.5 + (artisan.subCategories.length % 3) * 0.1;
                        final reviewCount = max(
                          10,
                          artisan.subCategories.length * 12,
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ArtisanCard(
                            imageUrl:
                                artisan.user.avatar ??
                                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
                            name: '${artisan.user.prenom} ${artisan.user.nom}',
                            specialty: artisan.subCategories.isNotEmpty
                                ? artisan.subCategories
                                      .map((s) => s.subCategory.libelleFr)
                                      .join(', ')
                                : 'Artisan',
                            rating: rating,
                            reviewCount: reviewCount,
                            distance: distance != null
                                ? '${distance.toStringAsFixed(1)} km'
                                : 'Distance inconnue',
                            isMasterArtisan: artisan.actif,
                            onTap: () => context.push('/artisan/${artisan.id}'),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 24),

                  // ===== PRODUITS & SERVICES =====
                  Text(
                    'Produits & services',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  if (filteredProducts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 48,
                            color: AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Aucun produit trouvé',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product =
                            filteredProducts[index] as Map<String, dynamic>;
                        final productId = product['id']?.toString() ?? '';
                        final artisanId = product['artisanId']?.toString();
                        final viewsCount = (product['viewsCount'] ?? 0) as num;
                        final rating = 4.5 + (viewsCount.toInt() % 5) * 0.1;

                        return ProductCard(
                          imageUrl: _extractProductImageUrl(product),
                          title: (product['title'] ?? 'Produit').toString(),
                          artisanName: artisanId != null
                              ? (artisanNamesById[artisanId] ?? 'Artisan')
                              : 'Artisan',
                          price:
                              '${(product['price'] ?? 0).toStringAsFixed(0)} ${(product['currency'] ?? 'XOF').toString()}',
                          type: _extractProductType(product),
                          rating: rating,
                          onTap: () => context.push('/product/$productId'),
                        );
                      },
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildMapView(List<ArtisanModel> artisans) {
    final located = artisans
        .where((a) => a.latitude != null && a.longitude != null)
        .toList();

    final markers = located.map((artisan) {
      return Marker(
        markerId: MarkerId(artisan.id),
        position: LatLng(artisan.latitude!, artisan.longitude!),
        infoWindow: InfoWindow(
          title: '${artisan.user.prenom} ${artisan.user.nom}',
          snippet: artisan.subCategories.isNotEmpty
              ? artisan.subCategories.first.subCategory.libelleFr
              : null,
          onTap: () => context.push('/artisan/${artisan.id}'),
        ),
        onTap: () => context.push('/artisan/${artisan.id}'),
      );
    }).toSet();

    final center = located.isNotEmpty
        ? LatLng(located.first.latitude!, located.first.longitude!)
        : _defaultMapCenter;

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: center, zoom: 12),
          markers: markers,
          myLocationButtonEnabled: false,
        ),
        if (located.isEmpty)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: AppColors.cardShadows,
              ),
              child: const Text('Aucun artisan géolocalisé pour cette recherche.'),
            ),
          ),
      ],
    );
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371;
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) => degrees * pi / 180;

  String _extractProductImageUrl(Map<String, dynamic> product) {
    final rawImages = product['images'] ?? product['imageUrls'];
    if (rawImages is List) {
      for (final image in rawImages) {
        if (image is Map && image['url'] != null) {
          return AppConstants.resolveMediaUrl(image['url'].toString()) ??
              'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=300&h=300&fit=crop';
        }
        if (image is String && image.isNotEmpty) {
          return AppConstants.resolveMediaUrl(image) ??
              'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=300&h=300&fit=crop';
        }
      }
    }

    final fallbackImage = product['image'];
    if (fallbackImage != null) {
      return AppConstants.resolveMediaUrl(fallbackImage.toString()) ??
          'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=300&h=300&fit=crop';
    }

    return 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=300&h=300&fit=crop';
  }

  String _extractProductType(Map<String, dynamic> product) {
    final isService = product['isService'];
    if (isService is bool) {
      return isService ? 'SERVICE' : 'PRODUIT';
    }

    final type = product['type'];
    if (type != null) {
      return type.toString().toUpperCase();
    }

    return 'PRODUIT';
  }
}

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isArtisan = authState.user?.role == UserRole.ARTISAN;
    final ordersAsync = ref.watch(myOrdersProvider(isArtisan));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mes Commandes',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: AppColors.background,
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune commande',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Commencez vos achats!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceMuted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Découvrir les services',
                    onPressed: () => context.go('/search'),
                    icon: Icons.search,
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myOrdersProvider(isArtisan)),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = orders[index];
                final date = order.createdAt;
                return OrderStatusCard(
                  status: order.status.name.toUpperCase(),
                  date:
                      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                  description:
                      '${order.items.length} article(s) - ${order.totalAmount.toStringAsFixed(0)} ${order.currency}',
                  isCompleted: order.status == OrderStatus.COMPLETED,
                  isActive: order.status == OrderStatus.CONFIRMED ||
                      order.status == OrderStatus.IN_PROGRESS,
                  onTap: () => context.push('/orders/${order.id}'),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Erreur de chargement',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Réessayer',
                onPressed: () => ref.invalidate(myOrdersProvider(isArtisan)),
                icon: Icons.refresh,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: authState.isAuthenticated
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ===== PROFIL CARD =====
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppColors.cardShadows,
                      color: AppColors.surface,
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.badgeGradient,
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          authState.user?.fullName ?? 'Utilisateur ALONU',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          authState.user?.email ?? 'Email non disponible',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        AppBadge(
                          label:
                              authState.user?.role.name.toUpperCase() ??
                              'CLIENT',
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                          textColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ===== ARTISAN SECTION =====
                  if (authState.user?.role.name == 'ARTISAN') ...
                    [
                      Text(
                        'Mon Espace Artisan',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      _ProfileMenuItem(
                        icon: Icons.dashboard_outlined,
                        title: 'Tableau de bord',
                        onTap: () => context.push('/artisan-dashboard'),
                      ),
                      _ProfileMenuItem(
                        icon: Icons.edit_outlined,
                        title: 'Modifier mon profil',
                        onTap: () => context.push('/artisan-profile?tab=0'),
                      ),
                      _ProfileMenuItem(
                        icon: Icons.shopping_cart_outlined,
                        title: 'Mes Produits & Services',
                        onTap: () => context.push('/artisan-profile?tab=2'),
                      ),
                      _ProfileMenuItem(
                        icon: Icons.people_outline,
                        title: 'Mes Apprentis',
                        onTap: () => context.push('/artisan-profile?tab=1'),
                      ),
                      _ProfileMenuItem(
                        icon: Icons.receipt_long_outlined,
                        title: 'Mes Commandes',
                        onTap: () => context.push('/artisan-profile?tab=3'),
                      ),
                      const SizedBox(height: 24),
                    ],

                  // ===== STUDENT SECTION =====
                  if (authState.user?.role.name == 'STUDENT') ...
                    [
                      Text(
                        'Mon Espace Étudiant',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      _ProfileMenuItem(
                        icon: Icons.school_outlined,
                        title: 'Mon espace étudiant',
                        onTap: () => context.push('/student-profile'),
                      ),
                      _ProfileMenuItem(
                        icon: Icons.track_changes_outlined,
                        title: 'Suivi des cours',
                        onTap: () => context.push('/student-profile'),
                      ),
                      const SizedBox(height: 24),
                    ],

                  // ===== ACTIONS SECTION =====
                  Text(
                    'Paramètres',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  if (authState.user?.role.name != 'ARTISAN')
                    _ProfileMenuItem(
                      icon: Icons.shopping_bag_outlined,
                      title: 'Mes Commandes',
                      onTap: () => context.push('/orders'),
                    ),
                  _ProfileMenuItem(
                    icon: Icons.favorite_border,
                    title: 'Favoris',
                    onTap: () {},
                  ),
                  _ProfileMenuItem(
                    icon: Icons.location_on_outlined,
                    title: 'Adresses',
                    onTap: () {},
                  ),
                  _ProfileMenuItem(
                    icon: Icons.payment,
                    title: 'Moyens de paiement',
                    onTap: () {},
                  ),
                  _ProfileMenuItem(
                    icon: Icons.volunteer_activism_outlined,
                    title: 'Faire un don',
                    onTap: () => context.push('/donation'),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.share_outlined,
                    title: 'Programme de parrainage',
                    onTap: () => context.push('/referral'),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.tune_outlined,
                    title: 'Préférences',
                    onTap: () => showPreferencesSheet(context),
                  ),
                  const SizedBox(height: 24),

                  // ===== LOGOUT BUTTON =====
                  AppButton(
                    label: 'Se déconnecter',
                    onPressed: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                    icon: Icons.logout,
                  ),
                  const SizedBox(height: 24),

                  // ===== FOOTER =====
                  Center(
                    child: Text(
                      'ALONU v1.0.0',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.surface,
                      boxShadow: AppColors.cardShadows,
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(0.15),
                          ),
                          child: const Icon(
                            Icons.lock_outline,
                            color: AppColors.primary,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Connectez-vous pour accéder à votre profil',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Créez un compte ou connectez-vous pour suivre vos commandes, vos favoris et vos informations personnelles.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 20),
                        AppButton(
                          label: 'Se connecter',
                          onPressed: () => context.go('/login'),
                          icon: Icons.login,
                        ),
                        const SizedBox(height: 12),
                        SecondaryButton(
                          label: 'Créer un compte',
                          onPressed: () => context.go('/register'),
                          icon: Icons.person_add,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderLight, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Icon(
              Icons.arrow_forward,
              color: AppColors.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
