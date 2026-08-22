import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../bloc/api_providers.dart';
import '../widgets/widgets.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final String productId;

  const CheckoutScreen({super.key, required this.productId});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _currentStep = 0;
  int quantity = 1;
  final TextEditingController _addressController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));
    final createOrderState = ref.watch(createOrderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Commander'),
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
      body: productAsync.when(
        data: (product) {
          if (product == null) {
            return const Center(child: Text('Produit indisponible'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: List.generate(3, (index) {
                    final isActive = index <= _currentStep;
                    const stepLabels = ['Articles', 'Adresse', 'Résumé'];
                    return Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.surfaceVariant,
                            ),
                            child: Center(
                              child: isActive
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : Text('${index + 1}'),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            stepLabels[index],
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const Divider(),
              Expanded(
                child: IndexedStack(
                  index: _currentStep,
                  children: [
                    _buildStep1(product),
                    _buildStep2(),
                    _buildStep3(product),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (err, _) => Center(child: Text('Erreur: ${err.toString()}')),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: SecondaryButton(
                  label: 'Précédent',
                  isEnabled: !(_isSubmitting || createOrderState.isLoading),
                  onPressed: () {
                    setState(() => _currentStep--);
                  },
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                label: _isSubmitting || createOrderState.isLoading
                    ? 'Traitement...'
                    : (_currentStep == 2 ? 'Payer' : 'Suivant'),
                isEnabled: !(_isSubmitting || createOrderState.isLoading),
                onPressed: () {
                  _handleNext();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1(dynamic product) {
    final productMap = product is Map
        ? product.cast<String, dynamic>()
        : <String, dynamic>{};
    final title = (productMap['title'] ?? productMap['name'] ?? 'Produit')
        .toString();
    final price = _extractPrice(productMap);
    final artisanName = _extractArtisanName(productMap);
    final description = (productMap['description'] ?? '').toString();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Détails du produit',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppColors.cardShadows,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    AppBadge(
                      label: '${price.toStringAsFixed(0)} XOF',
                      backgroundColor: AppColors.primary,
                      textColor: Colors.white,
                    ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Artisan:'),
                    Text(
                      artisanName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Quantité:'),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            if (quantity > 1) setState(() => quantity--);
                          },
                        ),
                        Text('$quantity'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => setState(() => quantity++),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:'),
                    Text(
                      '${(price * quantity).toStringAsFixed(0)} XOF',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Adresse de livraison',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              label: const Text('Adresse complète'),
              hintText: 'Ex: 123 Rue principale, Lomé',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3(dynamic product) {
    final productMap = product is Map
        ? product.cast<String, dynamic>()
        : <String, dynamic>{};
    final total = _extractPrice(productMap) * quantity;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Résumé de la commande',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adresse de livraison',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(_addressController.text),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${total.toStringAsFixed(0)} XOF',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNext() async {
    if (_currentStep == 2) {
      await _submitOrder();
    } else {
      setState(() => _currentStep++);
    }
  }

  Future<void> _submitOrder() async {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez renseigner une adresse de livraison.'),
        ),
      );
      return;
    }

    final productAsync = ref.read(productDetailProvider(widget.productId));
    final product = productAsync.value;
    final productMap = product is Map
        ? product.cast<String, dynamic>()
        : <String, dynamic>{};

    final artisanId = (productMap['artisanId'] ?? productMap['artisan']?['id'])
        ?.toString();
    if (artisanId == null || artisanId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Artisan introuvable pour ce produit.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final createdOrder = await ref
          .read(createOrderProvider.notifier)
          .createOrder({
            'artisanId': artisanId,
            'items': [
              {
                'productId': productMap['id'] ?? widget.productId,
                'quantity': quantity,
              },
            ],
            'deliveryAddress': _addressController.text.trim(),
          });

      final orderId = _extractOrderId(createdOrder);
      if (orderId == null) {
        throw Exception('Impossible de récupérer l’identifiant de la commande');
      }

      if (mounted) {
        context.push('/payment/$orderId');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de commande: ${error.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  double _extractPrice(Map<String, dynamic> product) {
    final rawPrice =
        product['price'] ?? product['unitPrice'] ?? product['amount'];
    if (rawPrice is num) {
      return rawPrice.toDouble();
    }
    if (rawPrice is String) {
      return double.tryParse(rawPrice) ?? 0;
    }
    return 0;
  }

  String _extractArtisanName(Map<String, dynamic> product) {
    final artisan = product['artisan'];
    if (artisan is Map) {
      final artisanMap = artisan.cast<String, dynamic>();
      final artisanName = artisanMap['name'] ?? artisanMap['fullName'];
      if (artisanName != null) {
        return artisanName.toString();
      }
      final firstName = artisanMap['firstName'] ?? '';
      final lastName = artisanMap['lastName'] ?? '';
      final fullName = '$firstName $lastName'.trim();
      if (fullName.isNotEmpty) {
        return fullName;
      }
    }

    final artisanName = product['artisanName'];
    if (artisanName != null) {
      return artisanName.toString();
    }

    return 'Artisan';
  }

  String? _extractOrderId(dynamic order) {
    if (order == null) {
      return null;
    }

    if (order is Map) {
      final directId = order['id'] ?? order['orderId'];
      if (directId != null) {
        return directId.toString();
      }

      final nestedData = order['data'];
      if (nestedData is Map) {
        final nestedId = nestedData['id'] ?? nestedData['orderId'];
        if (nestedId != null) {
          return nestedId.toString();
        }
      }
    }

    final stringValue = order.toString();
    return stringValue.isNotEmpty ? stringValue : null;
  }
}
