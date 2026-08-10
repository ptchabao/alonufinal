import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../bloc/api_providers.dart';
import '../bloc/auth_provider.dart';
import '../bloc/cart_order_provider.dart';
import '../widgets/widgets.dart';

/// Panier — regroupe les articles ajoutés depuis les fiches produit. Comme
/// CreateOrderDto (POST /orders) ne cible qu'un seul artisan par commande,
/// "Commander" crée une commande distincte par artisan représenté dans le
/// panier.
class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mon Panier',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        elevation: 0,
        backgroundColor: AppColors.background,
        actions: [
          if (cart.items.isNotEmpty)
            AppTextButton(
              label: 'Vider',
              color: AppColors.error,
              onPressed: () => ref.read(cartProvider.notifier).clearCart(),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? _buildEmptyState(context)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cart.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return _CartItemTile(item: item);
              },
            ),
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${cart.totalPrice.toStringAsFixed(0)} XOF',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: _isSubmitting ? 'Traitement...' : 'Commander',
                    isEnabled: !_isSubmitting,
                    onPressed: () => _handleOrder(context),
                    icon: Icons.check_circle_outline,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Votre panier est vide',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Découvrir le catalogue',
            onPressed: () => context.push('/catalog'),
            icon: Icons.storefront,
          ),
        ],
      ),
    );
  }

  Future<void> _handleOrder(BuildContext context) async {
    if (!ref.read(authProvider).isAuthenticated) {
      context.go('/login?redirect=${Uri.encodeComponent('/cart')}');
      return;
    }

    final deliveryAddress = await _askDeliveryAddress(context);
    if (deliveryAddress == null) return; // annulé par l'utilisateur

    final cart = ref.read(cartProvider);
    final groups = <String, List<CartItem>>{};
    for (final item in cart.items) {
      groups.putIfAbsent(item.artisanId, () => []).add(item);
    }

    setState(() => _isSubmitting = true);

    var createdCount = 0;
    try {
      for (final entry in groups.entries) {
        final payload = {
          'artisanId': entry.key,
          'items': entry.value
              .map((item) => {
                    'productId': item.productId,
                    'quantity': item.quantity,
                  })
              .toList(),
          if (deliveryAddress.isNotEmpty) 'deliveryAddress': deliveryAddress,
        };
        await ref.read(createOrderProvider.notifier).createOrder(payload);
        createdCount++;
      }

      ref.read(cartProvider.notifier).clearCart();
      if (!mounted) return;
      showSuccessSnackbar(
        context,
        createdCount > 1
            ? '$createdCount commandes créées (une par artisan)'
            : 'Commande créée',
      );
      context.go('/orders');
    } catch (e) {
      if (!mounted) return;
      showErrorSnackbar(
        context,
        createdCount > 0
            ? '$createdCount commande(s) créée(s), puis erreur: $e'
            : 'Erreur lors de la commande: $e',
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<String?> _askDeliveryAddress(BuildContext context) async {
    final controller = TextEditingController();
    return showModalBottomSheet<String>(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adresse de livraison',
                style: Theme.of(sheetContext).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Ex: 123 Rue principale, Lomé',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Valider',
                onPressed: () =>
                    Navigator.of(sheetContext).pop(controller.text.trim()),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  final CartItem item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadows,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productTitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.price.toStringAsFixed(0)} XOF',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.surfaceVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 18),
                  onPressed: () => ref
                      .read(cartProvider.notifier)
                      .updateItemQuantity(item.productId, item.quantity - 1),
                ),
                Text('${item.quantity}'),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: () => ref
                      .read(cartProvider.notifier)
                      .updateItemQuantity(item.productId, item.quantity + 1),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () =>
                ref.read(cartProvider.notifier).removeItem(item.productId),
          ),
        ],
      ),
    );
  }
}
