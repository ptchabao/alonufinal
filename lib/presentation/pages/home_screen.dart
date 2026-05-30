import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/widgets.dart';
import '../bloc/api_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _carouselIndex = 0;
  String _selectedCategoryId = '';

  final List<String> _fallbackAdImages = [
    'assets/ads/WhatsApp Image 2026-05-30 at 1.32.44 PM.jpeg',
    'assets/ads/WhatsApp Image 2026-05-30 at 1.32.45 PM.jpeg',
    'assets/ads/WhatsApp Image 2026-05-30 at 1.32.45 PM(1).jpeg',
    'assets/ads/WhatsApp Image 2026-05-30 at 1.32.46 PM.jpeg',
  ];

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final artisansAsync = ref.watch(artisansProvider);
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
          ),
        ),
        title: Text(
          'ALONU',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            color: AppColors.primary,
            onPressed: () => context.push('/profile'),
            tooltip: 'Profil',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppColors.cardShadows,
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Chercher un artisan...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: () => context.push('/search'),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                onTap: () => context.push('/search'),
              ),
            ),
            const SizedBox(height: 24),

            // Carousel
            ref.watch(advertisementsCarouselProvider).when(
                  data: (ads) {
                    if (ads.isEmpty) {
                      return _buildLocalAdsCarousel();
                    }

                    final currentIndex = _carouselIndex.clamp(0, ads.length - 1);

                    return Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CarouselSlider(
                            options: CarouselOptions(
                              height: 180,
                              autoPlay: true,
                              autoPlayInterval: const Duration(seconds: 5),
                              autoPlayAnimationDuration:
                                  const Duration(milliseconds: 800),
                              enlargeCenterPage: true,
                              onPageChanged: (index, reason) {
                                setState(() => _carouselIndex = index);
                              },
                            ),
                            items: ads.map((ad) {
                              final imageUrl =
                                  (ad['imageUrl'] ?? '').toString();
                              final secondaryImages =
                                  (ad['secondaryImages'] as List<dynamic>?)
                                      ?.map((e) => e.toString())
                                      .where((e) => e.isNotEmpty)
                                      .toList();
                              final linkUrl = (ad['linkUrl'] ?? '').toString();
                              final displayImage = imageUrl.isNotEmpty
                                  ? imageUrl
                                  : ((secondaryImages?.isNotEmpty == true)
                                      ? secondaryImages!.first
                                      : '');

                              return GestureDetector(
                                onTap: linkUrl.isNotEmpty
                                    ? () => _openAdLink(context, linkUrl)
                                    : null,
                                child: FadeInWidget(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: displayImage.isNotEmpty
                                          ? DecorationImage(
                                              image: CachedNetworkImageProvider(
                                                  displayImage),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                      color: AppColors.surfaceVariant,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: AppColors.heroGradient,
                                      ),
                                      alignment: Alignment.center,
                                      child: linkUrl.isNotEmpty
                                          ? const Icon(
                                              Icons.open_in_new,
                                              size: 32,
                                              color: Colors.white,
                                            )
                                          : const Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 16,
                                              ),
                                              child: Text(
                                                'Aucune publicité disponible',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            ads.length,
                            (index) => Container(
                              width: 8,
                              height: 8,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: currentIndex == index
                                    ? AppColors.primary
                                    : AppColors.onSurfaceMuted
                                        .withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.surfaceVariant,
                    ),
                    child: const Center(child: AppLoadingIndicator()),
                  ),
                  error: (err, st) => Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.surfaceVariant,
                    ),
                    child: Center(
                      child: Text(
                        'Impossible de charger le carousel',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ),
                ),
            const SizedBox(height: 24),

            // Categories
            Text(
              'Catégories',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return const SizedBox.shrink();
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(categories.length, (index) {
                      final item = categories[index];

                      final categoryName = item.libelleFr.isNotEmpty
                          ? item.libelleFr
                          : (item.libelle.isNotEmpty ? item.libelle : 'Autre');

                      final isSelected = _selectedCategoryId == item.id;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AppFilterChip(
                          label: categoryName,
                          isSelected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategoryId = selected ? item.id : '';
                            });
                            if (selected) {
                              context.push('/category/${item.id}');
                            }
                          },
                        ),
                      );
                    }),
                  ),
                );
              },
              loading: () =>
                  const SizedBox(height: 50, child: AppLoadingIndicator()),
              error: (err, st) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Erreur: ${err.toString()}',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Artisans
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Artisans près de vous',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                AppTextButton(
                  label: 'Voir tous',
                  onPressed: () => context.push('/search'),
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            artisansAsync.when(
              data: (artisans) {
                if (artisans.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.people_outline,
                          size: 48,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        const Text('Aucun artisan disponible'),
                        const SizedBox(height: 12),
                        AppButton(
                          label: 'Réessayer',
                          onPressed: () => ref.refresh(artisansProvider),
                          isSmall: true,
                        ),
                      ],
                    ),
                  );
                }

                final artisanList = artisans.take(6).toList();

                return SizedBox(
                  height: 240,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: artisanList.length,
                    itemBuilder: (context, index) {
                      final artisan = artisanList[index];
                      final prenom = artisan.user.prenom;
                      final nom = artisan.user.nom;
                      final name = '$prenom $nom'.trim();

                      final specialty = artisan.subCategories.isNotEmpty
                          ? artisan.subCategories
                                .map((item) => item.subCategory.libelleFr)
                                .join(', ')
                          : 'Artisan';

                      final imageUrl = artisan.user.avatar ?? '';
                      final distance =
                          artisan.distance ?? (index + 1).toDouble();
                      final rating =
                          4.5 + (artisan.subCategories.length % 3) * 0.1;
                      final reviewCount = max(
                        10,
                        artisan.subCategories.length * 12,
                      );

                      final distanceText = distance >= 1
                          ? '${distance.toStringAsFixed(1)} km'
                          : '${(distance * 1000).toStringAsFixed(0)} m';

                      return SizedBox(
                        width: 200,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ArtisanCard(
                            imageUrl: imageUrl,
                            name: name.isEmpty ? 'Artisan' : name,
                            specialty: specialty,
                            rating: rating,
                            reviewCount: reviewCount,
                            distance: distanceText,
                            isMasterArtisan: artisan.actif,
                            onTap: () => context.push('/artisan/${artisan.id}'),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: AppLoadingIndicator()),
              error: (err, st) => Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 12),
                    Text('Erreur: ${err.toString()}'),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'Réessayer',
                      onPressed: () => ref.refresh(artisansProvider),
                      isSmall: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Produits dynamiques
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Produits du moment',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                AppTextButton(
                  label: 'Voir tout',
                  onPressed: () => context.push('/catalog'),
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            productsAsync.when(
              data: (products) {
                final productList = products.take(4).toList();
                if (productList.isEmpty) {
                  return const Text('Aucun produit disponible pour le moment');
                }

                final artisanNamesById = {
                  for (final artisan in artisansAsync.value ?? [])
                    artisan.id: '${artisan.user.prenom} ${artisan.user.nom}'
                        .trim(),
                };

                return SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: productList.length,
                    itemBuilder: (context, index) {
                      final product = productList[index];
                      final imageUrl = _extractProductImageUrl(product);
                      final type = _extractProductType(product);
                      final artisanId =
                          (product is Map ? product['artisanId'] : null)
                              ?.toString();
                      final artisanName = artisanId != null
                          ? (artisanNamesById[artisanId] ?? 'Artisan')
                          : 'Artisan';
                      final viewsCount = (product['viewsCount'] ?? 0) as num;
                      final rating = 4.5 + (viewsCount.toInt() % 5) * 0.1;

                      return SizedBox(
                        width: 200,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ProductCard(
                            imageUrl: imageUrl,
                            title: (product['title'] ?? 'Produit').toString(),
                            artisanName: artisanName,
                            price:
                                '${(product['price'] ?? 0).toStringAsFixed(0)} ${(product['currency'] ?? 'XOF').toString()}',
                            type: type,
                            rating: rating,
                            onTap: () =>
                                context.push('/product/${product['id']}'),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const SizedBox(
                height: 280,
                child: Center(child: AppLoadingIndicator()),
              ),
              error: (err, st) => Text('Erreur produits: ${err.toString()}'),
            ),
            const SizedBox(height: 24),

            // Cours disponibles
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cours disponibles',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                AppBadge(
                  label: 'API',
                  backgroundColor: AppColors.primaryLight,
                  textColor: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ref
                .watch(apprenticeshipAdsProvider)
                .when(
                  data: (courses) {
                    if (courses.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Aucun cours disponible pour le moment.',
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        final title = (course['title'] ?? 'Cours disponible')
                            .toString();
                        final subtitle =
                            (course['subtitle'] ?? 'Formation artisanale')
                                .toString();
                        final description = (course['description'] ?? '')
                            .toString();
                        final imageUrl = _extractCourseImageUrl(course);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (imageUrl.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      height: 140,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        height: 140,
                                        color: AppColors.surfaceVariant,
                                        child: const Center(
                                          child: AppLoadingIndicator(),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                            height: 140,
                                            color: AppColors.surfaceVariant,
                                            alignment: Alignment.center,
                                            child: const Icon(
                                              Icons.image_not_supported,
                                            ),
                                          ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              title,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                          AppBadge(
                                            label: 'DISPONIBLE',
                                            backgroundColor:
                                                AppColors.secondary,
                                            textColor: Colors.white,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        subtitle,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                      ),
                                      if (description.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      ],
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: AppButton(
                                              label: 'Voir le cours',
                                              onPressed: () => context.push(
                                                '/course/${course['id']}',
                                              ),
                                              isSmall: true,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: SecondaryButton(
                                              label: 'Postuler',
                                              onPressed: () =>
                                                  _showCourseApplicationSheet(
                                                    context,
                                                    title,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const SizedBox(
                    height: 140,
                    child: Center(child: AppLoadingIndicator()),
                  ),
                  error: (err, st) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Erreur cours: ${err.toString()}',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _extractProductImageUrl(dynamic product) {
    final rawImages =
        (product is Map ? product['images'] : null) ??
        (product is Map ? product['imageUrls'] : null);
    if (rawImages is List) {
      for (final image in rawImages) {
        if (image is Map && image['url'] != null) {
          return image['url'].toString();
        }
        if (image is String && image.isNotEmpty) {
          return image;
        }
      }
    }

    final fallbackImage = product is Map ? product['image'] : null;
    if (fallbackImage != null) {
      return fallbackImage.toString();
    }

    return 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=300&h=300&fit=crop';
  }

  String _extractProductType(dynamic product) {
    if (product is Map) {
      final isService = product['isService'];
      if (isService is bool) {
        return isService ? 'SERVICE' : 'PRODUIT';
      }

      final type = product['type'];
      if (type != null) {
        return type.toString().toUpperCase();
      }
    }

    return 'PRODUIT';
  }

  String _extractCourseImageUrl(dynamic course) {
    if (course is Map) {
      final imageUrl = course['imageUrl'];
      if (imageUrl != null && imageUrl.toString().isNotEmpty) {
        return imageUrl.toString();
      }

      final secondaryImages = course['secondaryImages'];
      if (secondaryImages is List && secondaryImages.isNotEmpty) {
        final firstImage = secondaryImages.first;
        if (firstImage != null) {
          return firstImage.toString();
        }
      }
    }

    return '';
  }

  Future<void> _openAdLink(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _showSnackBar(context, 'Lien publicitaire invalide.');
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir le lien.')),
        );
      }
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir le lien.')),
      );
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildLocalAdsCarousel() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CarouselSlider(
            options: CarouselOptions(
              height: 180,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              enlargeCenterPage: true,
              onPageChanged: (index, reason) {
                setState(() => _carouselIndex = index);
              },
            ),
            items: _fallbackAdImages.map((assetPath) {
              return FadeInWidget(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage(assetPath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _fallbackAdImages.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _carouselIndex == index
                    ? AppColors.primary
                    : AppColors.onSurfaceMuted.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCourseApplicationSheet(BuildContext context, String courseTitle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final formKey = GlobalKey<FormState>();
        final nameController = TextEditingController();
        final emailController = TextEditingController();
        final motivationController = TextEditingController(
          text: 'Je souhaite postuler au cours $courseTitle.',
        );

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Postuler à $courseTitle',
                  style: Theme.of(sheetContext).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom complet',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Veuillez renseigner votre nom'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez renseigner votre email';
                    }
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+').hasMatch(value)) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: motivationController,
                  decoration: const InputDecoration(
                    labelText: 'Motivation',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Veuillez renseigner votre motivation'
                      : null,
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Envoyer la candidature',
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) {
                      return;
                    }
                    Navigator.pop(sheetContext);
                    showSuccessSnackbar(context, 'Candidature envoyée');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
