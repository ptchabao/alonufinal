# Quickstart Guide - Artisans par Géolocalisation

## Étape 1 : Vérifier les dépendances

Toutes les dépendances nécessaires sont déjà dans `pubspec.yaml` :
- ✅ `geolocator: ^9.0.2` - Pour la géolocalisation
- ✅ `flutter_riverpod: ^2.4.0` - Pour la gestion d'état
- ✅ `dio: ^5.3.1` - Pour les appels API
- ✅ `google_maps_flutter: ^2.5.0` - Pour l'intégration cartographique

Exécuter :
```bash
flutter pub get
```

## Étape 2 : Configurer les permissions

### Android
Ajouter dans `android/app/src/main/AndroidManifest.xml` (avant la balise `</manifest>`) :

```xml
<!-- Permissions for location -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS
Ajouter dans `ios/Runner/Info.plist` (avant la balise `</dict>`) :

```xml
<!-- Location permissions -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>ALONU a besoin de votre localisation pour trouver les artisans à proximité.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>ALONU a besoin de votre localisation pour trouver les artisans à proximité.</string>
```

Voir [PERMISSIONS_CONFIGURATION.md](./PERMISSIONS_CONFIGURATION.md) pour les détails complets.

## Étape 3 : Intégrer l'écran dans l'application

### Option A : Navigation simple

Dans `lib/main.dart` ou votre fichier de routes :

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screens/nearby_artisans_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### Option B : Avec GoRouter

Ajouter la route dans votre configuration GoRouter :

```dart
GoRoute(
  path: '/nearby-artisans',
  builder: (context, state) => const NearbyArtisansScreen(),
),
```

Puis naviguer :
```dart
context.go('/nearby-artisans');
```

## Étape 4 : Test simple

Créer une page de test pour vérifier le fonctionnement :

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/providers/artisan_provider.dart';

class TestLocationPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Test 1: Afficher la localisation actuelle
    final locationAsync = ref.watch(currentLocationProvider);
    
    // Test 2: Afficher les artisans à proximité
    final artisansAsync = ref.watch(nearbyArtisansProvider);
    
    // Test 3: Afficher les catégories
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Test Localisation')),
      body: Column(
        children: [
          // Afficher la localisation
          locationAsync.when(
            data: (pos) => ListTile(
              title: const Text('Votre localisation'),
              subtitle: Text('${pos.latitude}, ${pos.longitude}'),
            ),
            loading: () => const ListTile(
              title: Text('Localisation...'),
            ),
            error: (err, _) => ListTile(
              title: const Text('Erreur localisation'),
              subtitle: Text(err.toString()),
            ),
          ),
          const Divider(),
          // Afficher les artisans
          Expanded(
            child: artisansAsync.when(
              data: (artisans) => ListView(
                children: artisans
                    .map((a) => ListTile(
                      title: Text('${a.user.prenom} ${a.user.nom}'),
                      subtitle: Text('${a.distance?.toStringAsFixed(2)} km'),
                    ))
                    .toList(),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, _) => Center(
                child: Text('Erreur: $err'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

## Étape 5 : Utilisation dans votre écran

Copier le code de `nearby_artisans_screen.dart` ou le personnaliser selon vos besoins.

### Exemple minimaliste

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/providers/artisan_provider.dart';

class SimpleArtisansPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artisansAsync = ref.watch(nearbyArtisansProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Artisans à proximité')),
      body: artisansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur: $err')),
        data: (artisans) => ListView.builder(
          itemCount: artisans.length,
          itemBuilder: (context, index) {
            final artisan = artisans[index];
            return ListTile(
              title: Text('${artisan.user.prenom} ${artisan.user.nom}'),
              subtitle: Text('${artisan.distance?.toStringAsFixed(1) ?? "?"} km'),
              trailing: Text(artisan.numeroEnr),
            );
          },
        ),
      ),
    );
  }
}
```

## Étape 6 : Rafraîchir les données

Ajouter un FloatingActionButton pour rafraîchir :

```dart
floatingActionButton: FloatingActionButton(
  onPressed: () {
    ref.refresh(nearbyArtisansProvider);
  },
  child: const Icon(Icons.refresh),
),
```

## Étapes suivantes optionnelles

### 1. Ajouter la recherche
```dart
ref.read(artisanFilterProvider.notifier).setSearchQuery('menuisier');
```

### 2. Ajouter le filtrage par catégorie
```dart
ref.read(artisanFilterProvider.notifier).setCategory(categoryId);
```

### 3. Ajouter le filtrage par distance
```dart
ref.read(artisanFilterProvider.notifier).setMaxDistance(10.0); // 10 km
```

### 4. Intégrer Google Maps
```dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Afficher les artisans sur une carte
GoogleMap(
  initialCameraPosition: CameraPosition(
    target: LatLng(currentLat, currentLng),
    zoom: 15,
  ),
  markers: Set.from(
    artisans.map((a) => Marker(
      markerId: MarkerId(a.id),
      position: LatLng(a.latitude!, a.longitude!),
      infoWindow: InfoWindow(
        title: '${a.user.prenom} ${a.user.nom}',
      ),
    )),
  ),
)
```

## Dépannage rapide

### ❌ "Permission refusée"
- Android : Vérifier les permissions dans les paramètres de l'app
- iOS : Vérifier Info.plist et redémarrer l'app

### ❌ "Service de localisation désactivé"
- Activer la localisation dans les paramètres du téléphone

### ❌ "Aucun artisan trouvé"
- Vérifier que les coordonnées sont correctes
- Vérifier que l'API backend fonctionne
- Vérifier les logs du backend

### ❌ "Exception TimeOut"
- Vérifier la connexion internet
- Augmenter le timeout dans `location_service.dart`

## Documentation complète

Pour plus de détails, voir :
- [ARTISANS_GEOLOCATION_IMPLEMENTATION.md](./ARTISANS_GEOLOCATION_IMPLEMENTATION.md)
- [PERMISSIONS_CONFIGURATION.md](./PERMISSIONS_CONFIGURATION.md)

## Fichiers modifiés/créés

✅ Créés :
- `lib/core/services/location_service.dart`
- `lib/data/models/artisan_model.dart`
- `lib/presentation/providers/artisan_provider.dart`
- `lib/presentation/screens/nearby_artisans_screen.dart`

✏️ Modifiés :
- `lib/data/datasources/artisan_remote_data_source.dart`

## Prêt à l'emploi

L'implémentation est maintenant complète et prête à être utilisée. Tous les fichiers nécessaires ont été créés et configurés.
