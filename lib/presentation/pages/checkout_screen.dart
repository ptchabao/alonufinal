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
  String? selectedDeliveryType;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? address;
  String? city;
  bool _isSubmitting = false;

  final List<String> deliveryTypes = [
    'Standard (5-7 jours)',
    'Express (2-3 jours)',
  ];
  final List<String> cities = [
    'Cotonou',
    'Abomey-Calavi',
    'Porto-Novo',
    'Parakou',
    'Djougou',
  ];

  @override
  void initState() {
    super.initState();
    selectedDeliveryType = deliveryTypes.first;
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
          const SizedBox(height: 24),
          Text(
            'Mode de livraison',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          RadioGroup<String>(
            groupValue: selectedDeliveryType,
            onChanged: (value) => setState(() => selectedDeliveryType = value),
            child: Column(
              children: deliveryTypes.map((type) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selectedDeliveryType == type
                            ? AppColors.primary
                            : AppColors.surfaceVariant,
                      ),
                    ),
                    child: RadioListTile<String>(
                      value: type,
                      title: Text(type),
                    ),
                  ),
                );
              }).toList(),
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
            'Informations de livraison',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              label: const Text('Prénom'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) => firstName = value,
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: InputDecoration(
              label: const Text('Nom'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) => lastName = value,
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: InputDecoration(
              label: const Text('Email'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => email = value,
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: InputDecoration(
              label: const Text('Téléphone'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.phone,
            onChanged: (value) => phone = value,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              label: const Text('Ville'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: cities.map((c) {
              return DropdownMenuItem(value: c, child: Text(c));
            }).toList(),
            onChanged: (value) => setState(() => city = value),
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: InputDecoration(
              label: const Text('Adresse complète'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 2,
            onChanged: (value) => address = value,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3(dynamic product) {
    final productMap = product is Map
        ? product.cast<String, dynamic>()
        : <String, dynamic>{};
    final subtotal = _extractPrice(productMap) * quantity;
    final delivery = selectedDeliveryType?.contains('Express') ?? false
        ? 10000.0
        : 5000.0;
    final total = subtotal + delivery;

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
                Text('Client', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Nom:'),
                    Text('${firstName ?? ''} ${lastName ?? ''}'.trim()),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [const Text('Email:'), Text(email ?? '')],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [const Text('Tél:'), Text(phone ?? '')],
                ),
              ],
            ),
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
                  'Livraison',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(address ?? ''),
                Text(
                  '$city - Bénin',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Sous-total:'),
                    Text('${subtotal.toStringAsFixed(0)} XOF'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Livraison:'),
                    Text('${delivery.toStringAsFixed(0)} XOF'),
                  ],
                ),
                const Divider(),
                Row(
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
    if (firstName == null ||
        firstName!.trim().isEmpty ||
        lastName == null ||
        lastName!.trim().isEmpty ||
        email == null ||
        email!.trim().isEmpty ||
        phone == null ||
        phone!.trim().isEmpty ||
        address == null ||
        address!.trim().isEmpty ||
        city == null ||
        city!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez remplir toutes les informations de livraison.',
          ),
        ),
      );
      return;
    }

    final productAsync = ref.read(productDetailProvider(widget.productId));
    final product = productAsync.value;
    final productMap = product is Map
        ? product.cast<String, dynamic>()
        : <String, dynamic>{};

    final price = _extractPrice(productMap);
    final subtotal = price * quantity;
    final delivery = selectedDeliveryType?.contains('Express') ?? false
        ? 10000.0
        : 5000.0;
    final total = subtotal + delivery;

    setState(() => _isSubmitting = true);

    try {
      final createdOrder = await ref
          .read(createOrderProvider.notifier)
          .createOrder({
            'customerName': '${firstName!.trim()} ${lastName!.trim()}',
            'customerEmail': email!.trim(),
            'customerPhone': phone!.trim(),
            'deliveryAddress': address!.trim(),
            'city': city!.trim(),
            'deliveryType': selectedDeliveryType,
            'status': 'pending',
            'subtotal': subtotal,
            'deliveryFee': delivery,
            'totalAmount': total,
            'currency': 'XOF',
            'items': [
              {
                'productId': productMap['id'] ?? widget.productId,
                'quantity': quantity,
                'unitPrice': price,
                'totalPrice': subtotal,
                'title': (productMap['title'] ?? 'Produit').toString(),
                'artisanId':
                    productMap['artisanId'] ?? productMap['artisan']?['id'],
              },
            ],
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
