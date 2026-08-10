import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../bloc/api_providers.dart';
import '../bloc/auth_provider.dart';
import '../widgets/widgets.dart';

/// "Gagnez un cadeau" — met en avant les produits à prix zéro (créés par les
/// artisans/admin via POST /products avec price: 0) et permet de les réclamer
/// en une commande gratuite (POST /orders, montant total 0, aucun paiement).
class GiftScreen extends ConsumerStatefulWidget {
  const GiftScreen({super.key});

  @override
  ConsumerState<GiftScreen> createState() => _GiftScreenState();
}

class _GiftScreenState extends ConsumerState<GiftScreen> {
  final Set<String> _revealed = {};
  bool _isClaiming = false;

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '🎁 Gagnez un cadeau',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        elevation: 0,
        backgroundColor: AppColors.background,
      ),
      body: productsAsync.when(
        data: (products) {
          final gifts = products.where((product) {
            final map = product as Map;
            final price = (map['price'] as num?)?.toDouble() ?? 0;
            return price <= 0;
          }).toList();

          if (gifts.isEmpty) {
            return _buildEmptyState(context);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.heroGradient,
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Touchez un cadeau pour le révéler, puis réclamez-le '
                    'gratuitement !',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: gifts.length,
                  itemBuilder: (context, index) {
                    final gift = (gifts[index] as Map).cast<String, dynamic>();
                    final id = gift['id']?.toString() ?? index.toString();
                    return _GiftCard(
                      product: gift,
                      isRevealed: _revealed.contains(id),
                      isClaiming: _isClaiming,
                      onReveal: () => setState(() => _revealed.add(id)),
                      onClaim: () => _claimGift(context, gift),
                    );
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (err, _) => Center(child: Text('Erreur: ${err.toString()}')),
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
            const Icon(Icons.card_giftcard, size: 64, color: AppColors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'Aucun cadeau disponible pour le moment',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Revenez bientôt : les artisans ajoutent régulièrement de '
              'nouveaux produits offerts.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _claimGift(BuildContext context, Map<String, dynamic> gift) async {
    if (!ref.read(authProvider).isAuthenticated) {
      context.go('/login?redirect=${Uri.encodeComponent('/gifts')}');
      return;
    }

    final artisanId = gift['artisanId']?.toString();
    final productId = gift['id']?.toString();
    if (artisanId == null || productId == null) {
      showErrorSnackbar(context, 'Cadeau indisponible');
      return;
    }

    setState(() => _isClaiming = true);
    try {
      final order = await ref.read(createOrderProvider.notifier).createOrder({
        'artisanId': artisanId,
        'items': [
          {'productId': productId, 'quantity': 1},
        ],
      });

      final orderId = order is Map ? (order['id'] ?? order['orderId'])?.toString() : null;
      if (!mounted) return;
      showSuccessSnackbar(context, 'Cadeau réclamé !');
      if (orderId != null) {
        context.push('/orders/$orderId');
      } else {
        context.push('/orders');
      }
    } catch (e) {
      if (!mounted) return;
      showErrorSnackbar(context, 'Erreur: $e');
    } finally {
      if (mounted) setState(() => _isClaiming = false);
    }
  }
}

class _GiftCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isRevealed;
  final bool isClaiming;
  final VoidCallback onReveal;
  final VoidCallback onClaim;

  const _GiftCard({
    required this.product,
    required this.isRevealed,
    required this.isClaiming,
    required this.onReveal,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: isRevealed ? _buildRevealed(context) : _buildHidden(context),
      ),
    );
  }

  Widget _buildHidden(BuildContext context) {
    return InkWell(
      key: const ValueKey('hidden'),
      onTap: onReveal,
      child: Container(
        decoration: BoxDecoration(gradient: AppColors.badgeGradient),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.card_giftcard, size: 48, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              'Toucher pour révéler',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevealed(BuildContext context) {
    final title = (product['title'] ?? 'Cadeau').toString();
    final imageUrl = _extractImageUrl(product);

    return Column(
      key: const ValueKey('revealed'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1.4,
          child: imageUrl.isNotEmpty
              ? CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover)
              : Container(
                  color: AppColors.surfaceVariant,
                  child: const Icon(Icons.card_giftcard, size: 40),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              AppBadge(
                label: 'GRATUIT',
                backgroundColor: AppColors.secondary,
                textColor: Colors.white,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: isClaiming ? '...' : 'Réclamer',
                  isSmall: true,
                  isEnabled: !isClaiming,
                  onPressed: onClaim,
                ),
              ),
            ],
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
          return AppConstants.resolveMediaUrl(image['url'].toString()) ?? '';
        }
        if (image is String && image.isNotEmpty) {
          return AppConstants.resolveMediaUrl(image) ?? '';
        }
      }
    }
    return '';
  }
}
