import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../bloc/api_providers.dart';
import '../widgets/widgets.dart';
import 'payment_screen.dart';

/// Accès aux partenaires microfinance (GET /microfinance/partners) et à
/// l'adhésion (POST /microfinance/adhesions), suivie du paiement des frais
/// (POST /payments/microfinance-adhesion/{id}/initiate). Gestion des
/// partenaires, export CSV et reporting restent réservés à l'Admin.
class MicrofinanceScreen extends ConsumerWidget {
  const MicrofinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partnersAsync = ref.watch(microfinancePartnersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Microfinance'),
        leading: Padding(
          padding: const EdgeInsets.all(8),
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
      body: partnersAsync.when(
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (e, st) => Center(child: Text('Erreur: $e')),
        data: (partners) {
          if (partners.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.account_balance_outlined, size: 64, color: AppColors.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun partenaire microfinance disponible',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: partners.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final partner = (partners[i] as Map).cast<String, dynamic>();
              return _PartnerCard(partner: partner);
            },
          );
        },
      ),
    );
  }
}

class _PartnerCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> partner;

  const _PartnerCard({required this.partner});

  @override
  ConsumerState<_PartnerCard> createState() => _PartnerCardState();
}

class _PartnerCardState extends ConsumerState<_PartnerCard> {
  bool _isSubmitting = false;

  Future<void> _adhere() async {
    final partnerId = widget.partner['id']?.toString();
    if (partnerId == null) return;

    setState(() => _isSubmitting = true);
    try {
      final createAdhesion = ref.read(createMicrofinanceAdhesionActionProvider);
      final adhesion = await createAdhesion(partnerId);
      final adhesionId = adhesion['id']?.toString();
      if (adhesionId == null) {
        throw Exception('Identifiant d\'adhésion introuvable');
      }

      final amount = (widget.partner['adhesionFee'] as num?)?.toDouble();
      final currency = widget.partner['currency']?.toString() ?? 'XOF';

      if (!mounted) return;
      context.push(
        '/pay',
        extra: PaymentScreen(
          title: 'Frais d\'adhésion',
          reference: adhesionId,
          amount: amount,
          currency: currency,
          initiate: (phone, network) => ref.read(initiateMicrofinanceAdhesionPaymentActionProvider)(
            adhesionId,
            phone,
            network,
          ),
          onSuccess: () => context.pop(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showErrorSnackbar(context, 'Erreur: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = (widget.partner['name'] ?? 'Partenaire').toString();
    final fee = (widget.partner['adhesionFee'] as num?)?.toDouble() ?? 0;
    final currency = widget.partner['currency']?.toString() ?? 'XOF';
    final contactName = widget.partner['contactName']?.toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.account_balance, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    if (contactName != null && contactName.isNotEmpty)
                      Text(contactName, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Frais d\'adhésion', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant)),
                  Text(
                    '${fee.toStringAsFixed(0)} $currency',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              AppButton(
                label: _isSubmitting ? '...' : 'Adhérer',
                isSmall: true,
                isEnabled: !_isSubmitting,
                onPressed: _adhere,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
