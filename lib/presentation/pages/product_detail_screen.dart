import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/artisan_model.dart';
import '../bloc/api_providers.dart';
import '../bloc/auth_provider.dart';
import '../widgets/widgets.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _selectedImageIndex = 0;
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));

    return productAsync.when(
      data: (product) {
        final productData = product is Map<String, dynamic>
            ? product
            : <String, dynamic>{};

        if (productData.isEmpty) {
          return _buildFallbackScreen(
            context,
            title: 'Produit introuvable',
            message: 'Impossible de charger ce produit.',
          );
        }

        final artisanId = productData['artisanId']?.toString() ?? '';
        final artisanAsync = ref.watch(artisanDetailProvider(artisanId));
        final images = _extractProductImages(productData);
        final fallbackImage = images.isNotEmpty
            ? images.first
            : 'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?w=600&h=600&fit=crop';
        final selectedImage = images.isNotEmpty
            ? images[_selectedImageIndex.clamp(0, images.length - 1)]
            : fallbackImage;
        final viewsCount = (productData['viewsCount'] as num?)?.toInt() ?? 0;
        final rating = 4.5 + (viewsCount % 5) * 0.1;
        final reviewCount = viewsCount;
        final price = (productData['price'] as num?)?.toDouble() ?? 0;
        final currency = productData['currency']?.toString() ?? 'XOF';
        final createdAt =
            DateTime.tryParse(productData['createdAt']?.toString() ?? '') ??
            DateTime.now();

        final specs = [
          {'label': 'Type', 'value': _productTypeLabel(productData)},
          {'label': 'Prix', 'value': '${price.toStringAsFixed(0)} $currency'},
          {'label': 'Vues', 'value': '$viewsCount'},
          {'label': 'Créé le', 'value': _formatDate(createdAt)},
        ];

        return Scaffold(
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                shape: const CircleBorder(),
                color: AppColors.surface,
                child: InkWell(
                  onTap: () => context.pop(),
                  child: const Icon(Icons.arrow_back, color: AppColors.primary),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  shape: const CircleBorder(),
                  color: AppColors.surface,
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Produit ajouté aux favoris'),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.favorite_border,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Hero(
                      tag: 'product-${widget.productId}',
                      child: CachedNetworkImage(
                        imageUrl: selectedImage,
                        fit: BoxFit.cover,
                        height: 350,
                        width: double.infinity,
                        placeholder: (context, url) =>
                            const AppLoadingIndicator(),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.surfaceVariant,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedImageIndex = index),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _selectedImageIndex == index
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: AppColors.cardShadows,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: images[index],
                                  fit: BoxFit.cover,
                                  width: 80,
                                  placeholder: (context, url) =>
                                      const AppLoadingIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        color: AppColors.surfaceVariant,
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          size: 16,
                                        ),
                                      ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppBadge(
                        label: _productTypeLabel(productData),
                        backgroundColor: AppColors.primaryLight,
                        textColor: AppColors.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        productData['title']?.toString() ?? 'Produit',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${price.toStringAsFixed(0)} $currency',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Row(
                            children: [
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < rating.toInt()
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: const Color(0xFFFFD700),
                                    size: 18,
                                  );
                                }),
                              ),
                              const SizedBox(width: 4),
                              Text('($reviewCount)'),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      artisanAsync.when(
                        data: (artisan) {
                          final artisanModel = artisan is ArtisanModel
                              ? artisan
                              : (artisan is Map<String, dynamic>
                                    ? ArtisanModel.fromJson(artisan)
                                    : null);
                          final artisanEntity = artisanModel?.toEntity();
                          final artisanName = artisanEntity != null
                              ? '${artisanEntity.user.prenom} ${artisanEntity.user.nom}'
                                    .trim()
                              : 'Artisan';
                          final specialty =
                              artisanEntity != null &&
                                  artisanEntity.subCategories.isNotEmpty
                              ? artisanEntity
                                    .subCategories
                                    .first
                                    .subCategory
                                    .libelleFr
                              : 'Artisan indépendant';

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.primary,
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        artisanName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        specialty,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                AppTextButton(
                                  label: 'Voir',
                                  onPressed: () => context.push(
                                    '/artisan/${productData['artisanId']}',
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        loading: () => const AppLoadingIndicator(),
                        error: (_, _) => Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('Artisan indisponible'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (productData['description'] ??
                                'Aucune description disponible.')
                            .toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Caractéristiques',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.5,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: specs.length,
                        itemBuilder: (context, index) {
                          final spec = specs[index];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  spec['label']!,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  spec['value']!,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.surfaceVariant),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (_quantity > 1) setState(() => _quantity--);
                        },
                      ),
                      Text('$_quantity'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'Commander',
                    onPressed: () {
                      if (!ref.read(authProvider).isAuthenticated) {
                        final redirect = Uri.encodeComponent(
                          '/checkout/${widget.productId}',
                        );
                        context.go('/login?redirect=$redirect');
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$_quantity articles ajoutés')),
                      );
                      context.push('/checkout/${widget.productId}');
                    },
                    icon: Icons.shopping_cart,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: AppLoadingIndicator())),
      error: (_, _) => _buildFallbackScreen(
        context,
        title: 'Erreur de chargement',
        message: 'Impossible de charger le produit demandé.',
      ),
    );
  }

  Scaffold _buildFallbackScreen(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            shape: const CircleBorder(),
            color: AppColors.surface,
            child: InkWell(
              onTap: () => context.pop(),
              child: const Icon(Icons.arrow_back, color: AppColors.primary),
            ),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _extractProductImages(Map<String, dynamic> product) {
    final rawImages = product['images'];
    final extracted = <String>[];

    if (rawImages is List) {
      for (final image in rawImages) {
        if (image is Map && image['url'] != null) {
          extracted.add(image['url'].toString());
        } else if (image is String && image.isNotEmpty) {
          extracted.add(image);
        }
      }
    }

    if (extracted.isEmpty && product['imageUrls'] is List) {
      for (final image in product['imageUrls'] as List) {
        if (image is String && image.isNotEmpty) {
          extracted.add(image);
        }
      }
    }

    if (extracted.isEmpty && product['image'] != null) {
      extracted.add(product['image'].toString());
    }

    return extracted
        .map((e) => AppConstants.resolveMediaUrl(e) ?? e)
        .toList();
  }

  String _productTypeLabel(Map<String, dynamic> product) {
    if (product['isService'] is bool) {
      return product['isService'] == true ? 'SERVICE' : 'PRODUIT';
    }

    final type = product['type']?.toString().toUpperCase();
    if (type != null && type.isNotEmpty) {
      return type;
    }

    return 'PRODUIT';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}
