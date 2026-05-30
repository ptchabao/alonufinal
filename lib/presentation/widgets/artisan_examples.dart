import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/artisan_provider.dart';
import '../../core/services/location_service.dart';

/// Exemples avancés d'utilisation des providers d'artisans

/// Exemple 1: Afficher les artisans avec mise à jour automatique
class AutoUpdateArtisansWidget extends ConsumerStatefulWidget {
  const AutoUpdateArtisansWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<AutoUpdateArtisansWidget> createState() =>
      _AutoUpdateArtisansWidgetState();
}

class _AutoUpdateArtisansWidgetState
    extends ConsumerState<AutoUpdateArtisansWidget> {
  late Future<void> _refreshFuture;

  @override
  void initState() {
    super.initState();
    _refreshFuture = _refresh();
  }

  Future<void> _refresh() async {
    // Rafraîchir la localisation et les artisans
    await Future.wait([
      ref.refresh(currentLocationProvider.future),
      ref.refresh(nearbyArtisansProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final artisansAsync = ref.watch(nearbyArtisansProvider);

    return RefreshIndicator(
      onRefresh: _refresh,
      child: artisansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur: $err')),
        data: (artisans) => ListView.builder(
          itemCount: artisans.length,
          itemBuilder: (context, index) => ListTile(
            title: Text('${artisans[index].user.prenom} '
                '${artisans[index].user.nom}'),
            subtitle: Text(
                '${artisans[index].distance?.toStringAsFixed(2) ?? "?"} km'),
          ),
        ),
      ),
    );
  }
}

/// Exemple 2: Filtrage dynamique avec debounce
class DynamicFilteringWidget extends ConsumerWidget {
  const DynamicFilteringWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredArtisans = ref.watch(filteredArtisansProvider);
    final filterState = ref.watch(artisanFilterProvider);

    return Column(
      children: [
        // Barre de recherche
        TextField(
          decoration: InputDecoration(
            hintText: 'Chercher un artisan...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: (value) {
            ref
                .read(artisanFilterProvider.notifier)
                .setSearchQuery(value.isEmpty ? null : value);
          },
        ),
        const SizedBox(height: 16),
        // Filtres actifs
        if (filterState.selectedCategory != null ||
            filterState.maxDistance != null ||
            (filterState.searchQuery != null &&
                filterState.searchQuery!.isNotEmpty))
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Wrap(
              spacing: 8,
              children: [
                if (filterState.selectedCategory != null)
                  Chip(
                    label: Text('Catégorie: ${filterState.selectedCategory}'),
                    onDeleted: () {
                      ref
                          .read(artisanFilterProvider.notifier)
                          .setCategory(null);
                    },
                  ),
                if (filterState.maxDistance != null)
                  Chip(
                    label: Text(
                        'Distance: ${filterState.maxDistance!.toStringAsFixed(1)} km'),
                    onDeleted: () {
                      ref
                          .read(artisanFilterProvider.notifier)
                          .setMaxDistance(null);
                    },
                  ),
              ],
            ),
          ),
        // Liste des artisans filtrés
        Expanded(
          child: filteredArtisans.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Erreur: $err')),
            data: (artisans) => ListView.builder(
              itemCount: artisans.length,
              itemBuilder: (context, index) => ListTile(
                title: Text('${artisans[index].user.prenom} '
                    '${artisans[index].user.nom}'),
                subtitle: Text(
                    '${artisans[index].distance?.toStringAsFixed(2) ?? "?"} km'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Exemple 3: Gérer la localisation avec gestion d'erreur personnalisée
class LocationPermissionWidget extends ConsumerWidget {
  const LocationPermissionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(currentLocationProvider);

    return locationAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              'Impossible de récupérer votre localisation',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.settings),
              label: const Text('Ouvrir les paramètres'),
              onPressed: () {
                Geolocator.openLocationSettings();
              },
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              onPressed: () {
                ref.refresh(currentLocationProvider);
                ref.refresh(nearbyArtisansProvider);
              },
            ),
          ],
        ),
      ),
      data: (position) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Votre localisation',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Latitude: ${position.latitude.toStringAsFixed(4)}',
                ),
                Text(
                  'Longitude: ${position.longitude.toStringAsFixed(4)}',
                ),
                Text(
                  'Précision: ${position.accuracy.toStringAsFixed(1)} m',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Exemple 4: Comparaison entre les artisans par distance
class CompareArtisansByDistanceWidget extends ConsumerWidget {
  const CompareArtisansByDistanceWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artisansAsync = ref.watch(nearbyArtisansProvider);

    return artisansAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Erreur: $err')),
      data: (artisans) {
        // Grouper par distance (0-5km, 5-10km, 10km+)
        final close = artisans
            .where((a) => a.distance != null && a.distance! <= 5)
            .toList();
        final medium = artisans
            .where((a) => a.distance != null && a.distance! > 5 && a.distance! <= 10)
            .toList();
        final far = artisans.where((a) => a.distance != null && a.distance! > 10).toList();

        return ListView(
          children: [
            if (close.isNotEmpty) ...[
              _buildDistanceSection(context, 'Très proche (0-5 km)', close,
                  Colors.green),
              const Divider(),
            ],
            if (medium.isNotEmpty) ...[
              _buildDistanceSection(
                  context, 'Proche (5-10 km)', medium, Colors.orange),
              const Divider(),
            ],
            if (far.isNotEmpty) ...[
              _buildDistanceSection(context, 'Un peu loin (10+ km)', far,
                  Colors.red),
            ],
            if (artisans.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Aucun artisan trouvé'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDistanceSection(
    BuildContext context,
    String title,
    List artisans,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Text(
                '${artisans.length}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        ...artisans.map((artisan) => ListTile(
          title: Text('${artisan.user.prenom} ${artisan.user.nom}'),
          subtitle: Text('${artisan.distance?.toStringAsFixed(2) ?? "?"} km'),
          trailing: const Icon(Icons.arrow_forward),
        )),
      ],
    );
  }
}

/// Exemple 5: Caching et refresh intelligent
class SmartCachingWidget extends ConsumerWidget {
  const SmartCachingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artisansAsync = ref.watch(nearbyArtisansProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artisans (Cached)'),
        actions: [
          // Bouton pour forcer le rafraîchissement
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Force un nouveau chargement même si les données sont en cache
              ref.refresh(nearbyArtisansProvider);
            },
          ),
        ],
      ),
      body: artisansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur: $err')),
        data: (artisans) => ListView.builder(
          itemCount: artisans.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(
              '${artisans[index].user.prenom} ${artisans[index].user.nom}',
            ),
            subtitle: Text(
              '${artisans[index].distance?.toStringAsFixed(2) ?? "?"} km',
            ),
          ),
        ),
      ),
    );
  }
}

/// Exemple 6: Recherche avec providers family
class SearchWithFamilyWidget extends ConsumerWidget {
  final String searchQuery;

  const SearchWithFamilyWidget({
    Key? key,
    required this.searchQuery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (searchQuery.isEmpty) {
      return const Center(child: Text('Entrez un terme de recherche'));
    }

    final searchAsync = ref.watch(searchArtisansProvider(searchQuery));

    return searchAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Erreur: $err')),
      data: (artisans) => ListView.builder(
        itemCount: artisans.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(
            '${artisans[index].user.prenom} ${artisans[index].user.nom}',
          ),
          subtitle: Text(artisans[index].numeroEnr),
        ),
      ),
    );
  }
}
