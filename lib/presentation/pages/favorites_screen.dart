import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/artisan_model.dart';
import '../bloc/api_providers.dart';
import '../bloc/favorites_provider.dart';
import '../widgets/widgets.dart';

/// Favoris (produits + artisans) — fonctionnalité purement locale (voir
/// favorites_provider.dart), l'API ALONU n'ayant pas de notion de wishlist.
/// Chaque ID favori est résolu via les providers de détail existants
/// (GET /artisans/{id}, GET /products/{id}).
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final hasNothing = favorites.artisanIds.isEmpty && favorites.productIds.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mes Favoris',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        elevation: 0,
        backgroundColor: AppColors.background,
      ),
      body: hasNothing
          ? _buildEmptyState(context)
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (favorites.artisanIds.isNotEmpty) ...[
                  Text('Artisans', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  ...favorites.artisanIds.map(
                    (id) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SizedBox(height: 140, child: _FavoriteArtisanTile(artisanId: id)),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (favorites.productIds.isNotEmpty) ...[
                  Text('Produits & services', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: favorites.productIds.length,
                    itemBuilder: (context, index) {
                      final productId = favorites.productIds.elementAt(index);
                      return _FavoriteProductTile(productId: productId);
                    },
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, size: 64, color: AppColors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'Aucun favori pour le moment',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              'Appuyez sur le cœur d\'un artisan ou d\'un produit pour le retrouver ici.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceMuted),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Découvrir le catalogue',
              onPressed: () => context.push('/catalog'),
              icon: Icons.storefront,
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteArtisanTile extends ConsumerWidget {
  final String artisanId;

  const _FavoriteArtisanTile({required this.artisanId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artisanAsync = ref.watch(artisanDetailProvider(artisanId));

    return Stack(
      children: [
        Positioned.fill(
          child: artisanAsync.when(
            data: (artisan) {
              final model = artisan as ArtisanModel;
              return ArtisanCard(
                imageUrl: model.user.avatar ??
                    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
                name: '${model.user.prenom} ${model.user.nom}'.trim(),
                specialty: model.subCategories.isNotEmpty
                    ? model.subCategories.map((s) => s.subCategory.libelleFr).join(', ')
                    : 'Artisan',
                rating: 4.5,
                reviewCount: 0,
                distance: model.distance != null ? '${model.distance!.toStringAsFixed(1)} km' : '',
                isMasterArtisan: model.actif,
                onTap: () => context.push('/artisan/$artisanId'),
              );
            },
            loading: () => Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: AppLoadingIndicator()),
            ),
            error: (_, __) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text('Artisan indisponible')),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => ref.read(favoritesProvider.notifier).toggleArtisan(artisanId),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.favorite, color: AppColors.accent, size: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FavoriteProductTile extends ConsumerWidget {
  final String productId;

  const _FavoriteProductTile({required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));

    return Stack(
      children: [
        Positioned.fill(
          child: productAsync.when(
            data: (product) {
              final data = product is Map<String, dynamic> ? product : <String, dynamic>{};
              return ProductCard(
                imageUrl: _extractImageUrl(data),
                title: (data['title'] ?? 'Produit').toString(),
                artisanName: 'Artisan',
                price: '${(data['price'] ?? 0).toString()} ${(data['currency'] ?? 'XOF').toString()}',
                type: (data['isService'] == true) ? 'SERVICE' : 'PRODUIT',
                rating: 4.5,
                onTap: () => context.push('/product/$productId'),
              );
            },
            loading: () => Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: AppLoadingIndicator()),
            ),
            error: (_, __) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text('Produit indisponible')),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => ref.read(favoritesProvider.notifier).toggleProduct(productId),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.favorite, color: AppColors.accent, size: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _extractImageUrl(Map<String, dynamic> product) {
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
    return 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=300&h=300&fit=crop';
  }
}
