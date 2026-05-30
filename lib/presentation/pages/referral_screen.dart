import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../widgets/widgets.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({Key? key}) : super(key: key);

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final String referralCode = 'ALONU2025MS47';
  final String referralLink = 'https://alonu.shop/ref/ALONU2025MS47';

  final Map<String, dynamic> referralStats = {
    'totalReferrals': 12,
    'bonusEarned': 200000,
    'pendingBonus': 80000,
  };

  final List<Map<String, dynamic>> referrals = [
    {'name': 'Ahmed Sow', 'date': '15 Mai 2025', 'status': 'Inscrit', 'bonus': 20000},
    {'name': 'Fatou Diallo', 'date': '10 Mai 2025', 'status': 'Inscrit', 'bonus': 20000},
    {'name': 'Moussa Kone', 'date': '05 Mai 2025', 'status': 'Inscrit', 'bonus': 20000},
    {'name': 'Aïssatou Ba', 'date': '01 Mai 2025', 'status': 'En attente', 'bonus': 0},
  ];

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    showSuccessSnackbar(context, 'Copié!');
  }

  @override
  Widget build(BuildContext context) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mon code de parrainage',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(referralCode,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _copyToClipboard(referralCode),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white24,
                          ),
                          child: const Icon(Icons.content_copy, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Partage ce code et gagne 20,000 XOF par inscription!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats
            Row(
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
                        Text('${referralStats['bonusEarned']} XOF',
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
                        Text('${referralStats['pendingBonus']} XOF',
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
            ),
            const SizedBox(height: 24),

            // Share Buttons
            Text('Partager mon code', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => showSuccessSnackbar(context, 'WhatsApp'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFF25D366),
                      ),
                      child: const Center(
                        child: Text('WhatsApp',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => showSuccessSnackbar(context, 'SMS'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFF007AFF),
                      ),
                      child: const Center(
                        child: Text('SMS',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => showSuccessSnackbar(context, 'Email'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFFEA4335),
                      ),
                      child: const Center(
                        child: Text('Email',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Link
            Text('Mon lien', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.surfaceVariant),
                borderRadius: BorderRadius.circular(8),
                color: AppColors.surfaceVariant,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(referralLink,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _copyToClipboard(referralLink),
                    child: const Icon(Icons.content_copy, size: 18, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Referrals
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mes parrainés',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                AppBadge(
                  label: '${referralStats['totalReferrals']}',
                  backgroundColor: AppColors.primaryLight,
                  textColor: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.builder(
              itemCount: referrals.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final ref = referrals[index];
                final isCompleted = ref['status'] == 'Inscrit';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FadeInWidget(
                    delay: Duration(milliseconds: index * 100),
                    child: Container(
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ref['name'],
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(ref['date'],
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('+${ref['bonus']} XOF',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: isCompleted ? AppColors.secondary : AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(ref['status'],
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
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
