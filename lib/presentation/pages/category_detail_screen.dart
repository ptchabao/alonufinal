import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../bloc/api_providers.dart';
import '../widgets/widgets.dart';

class CategoryDetailScreen extends ConsumerStatefulWidget {
  final String categoryId;

  const CategoryDetailScreen({Key? key, required this.categoryId})
    : super(key: key);

  @override
  ConsumerState<CategoryDetailScreen> createState() =>
      _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends ConsumerState<CategoryDetailScreen> {
  String _selectedSubcategoryId = '';

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final subcategoriesAsync = ref.watch(
      subcategoriesProvider(widget.categoryId),
    );
    final artisansAsync = ref.watch(artisansProvider);
    final productsAsync = ref.watch(productsProvider);

    String categoryName = 'Catégorie';
    for (final category in categoriesAsync.value ?? []) {
      if (category.id == widget.categoryId) {
        categoryName = category.libelleFr.isNotEmpty
            ? category.libelleFr
            : category.libelle;
        break;
      }
    }

    final subcategories = subcategoriesAsync.value ?? [];
    final artisans = artisansAsync.value ?? [];
    final products = productsAsync.value ?? [];

    final matchArtisans = artisans.where((artisan) {
      final matchesCategory = artisan.subCategories.any(
        (item) => item.subCategory.categoryId == widget.categoryId,
      );
      final matchesSubcategory =
          _selectedSubcategoryId.isEmpty ||
          artisan.subCategories.any(
            (item) => item.subCategory.id == _selectedSubcategoryId,
          );
      return matchesCategory && matchesSubcategory;
    }).toList();

    final matchProducts = products.where((product) {
      final productMap = product is Map ? product : <String, dynamic>{};
      final categoryMatch =
          (productMap['categoryId'] ?? productMap['category']?['id'])
              ?.toString() ==
          widget.categoryId;
      final subcategoryMatch =
          _selectedSubcategoryId.isEmpty ||
          (productMap['subCategoryId']?.toString() == _selectedSubcategoryId) ||
          (productMap['subCategory']?['id']?.toString() ==
              _selectedSubcategoryId);
      return categoryMatch && subcategoryMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sous-catégories',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            subcategoriesAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Text(
                    'Aucune sous-catégorie disponible pour cette catégorie.',
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: items.map((subcategory) {
                      final label = subcategory.libelleFr.isNotEmpty
                          ? subcategory.libelleFr
                          : subcategory.libelle;
                      final isSelected =
                          _selectedSubcategoryId == subcategory.id;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AppFilterChip(
                          label: label,
                          isSelected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedSubcategoryId = selected
                                  ? subcategory.id
                                  : '';
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
              loading: () =>
                  const SizedBox(height: 50, child: AppLoadingIndicator()),
              error: (err, _) => Text('Erreur: ${err.toString()}'),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Artisans de cette catégorie',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                AppTextButton(
                  label: '${matchArtisans.length}',
                  onPressed: () {},
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            artisansAsync.when(
              data: (_) {
                if (matchArtisans.isEmpty) {
                  return const Text(
                    'Aucun artisan trouvé pour cette catégorie.',
                  );
                }

                return SizedBox(
                  height: 240,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: matchArtisans.length,
                    itemBuilder: (context, index) {
                      final artisan = matchArtisans[index];
                      final specialty = artisan.subCategories.isNotEmpty
                          ? artisan.subCategories
                                .map((item) => item.subCategory.libelleFr)
                                .join(', ')
                          : 'Artisan';

                      return SizedBox(
                        width: 200,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ArtisanCard(
                            imageUrl: artisan.user.avatar ?? '',
                            name: '${artisan.user.prenom} ${artisan.user.nom}'
                                .trim(),
                            specialty: specialty,
                            rating:
                                4.5 + (artisan.subCategories.length % 3) * 0.1,
                            reviewCount: artisan.subCategories.length * 12,
                            distance: artisan.distance != null
                                ? '${artisan.distance!.toStringAsFixed(1)} km'
                                : 'Distance inconnue',
                            isMasterArtisan: artisan.actif,
                            onTap: () => context.push('/artisan/${artisan.id}'),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const SizedBox(
                height: 240,
                child: Center(child: AppLoadingIndicator()),
              ),
              error: (err, _) => Text('Erreur artisans: ${err.toString()}'),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Produits liés',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                AppTextButton(
                  label: '${matchProducts.length}',
                  onPressed: () {},
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            productsAsync.when(
              data: (_) {
                if (matchProducts.isEmpty) {
                  return const Text(
                    'Aucun produit trouvé pour cette sélection.',
                  );
                }

                return SizedBox(
                  height: 260,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: matchProducts.length,
                    itemBuilder: (context, index) {
                      final product = matchProducts[index];
                      final productMap = product is Map
                          ? product
                          : <String, dynamic>{};
                      final price = (productMap['price'] ?? 0).toString();

                      return SizedBox(
                        width: 200,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ProductCard(
                            imageUrl: AppConstants.resolveMediaUrl(
                                  (productMap['images'] is List &&
                                          (productMap['images'] as List).isNotEmpty)
                                      ? (productMap['images'][0]['url'] ??
                                                productMap['images'][0])
                                            .toString()
                                      : productMap['image']?.toString(),
                                ) ??
                                'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=300&h=300&fit=crop',
                            title: (productMap['title'] ?? 'Produit')
                                .toString(),
                            artisanName: 'Artisan',
                            price: '$price XOF',
                            type: (productMap['type'] ?? 'PRODUIT')
                                .toString()
                                .toUpperCase(),
                            rating: 4.5,
                            onTap: () =>
                                context.push('/product/${productMap['id']}'),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const SizedBox(
                height: 260,
                child: Center(child: AppLoadingIndicator()),
              ),
              error: (err, _) => Text('Erreur produits: ${err.toString()}'),
            ),
          ],
        ),
      ),
    );
  }
}
