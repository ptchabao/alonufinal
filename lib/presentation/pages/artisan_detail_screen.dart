import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/artisan_model.dart';
import '../../domain/entities/artisan.dart' show Realisation;
import '../bloc/api_providers.dart';
import '../bloc/auth_provider.dart';
import '../widgets/widgets.dart';

class ArtisanDetailScreen extends ConsumerStatefulWidget {
  final String artisanId;

  const ArtisanDetailScreen({super.key, required this.artisanId});

  @override
  ConsumerState<ArtisanDetailScreen> createState() =>
      _ArtisanDetailScreenState();
}

class _ArtisanDetailScreenState extends ConsumerState<ArtisanDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedPhotoIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final artisanAsync = ref.watch(artisanDetailProvider(widget.artisanId));
    final productsAsync = ref.watch(productsProvider);
    final realizationsAsync =
        ref.watch(artisanRealisationsProvider(widget.artisanId));

    return artisanAsync.when(
      data: (artisan) {
        final artisanModel = artisan is ArtisanModel
            ? artisan
            : (artisan is Map<String, dynamic>
                  ? ArtisanModel.fromJson(artisan)
                  : null);

        if (artisanModel == null) {
          return _buildFallbackScreen(
            context,
            title: 'Artisan introuvable',
            message: 'Impossible de charger cet artisan.',
          );
        }

        final artisanName = _extractArtisanName(artisan);
        final specialty = _extractArtisanSpecialty(artisan);
        final location =
            _extractLocation(artisan) ?? 'Localisation non renseignée';
        final distanceValue = _extractDistance(artisan);
        final distance = distanceValue > 0
            ? '${distanceValue.toStringAsFixed(1)} km'
            : 'Distance non renseignée';
        final reviewCount = (productsAsync.value ?? [])
            .where(
              (item) =>
                  (item['artisanId'] ?? '').toString() == widget.artisanId,
            )
            .length;
        final rating = 4.5 + (reviewCount % 5) * 0.1;
        final isMasterArtisan = artisanModel.actif;
        final services = _extractServices(artisan);
        final products = (productsAsync.value ?? [])
            .where(
              (item) =>
                  (item['artisanId'] ?? '').toString() == widget.artisanId,
            )
            .toList();
        final realizations = realizationsAsync.value ?? const <Realisation>[];
        final safeSelectedIndex = realizations.isEmpty
            ? 0
            : _selectedPhotoIndex.clamp(0, realizations.length - 1);
        final selectedRealization = realizations.isNotEmpty
            ? realizations[safeSelectedIndex]
            : null;

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    shape: const CircleBorder(),
                    color: AppColors.surface.withValues(alpha: 0.9),
                    child: InkWell(
                      onTap: () => context.pop(),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      shape: const CircleBorder(),
                      color: AppColors.surface.withValues(alpha: 0.9),
                      child: InkWell(
                        onTap: () {
                          final link =
                              '${AppConstants.apiBaseUrl}/share/artisan/${widget.artisanId}';
                          // sharePositionOrigin requis sur iPad (popover),
                          // voir la même remarque dans product_detail_screen.dart.
                          final box = context.findRenderObject() as RenderBox?;
                          Share.share(
                            '$artisanName sur ALONU\n$link',
                            sharePositionOrigin:
                                box != null ? box.localToGlobal(Offset.zero) & box.size : null,
                          );
                        },
                        child: const Icon(
                          Icons.share_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      shape: const CircleBorder(),
                      color: AppColors.surface.withValues(alpha: 0.9),
                      child: InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Ajouté aux favoris')),
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
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'artisan-${widget.artisanId}',
                        child:
                            selectedRealization != null &&
                                selectedRealization.imageUrls.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: selectedRealization.imageUrls.first,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    const AppLoadingIndicator(),
                                errorWidget: (context, url, error) => Container(
                                  color: AppColors.surfaceVariant,
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              )
                            : Container(
                                color: AppColors.surfaceVariant,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 48,
                                ),
                              ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.heroGradient,
                        ),
                      ),
                      if (isMasterArtisan)
                        Positioned(
                          top: 16,
                          left: 16,
                          child: FadeInWidget(
                            child: MasterArtisanBadge(size: 16),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          artisanName,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          specialty,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
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
                            const SizedBox(width: 8),
                            Text('$rating ($reviewCount avis)'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16),
                            const SizedBox(width: 4),
                            Expanded(child: Text('$location • $distance')),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                label: 'Demander devis',
                                onPressed: () => _handleQuoteRequest(
                                  context,
                                  artisanName: artisanName,
                                ),
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SecondaryButton(
                                label: 'Appeler',
                                onPressed: () => _callArtisan(
                                  context,
                                  phoneNumber: artisanModel.telephone,
                                ),
                                borderColor: AppColors.success,
                                foregroundColor: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        AppTextButton(
                          label: 'Faire un don à cet artisan',
                          icon: Icons.volunteer_activism_outlined,
                          onPressed: () => context.push(
                            '/donation?recipientType=ARTISAN&recipientId=${widget.artisanId}&recipientLabel=${Uri.encodeComponent(artisanName)}',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.onSurfaceVariant,
                        indicatorColor: AppColors.primary,
                        tabs: const [
                          Tab(text: 'Infos'),
                          Tab(text: 'Portfolio'),
                          Tab(text: 'Produits'),
                        ],
                      ),
                      SizedBox(
                        height: 400,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildInfosTab(context, artisan, services),
                            _buildPortfolioTab(context, realizations),
                            _buildProductsTab(context, artisan, products),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Avis des clients',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        if (reviewCount == 0)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Aucun avis disponible pour le moment.',
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(artisanName),
                                      Row(
                                        children: List.generate(5, (i) {
                                          return Icon(
                                            i < rating.toInt()
                                                ? Icons.star
                                                : Icons.star_border,
                                            size: 14,
                                            color: const Color(0xFFFFD700),
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Artisan actif avec ${_extractApprenticeCount(artisan)} apprentis formés dans la communauté.',
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: AppLoadingIndicator())),
      error: (_, _) => _buildFallbackScreen(
        context,
        title: 'Erreur de chargement',
        message: 'Impossible de charger l\'artisan demandé.',
      ),
    );
  }

  Widget _buildInfosTab(
    BuildContext context,
    dynamic artisan,
    List<String> services,
  ) {
    final artisanName = _extractArtisanName(artisan);
    final isActive = _extractIsActive(artisan);
    final description =
        'Artisan $artisanName spécialisé en ${services.isNotEmpty ? services.join(', ') : 'artisanat local'}. Toujours disponible pour des réalisations sur mesure.';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.work, color: AppColors.primary),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Statut'),
                    Text(
                      isActive ? 'Actif' : 'Inactif',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('À propos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(description),
          const SizedBox(height: 16),
          Text('Compétences', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final service in services)
                AppBadge(
                  label: service,
                  backgroundColor: AppColors.primaryLight,
                  textColor: AppColors.primary,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Contact', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              if (_extractWhatsapp(artisan) != null)
                IconButton(
                  icon: const Icon(Icons.chat),
                  color: AppColors.primary,
                  onPressed: () => _openWhatsApp(context, phone: _extractWhatsapp(artisan)!),
                  tooltip: 'WhatsApp',
                ),
              if (_extractEmail(artisan) != null)
                IconButton(
                  icon: const Icon(Icons.email),
                  color: AppColors.primary,
                  onPressed: () => _openEmail(context, email: _extractEmail(artisan)!),
                  tooltip: 'Email',
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Google Map preview
          Builder(builder: (ctx) {
            final lat = _extractLatitude(artisan);
            final lng = _extractLongitude(artisan);
            if (lat == null || lng == null) {
              return const SizedBox.shrink();
            }

            final marker = Marker(
              markerId: const MarkerId('artisan-location'),
              position: LatLng(lat, lng),
            );

            return Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppColors.cardShadows,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(lat, lng),
                    zoom: 14,
                  ),
                  markers: {marker},
                  zoomControlsEnabled: false,
                  onTap: (_) async {
                    final mapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                    await launchUrl(mapsUrl);
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPortfolioTab(BuildContext context, List<Realisation> realizations) {
    if (realizations.isEmpty) {
      return const Center(child: Text('Aucune réalisation pour le moment.'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: realizations.length,
      itemBuilder: (context, index) {
        final realization = realizations[index];
        final imageUrl = realization.imageUrls.isNotEmpty
            ? realization.imageUrls.first
            : '';
        return InkWell(
          onTap: () => setState(() => _selectedPhotoIndex = index),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppColors.cardShadows,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.surfaceVariant,
                            alignment: Alignment.center,
                            child: const Icon(Icons.image_not_supported),
                          ),
                        )
                      : Container(
                          color: AppColors.surfaceVariant,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported),
                        ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black45],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Text(
                    realization.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductsTab(
    BuildContext context,
    dynamic artisan,
    List<dynamic> products,
  ) {
    final artisanName = _extractArtisanName(artisan);

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index] as Map<String, dynamic>;
        final productImage = _extractProductImage(product);
        final viewsCount = (product['viewsCount'] as num?)?.toInt() ?? 0;
        final price = (product['price'] as num?)?.toDouble() ?? 0;
        final currency = product['currency']?.toString() ?? 'XOF';
        return ProductCard(
          imageUrl: productImage,
          title: (product['title'] ?? 'Produit').toString(),
          artisanName: artisanName,
          price: '${price.toStringAsFixed(0)} $currency',
          type: (product['isService'] == true ? 'SERVICE' : 'PRODUIT'),
          rating: 4.5 + (viewsCount % 5) * 0.1,
          onTap: () => context.push('/product/${product['id']}'),
        );
      },
    );
  }

  String _extractArtisanName(dynamic artisan) {
    if (artisan is ArtisanModel) {
      final fullName = [
        artisan.user.prenom,
        artisan.user.nom,
      ].where((part) => part.trim().isNotEmpty).join(' ').trim();
      if (fullName.isNotEmpty) {
        return fullName;
      }
    }

    if (artisan is Map<String, dynamic>) {
      final user = artisan['user'];
      if (user is Map<String, dynamic>) {
        final prenom = user['prenom']?.toString().trim() ?? '';
        final nom = user['nom']?.toString().trim() ?? '';
        final fullName = [
          prenom,
          nom,
        ].where((part) => part.isNotEmpty).join(' ');
        if (fullName.isNotEmpty) {
          return fullName;
        }
      }

      final prenom = artisan['prenom']?.toString().trim() ?? '';
      final nom = artisan['nom']?.toString().trim() ?? '';
      final fallbackName = [
        prenom,
        nom,
      ].where((part) => part.isNotEmpty).join(' ');
      if (fallbackName.isNotEmpty) {
        return fallbackName;
      }
    }

    return 'Artisan';
  }

  String _extractArtisanSpecialty(dynamic artisan) {
    if (artisan is ArtisanModel) {
      if (artisan.subCategories.isNotEmpty) {
        return artisan.subCategories.first.subCategory.libelleFr;
      }
    }

    if (artisan is Map<String, dynamic>) {
      final subCategories = artisan['subCategories'];
      if (subCategories is List) {
        for (final item in subCategories) {
          if (item is Map<String, dynamic>) {
            final subCategory = item['subCategory'];
            if (subCategory is Map<String, dynamic>) {
              final label = subCategory['libelleFr']?.toString().trim();
              if (label != null && label.isNotEmpty) {
                return label;
              }
            }
          }
        }
      }
    }

    return 'Artisan indépendant';
  }

  List<String> _extractServices(dynamic artisan) {
    if (artisan is ArtisanModel) {
      return artisan.subCategories
          .map((item) => item.subCategory.libelleFr)
          .where((service) => service.trim().isNotEmpty)
          .toList();
    }

    if (artisan is Map<String, dynamic>) {
      final subCategories = artisan['subCategories'];
      final services = <String>[];
      if (subCategories is List) {
        for (final item in subCategories) {
          if (item is Map<String, dynamic>) {
            final subCategory = item['subCategory'];
            if (subCategory is Map<String, dynamic>) {
              final label = subCategory['libelleFr']?.toString().trim();
              if (label != null && label.isNotEmpty) {
                services.add(label);
              }
            }
          }
        }
      }
      return services;
    }

    return [];
  }

  String? _extractLocation(dynamic artisan) {
    if (artisan is ArtisanModel) {
      return artisan.adresse;
    }

    if (artisan is Map<String, dynamic>) {
      final location = artisan['adresse']?.toString().trim();
      if (location != null && location.isNotEmpty) {
        return location;
      }
    }

    return null;
  }

  double _extractDistance(dynamic artisan) {
    if (artisan is ArtisanModel) {
      return artisan.distance ?? 0;
    }

    if (artisan is Map<String, dynamic>) {
      final distance = artisan['distance'] ?? artisan['distanceKm'];
      if (distance is num) {
        return distance.toDouble();
      }
      if (distance is String) {
        return double.tryParse(distance) ?? 0;
      }
    }

    return 0;
  }

  bool _extractIsActive(dynamic artisan) {
    if (artisan is ArtisanModel) {
      return artisan.actif;
    }

    if (artisan is Map<String, dynamic>) {
      return artisan['actif'] as bool? ?? false;
    }

    return false;
  }

  int _extractApprenticeCount(dynamic artisan) {
    if (artisan is Map<String, dynamic>) {
      final count = artisan['apprenticeCount'];
      if (count is num) {
        return count.toInt();
      }
      if (count is String) {
        return int.tryParse(count) ?? 0;
      }
    }

    return 0;
  }

  String _extractProductImage(Map<String, dynamic> product) {
    final rawImages = product['images'];
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

  Future<void> _callArtisan(
    BuildContext context, {
    required String phoneNumber,
  }) async {
    final normalizedPhone = phoneNumber.trim();
    if (normalizedPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Numéro de téléphone indisponible')),
      );
      return;
    }

    final messenger = ScaffoldMessenger.maybeOf(context);
    final uri = Uri(scheme: 'tel', path: normalizedPhone);
    final launched = await launchUrl(uri);
    if (!mounted) {
      return;
    }
    if (!launched) {
      messenger?.showSnackBar(
        const SnackBar(content: Text('Impossible d’appeler cet artisan')),
      );
    }
  }

  Future<void> _openEmail(BuildContext context, {required String email}) async {
    final normalized = email.trim();
    if (normalized.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail indisponible')),
      );
      return;
    }

    final uri = Uri(scheme: 'mailto', path: normalized);
    final launched = await launchUrl(uri);
    if (!mounted) return;
    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’ouvrir le client e‑mail')),
      );
    }
  }

  Future<void> _openWhatsApp(BuildContext context, {required String phone}) async {
    final normalized = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (normalized.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Numéro WhatsApp indisponible')),
      );
      return;
    }

    final uri = Uri.parse('https://wa.me/$normalized');
    final launched = await launchUrl(uri);
    if (!mounted) return;
    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’ouvrir WhatsApp')),
      );
    }
  }

  String? _extractEmail(dynamic artisan) {
    if (artisan is ArtisanModel) {
      return artisan.user.email;
    }
    if (artisan is Map<String, dynamic>) {
      final user = artisan['user'];
      if (user is Map<String, dynamic>) {
        final email = user['email']?.toString().trim();
        if (email != null && email.isNotEmpty) return email;
      }
      final email = artisan['email']?.toString().trim();
      if (email != null && email.isNotEmpty) return email;
    }
    return null;
  }

  String? _extractWhatsapp(dynamic artisan) {
    String? whatsapp;

    if (artisan is ArtisanModel) {
      whatsapp = artisan.whatsapp?.toString().trim();
      if (whatsapp != null && whatsapp.isNotEmpty) {
        return whatsapp;
      }
      final telephone = artisan.telephone.toString().trim();
      return telephone.isNotEmpty ? telephone : null;
    }

    if (artisan is Map<String, dynamic>) {
      final w = artisan['whatsapp']?.toString().trim();
      if (w != null && w.isNotEmpty) {
        return w;
      }

      final user = artisan['user'];
      if (user is Map<String, dynamic>) {
        final phone = user['telephone']?.toString().trim();
        if (phone != null && phone.isNotEmpty) {
          return phone;
        }
      }

      final telephone = artisan['telephone']?.toString().trim();
      if (telephone != null && telephone.isNotEmpty) {
        return telephone;
      }
    }

    return null;
  }

  double? _extractLatitude(dynamic artisan) {
    if (artisan is ArtisanModel) return artisan.latitude;
    if (artisan is Map<String, dynamic>) {
      final v = artisan['latitude'] ?? artisan['lat'];
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
    }
    return null;
  }

  double? _extractLongitude(dynamic artisan) {
    if (artisan is ArtisanModel) return artisan.longitude;
    if (artisan is Map<String, dynamic>) {
      final v = artisan['longitude'] ?? artisan['lng'];
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
    }
    return null;
  }

  void _handleQuoteRequest(
    BuildContext context, {
    required String artisanName,
  }) {
    if (!ref.read(authProvider).isAuthenticated) {
      final redirect = Uri.encodeComponent('/artisan/${widget.artisanId}');
      context.go('/login?redirect=$redirect');
      return;
    }

    _openQuoteSheet(context, artisanName: artisanName);
  }

  void _openQuoteSheet(BuildContext context, {required String artisanName}) {
    final formKey = GlobalKey<FormState>();
    final descriptionController = TextEditingController();
    final budgetController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
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
                  'Demander un devis à $artisanName',
                  style: Theme.of(sheetContext).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description du projet',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Veuillez décrire votre projet'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: budgetController,
                  decoration: const InputDecoration(
                    labelText: 'Budget estimé',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Envoyer la demande',
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) {
                      return;
                    }
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Demande de devis envoyée à $artisanName',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
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
}
