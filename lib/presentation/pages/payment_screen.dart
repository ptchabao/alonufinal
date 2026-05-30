import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../bloc/api_providers.dart';
import '../widgets/widgets.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String orderId;

  const PaymentScreen({super.key, required this.orderId});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  int _step = 0;
  String? selectedOperator;
  String phoneNumber = '';

  final Map<String, Map<String, String>> fallbackOperators = {
    'FLOOZ': {
      'image': '🟠',
      'desc': 'Paiement FLOOZ - MTN Bénin',
      'prefix': '+229',
    },
    'TMONEY': {
      'image': '🟡',
      'desc': 'Paiement TMONEY - Moov Bénin',
      'prefix': '+229',
    },
  };

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderDetailProvider(widget.orderId));
    final paymentMethodsAsync = ref.watch(paymentMethodsProvider);

    final orderData = orderAsync.value;
    final paymentMethods = paymentMethodsAsync.value ?? [];
    final operatorOptions = _normalizeOperators(paymentMethods);
    final displayAmount = _extractAmount(orderData);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement'),
        leading: _step < 3
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  shape: const CircleBorder(),
                  color: AppColors.surface,
                  child: InkWell(
                    onTap: () {
                      if (_step == 0) {
                        context.pop();
                      } else {
                        setState(() => _step--);
                      }
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              )
            : null,
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(
        index: _step,
        children: [
          _buildOperatorSelection(operatorOptions),
          _buildPhoneInput(operatorOptions, displayAmount),
          _buildProcessing(displayAmount),
          _buildSuccess(displayAmount),
        ],
      ),
    );
  }

  Widget _buildOperatorSelection(List<Map<String, dynamic>> operatorOptions) {
    final available = operatorOptions.isEmpty
        ? fallbackOperators.entries
              .map(
                (entry) => {
                  'key': entry.key,
                  'display': entry.key,
                  'description': entry.value['desc'],
                  'emoji': entry.value['image'],
                },
              )
              .toList()
        : operatorOptions;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choisissez votre opérateur',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Sélectionnez le moyen de paiement mobile money',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          ...available.map((entry) {
            final key = entry['key'].toString();
            final displayName = entry['display']?.toString() ?? key;
            final description = entry['description']?.toString() ?? '';
            final emoji = entry['emoji']?.toString() ?? '💳';
            final isSelected = selectedOperator == key;

            return GestureDetector(
              onTap: () => setState(() => selectedOperator = key),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceVariant,
                      width: isSelected ? 2 : 1,
                    ),
                    color: isSelected
                        ? AppColors.primaryLight
                        : Colors.transparent,
                    boxShadow: isSelected ? AppColors.cardShadows : [],
                  ),
                  child: Row(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 40)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'Continuer',
              isEnabled: selectedOperator != null,
              onPressed: () {
                setState(() => _step = 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInput(
    List<Map<String, dynamic>> operatorOptions,
    double amount,
  ) {
    final available = operatorOptions.isEmpty
        ? fallbackOperators.entries
              .map(
                (entry) => {
                  'key': entry.key,
                  'display': entry.key,
                  'emoji': entry.value['image'],
                  'prefix': entry.value['prefix'],
                },
              )
              .toList()
        : operatorOptions;

    final currentOperator = available.firstWhere(
      (entry) => entry['key'].toString() == selectedOperator,
      orElse: () =>
          available.isNotEmpty ? available.first : <String, dynamic>{},
    );
    final prefix = (currentOperator['prefix'] ?? '+229').toString();
    final emoji = (currentOperator['emoji'] ?? '💳').toString();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Numéro de téléphone',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Entrez votre numéro ${selectedOperator ?? 'opérateur'}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.phone,
                    maxLength: 8,
                    decoration: InputDecoration(
                      prefix: Text('$prefix '),
                      border: InputBorder.none,
                      hintText: '97 XX XX XX',
                      hintStyle: TextStyle(color: AppColors.onSurfaceVariant),
                      counterText: '',
                    ),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (value) => setState(() => phoneNumber = value),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary),
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Vous recevrez un code USSD à confirmer',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'Confirmer',
              isEnabled: phoneNumber.length == 8,
              onPressed: () {
                _processPayment();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessing(double amount) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLoadingIndicator(),
            const SizedBox(height: 24),
            Text(
              'Traitement du paiement',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Veuillez patienter...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
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
                    'Commande: ${widget.orderId}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Opérateur: ${selectedOperator ?? ""}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Montant: ${amount.toStringAsFixed(0)} XOF',
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess(double amount) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SuccessAnimation(onComplete: () {}),
            const SizedBox(height: 24),
            Text(
              'Paiement réussi!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Votre commande a été confirmée',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Commande:'),
                      Text(
                        widget.orderId,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Montant:'),
                      Text(
                        '${amount.toStringAsFixed(0)} XOF',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Statut:'),
                      AppBadge(
                        label: 'Payée',
                        backgroundColor: AppColors.secondary,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Voir ma commande',
                onPressed: () => context.go('/orders'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: SecondaryButton(
                label: 'Retourner à l\'accueil',
                onPressed: () => context.go('/home'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (selectedOperator == null || phoneNumber.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez sélectionner un opérateur et saisir un numéro valide.',
          ),
        ),
      );
      return;
    }

    final orderData = ref.read(orderDetailProvider(widget.orderId)).value;
    final amount = _extractAmount(orderData);

    setState(() => _step = 2);

    try {
      final response = await ref
          .read(paymentProvider.notifier)
          .initializePayment({
            'orderId': widget.orderId,
            'paymentMethod': selectedOperator,
            'phoneNumber': phoneNumber,
            'amount': amount,
            'currency': 'XOF',
          });

      final status = _extractPaymentStatus(response);
      if (status == 'success' || status == 'paid') {
        if (mounted) {
          setState(() => _step = 3);
        }
      } else {
        if (mounted) {
          setState(() => _step = 1);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Paiement non confirmé: ${response.toString()}'),
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() => _step = 1);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de paiement: ${error.toString()}')),
        );
      }
    }
  }

  List<Map<String, dynamic>> _normalizeOperators(List<dynamic> methods) {
    if (methods.isEmpty) {
      return [];
    }

    return methods.map((method) {
      if (method is Map) {
        final code =
            (method['code'] ??
                    method['provider'] ??
                    method['name'] ??
                    'PAYMENT')
                .toString();
        final label =
            (method['label'] ?? method['name'] ?? method['provider'] ?? code)
                .toString();
        final description = (method['description'] ?? 'Paiement mobile')
            .toString();
        final prefix = (method['prefix'] ?? '+229').toString();

        return {
          'key': code,
          'display': label,
          'description': description,
          'prefix': prefix,
          'emoji': _emojiForOperator(code),
        };
      }

      return {
        'key': method.toString(),
        'display': method.toString(),
        'description': 'Paiement mobile',
        'prefix': '+229',
        'emoji': '💳',
      };
    }).toList();
  }

  String _emojiForOperator(String key) {
    switch (key.toUpperCase()) {
      case 'FLOOZ':
        return '🟠';
      case 'TMONEY':
        return '🟡';
      default:
        return '💳';
    }
  }

  double _extractAmount(dynamic order) {
    if (order == null) {
      return 0;
    }
    if (order is Map) {
      final amount = order['totalAmount'] ?? order['amount'] ?? order['price'];
      if (amount is num) return amount.toDouble();
      if (amount is String) return double.tryParse(amount) ?? 0;
    }
    return 0;
  }

  String _extractPaymentStatus(dynamic response) {
    if (response == null) {
      return 'pending';
    }
    if (response is Map) {
      final status =
          response['status'] ?? response['paymentStatus'] ?? response['state'];
      if (status != null) {
        return status.toString().toLowerCase();
      }
    }
    return 'pending';
  }
}
