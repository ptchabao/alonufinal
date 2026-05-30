# Implémentation Artisans par Géolocalisation

## Vue d'ensemble

Cette implémentation ajoute la fonctionnalité de récupération des artisans proches de l'utilisateur en utilisant la géolocalisation. L'application récupère la position actuelle de l'utilisateur et appelle l'API pour obtenir les artisans filtrés par proximité.

## Architecture

### Structure des fichiers créés/modifiés

```
lib/
├── core/
│   └── services/
│       └── location_service.dart (NOUVEAU)
├── data/
│   ├── datasources/
│   │   └── artisan_remote_data_source.dart (MODIFIÉ)
│   └── models/
│       └── artisan_model.dart (NOUVEAU)
├── presentation/
│   ├── providers/
│   │   └── artisan_provider.dart (NOUVEAU)
│   └── screens/
│       └── nearby_artisans_screen.dart (NOUVEAU - EXEMPLE)
```

## Modèles de données

### ArtisanModel
Représente un artisan avec toutes les informations :
- Informations personnelles (nom, prénom, email)
- Localisation (latitude, longitude, adresse)
- Catégories/sous-catégories
- Réseaux sociaux
- Statut d'abonnement
- Distance calculée par rapport à l'utilisateur

### CategoryModel et SubCategoryModel
Représentent les catégories et sous-catégories d'artisans

### CountryModel
Représente les informations d'un pays

## Services

### LocationService
Gère la géolocalisation de l'utilisateur :
- `requestLocationPermission()` : Demande la permission d'accès à la localisation
- `isLocationServiceEnabled()` : Vérifie si le service est activé
- `getCurrentPosition()` : Obtient la position actuelle
- `calculateDistance()` : Calcule la distance entre deux points
- `getAddressFromCoordinates()` : Obtient l'adresse approximative

## Providers Riverpod

### Providers de base
- **dioProvider** : Fournit l'instance Dio configurée
- **locationServiceProvider** : Fournit le service de localisation
- **artisanRemoteDataSourceProvider** : Fournit la source de données distante

### Providers de données
- **currentLocationProvider** : Position actuelle de l'utilisateur
- **categoriesProvider** : Liste des catégories
- **nearbyArtisansProvider** : Artisans à proximité (utilise la localisation actuelle)
- **artisansByLocationProvider** : Artisans filtrés par coordonnées spécifiques
- **allArtisansProvider** : Tous les artisans sans filtrage de localisation
- **searchArtisansProvider** : Recherche d'artisans par requête

### Providers d'état
- **artisanFilterProvider** : Gère l'état du filtrage (catégorie, distance, recherche)
- **filteredArtisansProvider** : Retourne les artisans filtrés selon l'état

## Configuration requise

### Android

Ajouter les permissions dans `android/app/src/main/AndroidManifest.xml` :

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS

Ajouter les clés dans `ios/Runner/Info.plist` :

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Cette application a besoin de votre localisation pour trouver les artisans à proximité.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Cette application a besoin de votre localisation pour trouver les artisans à proximité.</string>
```

## Utilisation

### Afficher les artisans à proximité

```dart
class NearbyArtisansScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artisansAsync = ref.watch(filteredArtisansProvider);
    
    return artisansAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (err, _) => Text('Erreur: $err'),
      data: (artisans) => ListView(
        children: artisans.map((a) => ArtisanTile(artisan: a)).toList(),
      ),
    );
  }
}
```

### Filtrer les artisans

```dart
// Sélectionner une catégorie
ref.read(artisanFilterProvider.notifier).setCategory(categoryId);

// Définir une distance maximale
ref.read(artisanFilterProvider.notifier).setMaxDistance(10.0); // 10 km

// Chercher par texte
ref.read(artisanFilterProvider.notifier).setSearchQuery('menuisier');

// Basculer le tri par distance
ref.read(artisanFilterProvider.notifier).toggleSortByDistance();

// Réinitialiser les filtres
ref.read(artisanFilterProvider.notifier).reset();
```

### Rafraîchir les données

```dart
// Forcer le rafraîchissement
ref.refresh(filteredArtisansProvider);
ref.refresh(nearbyArtisansProvider);
ref.refresh(categoriesProvider);
```

### Obtenir la localisation actuelle

```dart
final locationAsync = ref.watch(currentLocationProvider);

locationAsync.when(
  data: (position) {
    print('Lat: ${position.latitude}, Lng: ${position.longitude}');
  },
  loading: () => print('Récupération de la localisation...'),
  error: (err, _) => print('Erreur: $err'),
);
```

## Appels API

### Récupérer les artisans par localisation
```
GET /api/artisans?lat=6.1924326&lng=1.1908736
```

Paramètres optionnels :
- `page` : Numéro de page (défaut : 1)
- `limit` : Nombre de résultats (défaut : 20)

Réponse : Liste d'ArtisanModel avec la distance calculée

### Récupérer les catégories
```
GET /api/categories
```

Réponse : Liste de CategoryModel avec sous-catégories

## Gestion des erreurs

### LocationException
Exception levée par le service de localisation quand :
- La permission est refusée
- Le service de localisation est désactivé
- Erreur lors de la récupération de la position

### Exemple de gestion

```dart
try {
  final position = await locationService.getCurrentPosition();
} on LocationException catch (e) {
  // Afficher un dialog ou un snackbar avec le message d'erreur
  showErrorDialog(context, e.message);
}
```

## Optimisations et bonnes pratiques

1. **Mise en cache** : Les providers Riverpod mettent automatiquement en cache les résultats
2. **Tri automatique** : Les artisans sont triés par distance par défaut
3. **Gestion des permissions** : Le service demande les permissions à la première utilisation
4. **Timeout** : Les requêtes réseau ont un timeout de 30 secondes
5. **Filtrage côté client** : Le filtrage par catégorie et recherche se fait côté client pour une meilleure UX

## Intégration avec le reste de l'application

### Dans main.dart
```dart
void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### Routes possibles
Vous pouvez ajouter la route suivante dans GoRouter :

```dart
GoRoute(
  path: '/nearby-artisans',
  builder: (context, state) => const NearbyArtisansScreen(),
),
```

## Prochaines étapes

1. Intégrer l'écran d'exemple dans l'application
2. Ajouter l'intégration WhatsApp et appels téléphoniques
3. Implémenter le partage de localisation
4. Ajouter les favoris/bookmarks
5. Implémenter les avis et notes

## Ressources externes

- [Geolocator Package](https://pub.dev/packages/geolocator)
- [Riverpod Documentation](https://riverpod.dev)
- [Flutter Widgets Guide](https://flutter.dev/docs/development/ui/widgets)
