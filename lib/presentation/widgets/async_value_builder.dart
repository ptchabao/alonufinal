import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import 'widgets.dart';

/// Widget réutilisable pour gérer les états AsyncValue
class AsyncValueBuilder<T> extends StatelessWidget {
  final AsyncValue<T> asyncValue;
  final Widget Function(BuildContext, T) data;
  final Widget Function(BuildContext, String)? error;
  final Widget? loading;

  const AsyncValueBuilder({
    Key? key,
    required this.asyncValue,
    required this.data,
    this.error,
    this.loading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      data: (value) => data(context, value),
      loading: () => loading ?? _buildDefaultLoading(),
      error: (err, st) => error?.call(context, err.toString()) ?? _buildDefaultError(err.toString()),
    );
  }

  Widget _buildDefaultLoading() {
    return const Center(
      child: AppLoadingIndicator(),
    );
  }

  Widget _buildDefaultError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 16),
          Text(
            'Erreur',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget pour afficher une liste avec support AsyncValue
class AsyncListBuilder<T> extends StatelessWidget {
  final AsyncValue<List<T>> asyncValue;
  final Widget Function(BuildContext, List<T>, int) itemBuilder;
  final ScrollPhysics? physics;
  final EdgeInsets padding;
  final Axis scrollDirection;

  const AsyncListBuilder({
    Key? key,
    required this.asyncValue,
    required this.itemBuilder,
    this.physics,
    this.padding = const EdgeInsets.all(16),
    this.scrollDirection = Axis.vertical,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucun élément trouvé',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: items.length,
          physics: physics,
          padding: padding,
          scrollDirection: scrollDirection,
          itemBuilder: (context, index) => itemBuilder(context, items, index),
        );
      },
      loading: () => const Center(child: AppLoadingIndicator()),
      error: (err, st) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'Erreur: ${err.toString()}',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Snackbar helper pour afficher les erreurs
void showErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: AppColors.error,
      duration: const Duration(seconds: 4),
    ),
  );
}

/// Snackbar helper pour afficher les succès
void showSuccessSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: AppColors.secondary,
      duration: const Duration(seconds: 3),
    ),
  );
}

/// Dialog pour confirmer une action
Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Confirmer',
  String cancelText = 'Annuler',
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
}
