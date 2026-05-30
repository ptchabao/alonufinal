import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/artisan_model.dart';
import '../providers/artisan_provider.dart';

/// Écran pour afficher les artisans à proximité de l'utilisateur
class NearbyArtisansScreen extends ConsumerWidget {
  const NearbyArtisansScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the filtered artisans provider
    final artisansAsync = ref.watch(filteredArtisansProvider);
    final categories = ref.watch(categoriesProvider);
    final filterState = ref.watch(artisanFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artisans à proximité'),
        centerTitle: true,
      ),
      body: artisansAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Erreur: ${err.toString()}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.refresh(filteredArtisansProvider);
                },
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (artisans) => Column(
          children: [
            // Filter/Sort Bar
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Sort by distance button
                  FilterChip(
                    label: const Text('Distance'),
                    selected: filterState.sortByDistance,
                    onSelected: (_) {
                      ref
                          .read(artisanFilterProvider.notifier)
                          .toggleSortByDistance();
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.blue[100],
                  ),
                  const SizedBox(width: 8),
                  // Filter button
                  ElevatedButton.icon(
                    icon: const Icon(Icons.tune),
                    label: const Text('Filtres'),
                    onPressed: () {
                      _showFilterDialog(context, ref, categories);
                    },
                  ),
                  const Spacer(),
                  // Reset button
                  if (filterState.selectedCategory != null ||
                      filterState.maxDistance != null ||
                      (filterState.searchQuery != null &&
                          filterState.searchQuery!.isNotEmpty))
                    TextButton.icon(
                      icon: const Icon(Icons.clear),
                      label: const Text('Réinitialiser'),
                      onPressed: () {
                        ref.read(artisanFilterProvider.notifier).reset();
                      },
                    ),
                ],
              ),
            ),
            // Results count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '${artisans.length} artisan${artisans.length > 1 ? 's' : ''} trouvé${artisans.length > 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            // Artisans list
            Expanded(
              child: artisans.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.business_center_outlined,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('Aucun artisan trouvé'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: artisans.length,
                      itemBuilder: (context, index) {
                        final artisan = artisans[index];
                        return _ArtisanCard(artisan: artisan);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<CategoryModel>> categoriesAsync,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtres'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category filter
              Text(
                'Catégorie',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              categoriesAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (err, _) => const Text('Erreur au chargement'),
                data: (categories) => SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: categories.map((category) {
                      return CheckboxListTile(
                        title: Text(category.libelleFr),
                        value: ref.watch(artisanFilterProvider).selectedCategory ==
                            category.id,
                        onChanged: (value) {
                          if (value == true) {
                            ref
                                .read(artisanFilterProvider.notifier)
                                .setCategory(category.id);
                          } else {
                            ref
                                .read(artisanFilterProvider.notifier)
                                .setCategory(null);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Distance filter
              Text(
                'Distance maximale: ${ref.watch(artisanFilterProvider).maxDistance?.toStringAsFixed(1) ?? "Non limitée"} km',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Slider(
                min: 0,
                max: 50,
                divisions: 50,
                value: ref.watch(artisanFilterProvider).maxDistance ?? 50,
                onChanged: (value) {
                  ref
                      .read(artisanFilterProvider.notifier)
                      .setMaxDistance(value);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Appliquer'),
          ),
        ],
      ),
    );
  }
}

/// Widget for displaying an artisan card
class _ArtisanCard extends StatelessWidget {
  final ArtisanModel artisan;

  const _ArtisanCard({required this.artisan});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and distance
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  backgroundImage: artisan.user.avatar != null
                      ? NetworkImage(artisan.user.avatar!)
                      : null,
                  child: artisan.user.avatar == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${artisan.user.prenom} ${artisan.user.nom}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        artisan.numeroEnr,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                // Distance and status
                if (artisan.distance != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${artisan.distance!.toStringAsFixed(2)} km',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      if (!artisan.actif)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Inactif',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Contact info
            if (artisan.adresse != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        artisan.adresse!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  artisan.telephone,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Sub-categories
            if (artisan.subCategories.isNotEmpty)
              Wrap(
                spacing: 4,
                children: artisan.subCategories
                    .take(3)
                    .map((sc) => Chip(
                      label: Text(
                        sc.subCategory.libelleFr,
                        style: const TextStyle(fontSize: 12),
                      ),
                      visualDensity: VisualDensity.compact,
                    ))
                    .toList(),
              ),
            if (artisan.subCategories.length > 3)
              Text(
                '+${artisan.subCategories.length - 3} autres',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 12),
            // Action buttons
            Row(
              children: [
                if (artisan.whatsapp != null && artisan.whatsapp!.isNotEmpty)
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.message, size: 16),
                      label: const Text('WhatsApp'),
                      onPressed: () {
                        // TODO: Implement WhatsApp integration
                      },
                    ),
                  ),
                if (artisan.whatsapp != null && artisan.whatsapp!.isNotEmpty)
                  const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.phone, size: 16),
                    label: const Text('Appeler'),
                    onPressed: () {
                      // TODO: Implement phone call integration
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
