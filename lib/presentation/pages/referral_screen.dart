import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../bloc/api_providers.dart';
import '../widgets/widgets.dart';

class ReferralScreen extends ConsumerWidget {
  const ReferralScreen({Key? key}) : super(key: key);

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    showSuccessSnackbar(context, 'Copié!');
  }

  Future<void> _share(BuildContext context, Uri uri) async {
    final launched = await launchUrl(uri);
    if (!launched && context.mounted) {
      showErrorSnackbar(context, 'Impossible d\'ouvrir l\'application');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final codeAsync = ref.watch(myReferralCodeProvider);
    final statsAsync = ref.watch(referralStatsProvider);
    final referralsAsync = ref.watch(myReferralsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Programme de parrainage'),
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
            // Code Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppColors.cardShadows,
              ),
              child: codeAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                error: (e, st) => Text('Erreur: $e', style: const TextStyle(color: Colors.white)),
                data: (data) {
                  final code = data['referralCode']?.toString() ?? '';
                  final shareUrl = data['shareUrl']?.toString() ?? '';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mon code de parrainage',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(code,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _copyToClipboard(context, code),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white24),
                              child: const Icon(Icons.content_copy, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(shareUrl,
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _copyToClipboard(context, shareUrl),
                            child: const Icon(Icons.content_copy, color: Colors.white70, size: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _ShareButton(
                              label: 'WhatsApp',
                              color: const Color(0xFF25D366),
                              onTap: () => _share(context, Uri.parse(
                                  'https://wa.me/?text=${Uri.encodeComponent('Rejoins ALONU avec mon code $code : $shareUrl')}')),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ShareButton(
                              label: 'SMS',
                              color: const Color(0xFF007AFF),
                              onTap: () => _share(context, Uri(
                                  scheme: 'sms',
                                  queryParameters: {'body': 'Rejoins ALONU avec mon code $code : $shareUrl'})),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ShareButton(
                              label: 'Email',
                              color: const Color(0xFFEA4335),
                              onTap: () => _share(context, Uri(
                                  scheme: 'mailto',
                                  queryParameters: {
                                    'subject': 'Rejoins ALONU',
                                    'body': 'Utilise mon code de parrainage $code : $shareUrl',
                                  })),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Stats
            statsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('Erreur: $e'),
              data: (stats) {
                final totalReward = stats['totalReward']?.toString() ?? '0';
                final pendingReward = stats['pendingReward']?.toString() ?? '0';
                return Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.primaryLight,
                          boxShadow: AppColors.cardShadows,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Gains', style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 8),
                            Text('$totalReward XOF',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          boxShadow: AppColors.cardShadows,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('En attente', style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 8),
                            Text('$pendingReward XOF',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Referrals
            Text('Mes parrainés', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            referralsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('Erreur: $e'),
              data: (referrals) {
                if (referrals.isEmpty) {
                  return const Text('Aucun parrainage pour le moment.');
                }
                return ListView.separated(
                  itemCount: referrals.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final ref = referrals[index] as Map<String, dynamic>;
                    final status = ref['status']?.toString() ?? 'PENDING';
                    final isCompleted = status == 'PAID';
                    final amount = ref['amount']?.toString() ?? '0';
                    final referred = ref['referred'] as Map<String, dynamic>?;
                    final name = referred != null
                        ? '${referred['prenom'] ?? ''} ${referred['nom'] ?? ''}'.trim()
                        : 'Utilisateur';

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isCompleted ? AppColors.secondary : AppColors.surfaceVariant,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: isCompleted ? AppColors.secondary.withValues(alpha: 0.1) : AppColors.surface,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompleted
                                  ? AppColors.secondary.withValues(alpha: 0.2)
                                  : AppColors.surfaceVariant,
                            ),
                            child: Text(isCompleted ? '✓' : '⏳', style: const TextStyle(fontSize: 16)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(name.isEmpty ? 'Utilisateur' : name,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('+$amount XOF',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: isCompleted ? AppColors.secondary : AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(status,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ],
                      ),
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

class _ShareButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: color),
        child: Center(
          child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
