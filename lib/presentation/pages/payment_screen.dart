import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../bloc/api_providers.dart';
import '../widgets/widgets.dart';

/// Écran de paiement PayGate générique — réutilisé pour le paiement d'une
/// commande, d'un abonnement (artisan/étudiant) et d'une adhésion
/// microfinance. PayGate étant asynchrone (push USSD sur le téléphone du
/// client), [initiate] renvoie un `paymentId` que cet écran suit ensuite par
/// polling (`GET /payments/{paymentId}/status`) jusqu'à COMPLETED/FAILED.
class PaymentScreen extends ConsumerStatefulWidget {
  final String title;
  final String reference;
  final double? amount;
  final String currency;
  final Future<Map<String, dynamic>> Function(String phoneNumber, String network) initiate;
  final VoidCallback onSuccess;

  const PaymentScreen({
    super.key,
    required this.title,
    required this.reference,
    required this.amount,
    required this.initiate,
    required this.onSuccess,
    this.currency = 'XOF',
  });

  /// Construit un écran de paiement pour une commande — GET /orders/{id} pour
  /// le montant, POST /payments/order/{orderId}/initiate pour l'initiation.
  factory PaymentScreen.forOrder({
    Key? key,
    required String orderId,
    required double amount,
    required WidgetRef ref,
    required BuildContext context,
  }) {
    return PaymentScreen(
      key: key,
      title: 'Paiement de la commande',
      reference: orderId,
      amount: amount,
      currency: 'XOF',
      initiate: (phone, network) => ref.read(initiateOrderPaymentActionProvider)(
        orderId,
        phone,
        network,
      ),
      onSuccess: () => context.go('/orders'),
    );
  }

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

/// Point d'entrée route `/payment/:orderId` — charge la commande (montant)
/// puis délègue à [PaymentScreen.forOrder].
class OrderPaymentScreen extends ConsumerWidget {
  final String orderId;

  const OrderPaymentScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return orderAsync.when(
      data: (order) {
        final amount = order is Map
            ? ((order['totalAmount'] as num?)?.toDouble() ?? 0)
            : 0.0;
        return PaymentScreen.forOrder(
          orderId: orderId,
          amount: amount,
          ref: ref,
          context: context,
        );
      },
      loading: () => const Scaffold(body: Center(child: AppLoadingIndicator())),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Paiement')),
        body: Center(child: Text('Erreur: $err')),
      ),
    );
  }
}

const _networks = [
  {'key': 'FLOOZ', 'emoji': '🟠', 'label': 'FLOOZ', 'desc': 'Paiement mobile money Moov'},
  {'key': 'TMONEY', 'emoji': '🟡', 'label': 'T-Money', 'desc': 'Paiement mobile money Togocel'},
];

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  int _step = 0;
  String? selectedNetwork;
  String phoneNumber = '';
  String _processingMessage = 'Initialisation du paiement...';
  bool _pollingTimedOut = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
                    child: const Icon(Icons.arrow_back, color: AppColors.primary),
                  ),
                ),
              )
            : null,
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(
        index: _step,
        children: [
          _buildNetworkSelection(),
          _buildPhoneInput(),
          _buildProcessing(),
          _buildSuccess(),
        ],
      ),
    );
  }

  String get _amountLabel => widget.amount != null
      ? '${widget.amount!.toStringAsFixed(0)} ${widget.currency}'
      : 'Montant déterminé par le serveur';

  Widget _buildNetworkSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choisissez votre opérateur', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Sélectionnez le moyen de paiement mobile money',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          ..._networks.map((entry) {
            final key = entry['key']!;
            final isSelected = selectedNetwork == key;
            return GestureDetector(
              onTap: () => setState(() => selectedNetwork = key),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                      width: isSelected ? 2 : 1,
                    ),
                    color: isSelected ? AppColors.primaryLight : Colors.transparent,
                    boxShadow: isSelected ? AppColors.cardShadows : [],
                  ),
                  child: Row(
                    children: [
                      Text(entry['emoji']!, style: const TextStyle(fontSize: 40)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry['label']!,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(entry['desc']!, style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary),
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
              isEnabled: selectedNetwork != null,
              onPressed: () => setState(() => _step = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInput() {
    final current = _networks.firstWhere((entry) => entry['key'] == selectedNetwork);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Numéro de téléphone', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Entrez votre numéro ${current['label']}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
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
                Text(current['emoji']!, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '+228 90 12 34 56',
                    ),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
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
                    'Vous recevrez une demande de confirmation sur votre téléphone (USSD)',
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
              label: 'Payer $_amountLabel',
              isEnabled: phoneNumber.trim().length >= 8,
              onPressed: _processPayment,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessing() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLoadingIndicator(),
            const SizedBox(height: 24),
            Text('Traitement du paiement', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              _processingMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
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
                  Text('Référence: ${widget.reference}', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text('Opérateur: ${selectedNetwork ?? ""}', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    'Montant: $_amountLabel',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess() {
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
            Text('Votre paiement a été confirmé', style: Theme.of(context).textTheme.bodyMedium),
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
                      const Text('Référence:'),
                      Text(widget.reference, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Montant:'),
                      Text(
                        _amountLabel,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Statut:'),
                      AppBadge(label: 'Payé', backgroundColor: AppColors.secondary, textColor: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: AppButton(label: 'Continuer', onPressed: widget.onSuccess),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (selectedNetwork == null || phoneNumber.trim().length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un opérateur et saisir un numéro valide.')),
      );
      return;
    }

    setState(() {
      _step = 2;
      _processingMessage = 'Initialisation du paiement...';
      _pollingTimedOut = false;
    });

    try {
      final result = await widget.initiate(phoneNumber.trim(), selectedNetwork!);
      final paymentId = result['paymentId']?.toString();
      if (paymentId == null) {
        throw Exception('Réponse de paiement invalide (paymentId manquant)');
      }

      if (!mounted) return;
      setState(() => _processingMessage = 'En attente de confirmation sur votre téléphone...');

      final finalStatus = await _pollPaymentStatus(paymentId);

      if (!mounted) return;
      if (finalStatus == 'COMPLETED') {
        setState(() => _step = 3);
      } else if (_pollingTimedOut) {
        setState(() => _step = 1);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Confirmation non reçue à temps. Si vous avez validé sur votre téléphone, '
              'vérifiez vos commandes dans quelques instants.',
            ),
          ),
        );
      } else {
        setState(() => _step = 1);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Paiement non confirmé (statut: $finalStatus)')),
        );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _step = 1);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de paiement: ${error.toString()}')),
      );
    }
  }

  /// Interroge GET /payments/{paymentId}/status toutes les 3s jusqu'à un
  /// statut terminal (COMPLETED/FAILED/REFUNDED) ou 90s d'attente.
  Future<String> _pollPaymentStatus(String paymentId) async {
    final getStatus = ref.read(getPaymentStatusActionProvider);
    const maxAttempts = 30;
    const interval = Duration(seconds: 3);

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      await Future.delayed(interval);
      if (!mounted) return 'CANCELLED';

      try {
        final status = (await getStatus(paymentId))['status']?.toString() ?? 'PENDING';
        if (status != 'PENDING') {
          return status;
        }
      } catch (_) {
        // Erreur réseau transitoire pendant le polling : on retente.
      }
    }

    _pollingTimedOut = true;
    return 'PENDING';
  }
}
