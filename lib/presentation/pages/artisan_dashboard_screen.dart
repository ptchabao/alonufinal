import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../bloc/api_providers.dart';

/// Tableau de bord artisan, branché sur GET /dashboard/artisan.
class ArtisanDashboardScreen extends ConsumerWidget {
  const ArtisanDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(myArtisanDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
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
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erreur: $e')),
        data: (dashboard) {
          final products = dashboard['products'] as Map<String, dynamic>? ?? {};
          final orders = dashboard['orders'] as Map<String, dynamic>? ?? {};
          final revenue = dashboard['revenue'] as Map<String, dynamic>? ?? {};
          final students = dashboard['students'] as Map<String, dynamic>? ?? {};
          final currency = revenue['currency']?.toString() ?? 'XOF';

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myArtisanDashboardProvider),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Revenus', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _StatCard(label: 'Total', value: '${revenue['total'] ?? 0} $currency', color: AppColors.primary)),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(label: 'En attente', value: '${revenue['pending'] ?? 0} $currency', color: AppColors.secondary)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text('Commandes', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _StatCard(label: 'Total', value: '${orders['total'] ?? 0}', color: AppColors.primary)),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(label: 'En cours', value: '${orders['inProgress'] ?? 0}', color: AppColors.secondary)),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(label: 'Terminées', value: '${orders['completed'] ?? 0}', color: AppColors.success)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text('Produits', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _StatCard(label: 'Actifs', value: '${products['active'] ?? 0}', color: AppColors.primary)),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(label: 'Vues totales', value: '${products['totalViews'] ?? 0}', color: AppColors.secondary)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text('Apprentis', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _StatCard(label: 'Total assignés', value: '${students['total'] ?? 0}', color: AppColors.primary, fullWidth: true),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool fullWidth;

  const _StatCard({required this.label, required this.value, required this.color, this.fullWidth = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: 0.1),
        boxShadow: AppColors.cardShadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
