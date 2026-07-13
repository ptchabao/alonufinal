import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../bloc/api_providers.dart';
import '../widgets/widgets.dart';

/// Écran de don, branché sur POST /donations, GET /donations/me et
/// GET /donations/stats. L'API ne connaît que 3 types de bénéficiaires
/// (ARTISAN, STUDENT, PLATFORM avec recipientId requis sauf pour PLATFORM) :
/// il n'y a pas de notion de "cause" ou de campagne côté backend.
class DonationScreen extends ConsumerStatefulWidget {
  final String? recipientType;
  final String? recipientId;
  final String? recipientLabel;

  const DonationScreen({
    Key? key,
    this.recipientType,
    this.recipientId,
    this.recipientLabel,
  }) : super(key: key);

  @override
  ConsumerState<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends ConsumerState<DonationScreen> {
  String _selectedAmount = '';
  bool _anonymous = false;
  bool _submitting = false;
  late TextEditingController _customAmountController;
  late TextEditingController _messageController;

  final List<String> predefinedAmounts = ['1000', '5000', '10000', '25000', '50000'];

  String get _recipientType => widget.recipientType ?? 'PLATFORM';
  String get _recipientLabel => widget.recipientLabel ?? 'Plateforme ALONU';

  @override
  void initState() {
    super.initState();
    _customAmountController = TextEditingController();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitDonation() async {
    final amountText = _selectedAmount.isNotEmpty ? _selectedAmount : _customAmountController.text.trim();
    final amount = double.tryParse(amountText);
    if (amount == null || amount < 100) {
      showErrorSnackbar(context, 'Le montant minimum est de 100 XOF');
      return;
    }

    setState(() => _submitting = true);
    try {
      final create = ref.read(createDonationActionProvider);
      await create({
        'recipientType': _recipientType,
        if (widget.recipientId != null) 'recipientId': widget.recipientId,
        'amount': amount,
        'currency': 'XOF',
        if (_messageController.text.trim().isNotEmpty) 'message': _messageController.text.trim(),
        'anonymous': _anonymous,
      });
      ref.invalidate(myDonationsProvider);
      if (!mounted) return;
      showSuccessSnackbar(context, 'Merci pour votre don de $amountText XOF !');
      setState(() {
        _selectedAmount = '';
        _customAmountController.clear();
        _messageController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      showErrorSnackbar(context, 'Erreur: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myDonationsAsync = ref.watch(myDonationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Faire un don'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppColors.cardShadows,
              ),
              child: Row(
                children: [
                  const Icon(Icons.volunteer_activism, color: AppColors.primary, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bénéficiaire', style: Theme.of(context).textTheme.bodySmall),
                        Text(_recipientLabel,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('Montant du don', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: predefinedAmounts.map((amount) {
                final isSelected = _selectedAmount == amount;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAmount = isSelected ? '' : amount;
                      _customAmountController.clear();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected ? AppColors.primaryLight : AppColors.surface,
                    ),
                    child: Text(
                      '$amount XOF',
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.primary : AppColors.onSurface,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _customAmountController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() => _selectedAmount = ''),
              decoration: InputDecoration(
                labelText: 'Montant personnalisé (XOF)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: AppColors.surfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              maxLines: 2,
              maxLength: 500,
              decoration: InputDecoration(
                labelText: 'Message (optionnel)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: AppColors.surfaceVariant,
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _anonymous,
              onChanged: (v) => setState(() => _anonymous = v),
              title: const Text('Don anonyme'),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: _submitting ? 'Envoi…' : 'Faire un don',
              isEnabled: !_submitting,
              isLoading: _submitting,
              onPressed: _submitDonation,
            ),
            const SizedBox(height: 32),

            Text('Mes dons', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            myDonationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('Erreur: $e'),
              data: (donations) {
                if (donations.isEmpty) {
                  return const Text('Vous n\'avez pas encore fait de don.');
                }
                return ListView.separated(
                  itemCount: donations.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, i) {
                    final d = donations[i] as Map<String, dynamic>;
                    final amount = d['amount']?.toString() ?? '0';
                    final currency = d['currency']?.toString() ?? 'XOF';
                    final recipientType = d['recipientType']?.toString() ?? '';
                    return ListTile(
                      leading: const Icon(Icons.favorite, color: AppColors.primary),
                      title: Text('$amount $currency'),
                      subtitle: Text(recipientType),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
