import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../bloc/api_providers.dart';
import '../widgets/widgets.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderDetailProvider(widget.orderId));

    return orderAsync.when(
      data: (order) {
        final orderData = order is Map<String, dynamic>
            ? order
            : <String, dynamic>{};

        if (orderData.isEmpty) {
          return _buildFallbackScreen(
            context,
            title: 'Commande introuvable',
            message: 'Impossible de charger cette commande.',
          );
        }

        final artisanId = orderData['artisanId']?.toString() ?? '';
        final artisanAsync = ref.watch(artisanDetailProvider(artisanId));
        final items = (orderData['items'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .toList();
        final subtotal = items.fold<double>(
          0,
          (sum, item) => sum + (item['totalPrice'] as num? ?? 0).toDouble(),
        );
        final totalAmount = (orderData['totalAmount'] as num?)?.toDouble() ?? 0;
        final currency = orderData['currency']?.toString() ?? 'XOF';
        final delivery = (totalAmount - subtotal).clamp(0, double.infinity);
        final createdAt =
            DateTime.tryParse(orderData['createdAt']?.toString() ?? '') ??
            DateTime.now();
        final updatedAt =
            DateTime.tryParse(orderData['updatedAt']?.toString() ?? '') ??
            createdAt;
        final status = orderData['status']?.toString().toUpperCase() ?? 'PENDING';
        final deliveryAddress =
            orderData['deliveryAddress']?.toString() ??
            'Adresse non renseignée';
        final isBranchedOff = status == 'DISPUTED' || status == 'CANCELLED';

        final timeline = [
          {
            'label': 'Commandé',
            'date': _formatDate(createdAt),
            'completed': _isStatusAtLeast(status, 'PENDING'),
          },
          {
            'label': 'Confirmée',
            'date': _formatDate(updatedAt),
            'completed': _isStatusAtLeast(status, 'CONFIRMED'),
          },
          {
            'label': 'En cours',
            'date': _formatDate(updatedAt),
            'completed': _isStatusAtLeast(status, 'IN_PROGRESS'),
          },
          {
            'label': 'Livrée',
            'date': _formatDate(updatedAt),
            'completed': _isStatusAtLeast(status, 'DELIVERED'),
          },
          {
            'label': 'Terminée',
            'date': _formatDate(updatedAt),
            'completed': _isStatusAtLeast(status, 'COMPLETED'),
          },
        ];

        final currentStatusIndex = timeline.indexWhere(
          (step) => step['completed'] == false,
        );
        final currentIndex = currentStatusIndex == -1
            ? timeline.length - 1
            : currentStatusIndex;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Commande #${orderData['orderNumber'] ?? orderData['id']}',
            ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Statut de la commande',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getStatusLabel(status),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      AppBadge(
                        label: _formatDate(createdAt),
                        backgroundColor: AppColors.primaryLight,
                        textColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                if (status == 'DISPUTED')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.gavel, color: AppColors.error),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Litige en cours — un administrateur va examiner votre réclamation.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (status == 'CANCELLED')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.cancel_outlined, color: AppColors.onSurfaceVariant),
                          SizedBox(width: 12),
                          Expanded(child: Text('Cette commande a été annulée.')),
                        ],
                      ),
                    ),
                  ),
                const Divider(height: 1),
                if (!isBranchedOff)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Suivi de la commande',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(timeline.length, (index) {
                          final item = timeline[index];
                          final isCompleted = item['completed'] as bool;
                          final isCurrent = index == currentIndex;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isCompleted
                                            ? AppColors.secondary
                                            : AppColors.surfaceVariant,
                                        border: isCurrent
                                            ? Border.all(
                                                color: AppColors.primary,
                                                width: 3,
                                              )
                                            : null,
                                      ),
                                      child: Center(
                                        child: isCompleted
                                            ? const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 20,
                                              )
                                            : const Icon(
                                                Icons.schedule,
                                                size: 20,
                                              ),
                                      ),
                                    ),
                                    if (index < timeline.length - 1)
                                      Container(
                                        width: 2,
                                        height: 30,
                                        color: isCompleted
                                            ? AppColors.secondary
                                            : AppColors.surfaceVariant,
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['label'] as String,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        if ((item['date'] as String).isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: Text(
                                              item['date'] as String,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: AppColors
                                                        .onSurfaceVariant,
                                                  ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Produits commandés',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      ...items.map((item) {
                        final totalPrice =
                            (item['totalPrice'] as num?)?.toDouble() ?? 0;
                        final quantity =
                            (item['quantity'] as num?)?.toInt() ?? 0;
                        final productId = item['productId']?.toString() ?? '';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: AppColors.cardShadows,
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?w=300&h=300&fit=crop',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Produit #$productId',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleSmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Qté: $quantity',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${totalPrice.toStringAsFixed(0)} ${orderData['currency'] ?? 'XOF'}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Artisan',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      artisanAsync.when(
                        data: (artisan) {
                          final artisanName = _extractArtisanName(artisan);
                          final specialty = _extractArtisanSpecialty(artisan);

                          return Container(
                            padding: const EdgeInsets.all(16),
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
                                    '/artisan/${orderData['artisanId']}',
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        loading: () => const AppLoadingIndicator(),
                        error: (_, _) => Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('Artisan indisponible'),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Adresse de livraison',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 20,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    deliveryAddress,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Livraison standard • ${_formatDate(updatedAt)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Sous-total'),
                            Text('${subtotal.toStringAsFixed(0)} $currency'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Livraison'),
                            Text('${delivery.toStringAsFixed(0)} $currency'),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '${totalAmount.toStringAsFixed(0)} $currency',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppButton(
                        label: 'Contacter l\'artisan',
                        isEnabled: !_isSubmitting,
                        onPressed: () => _contactArtisan(artisanAsync.value),
                        icon: Icons.message,
                      ),
                      if (status == 'DELIVERED') ...[
                        const SizedBox(height: 12),
                        AppButton(
                          label: 'Confirmer la réception',
                          isEnabled: !_isSubmitting,
                          onPressed: () => _confirmDelivery(widget.orderId),
                          icon: Icons.check_circle_outline,
                        ),
                        const SizedBox(height: 12),
                        SecondaryButton(
                          label: 'Signaler un problème',
                          isEnabled: !_isSubmitting,
                          onPressed: () => _disputeOrder(context, widget.orderId),
                        ),
                      ] else if (status == 'PENDING' || status == 'CONFIRMED') ...[
                        const SizedBox(height: 12),
                        SecondaryButton(
                          label: 'Annuler la commande',
                          isEnabled: !_isSubmitting,
                          onPressed: () => _cancelOrder(context, widget.orderId),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: AppLoadingIndicator())),
      error: (_, _) => _buildFallbackScreen(
        context,
        title: 'Erreur de chargement',
        message: 'Impossible de charger la commande demandée.',
      ),
    );
  }

  Future<void> _contactArtisan(dynamic artisan) async {
    final whatsapp = artisan is Map ? artisan['whatsapp']?.toString() : null;
    final telephone = artisan is Map ? artisan['telephone']?.toString() : null;
    final rawNumber = (whatsapp?.isNotEmpty ?? false) ? whatsapp : telephone;

    if (rawNumber == null || rawNumber.isEmpty) {
      if (!mounted) return;
      showErrorSnackbar(context, 'Numéro de contact indisponible');
      return;
    }

    final digitsOnly = rawNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$digitsOnly');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      showErrorSnackbar(context, 'Impossible d\'ouvrir WhatsApp');
    }
  }

  Future<void> _confirmDelivery(String orderId) async {
    setState(() => _isSubmitting = true);
    try {
      final confirmDelivery = ref.read(confirmOrderDeliveryActionProvider);
      await confirmDelivery(orderId);
      ref.invalidate(orderDetailProvider(orderId));
      if (!mounted) return;
      showSuccessSnackbar(context, 'Réception confirmée, merci !');
    } catch (e) {
      if (!mounted) return;
      showErrorSnackbar(context, 'Erreur: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _disputeOrder(BuildContext context, String orderId) async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Signaler un problème'),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Décrivez le problème rencontré avec cette livraison',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(reasonController.text.trim()),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );

    if (reason == null || reason.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      final dispute = ref.read(disputeOrderActionProvider);
      await dispute(orderId, reason);
      ref.invalidate(orderDetailProvider(orderId));
      if (!mounted) return;
      showSuccessSnackbar(context, 'Litige ouvert, un administrateur va intervenir');
    } catch (e) {
      if (!mounted) return;
      showErrorSnackbar(context, 'Erreur: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _cancelOrder(BuildContext context, String orderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Annuler la commande'),
        content: const Text('Voulez-vous vraiment annuler cette commande ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSubmitting = true);
    try {
      final cancelOrder = ref.read(cancelOrderActionProvider);
      await cancelOrder(orderId);
      ref.invalidate(orderDetailProvider(orderId));
      if (!mounted) return;
      showSuccessSnackbar(context, 'Commande annulée');
    } catch (e) {
      if (!mounted) return;
      showErrorSnackbar(context, 'Erreur: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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

  bool _isStatusAtLeast(String currentStatus, String targetStatus) {
    final statusRank = {
      'PENDING': 0,
      'CONFIRMED': 1,
      'IN_PROGRESS': 2,
      'DELIVERED': 3,
      'COMPLETED': 4,
    };

    // DISPUTED/CANCELLED sont des branches, pas des étapes de la timeline
    // linéaire : on les traite comme "tout est en attente" ici — l'appelant
    // affiche un bandeau dédié dans ce cas plutôt que la timeline.
    final currentRank = statusRank[currentStatus.toUpperCase()];
    final targetRank = statusRank[targetStatus.toUpperCase()] ?? 0;
    if (currentRank == null) return false;

    return currentRank >= targetRank;
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'En attente';
      case 'CONFIRMED':
        return 'Confirmée';
      case 'IN_PROGRESS':
        return 'En cours';
      case 'DELIVERED':
        return 'Livrée';
      case 'COMPLETED':
        return 'Terminée';
      case 'DISPUTED':
        return 'Litige';
      case 'CANCELLED':
        return 'Annulée';
      default:
        return 'En attente';
    }
  }

  String _extractArtisanName(dynamic artisan) {
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
      final fullName = [prenom, nom].where((part) => part.isNotEmpty).join(' ');
      if (fullName.isNotEmpty) {
        return fullName;
      }
    }

    return 'Artisan';
  }

  String _extractArtisanSpecialty(dynamic artisan) {
    if (artisan is Map<String, dynamic>) {
      final specialty = artisan['specialty']?.toString().trim();
      if (specialty != null && specialty.isNotEmpty) {
        return specialty;
      }

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

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}
