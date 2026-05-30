# Guide de Test - Artisans par Géolocalisation

## Fichiers de test à créer

### 1. Tests unitaires pour LocationService

Fichier : `test/unit/location_service_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:alonu_app/core/services/location_service.dart';

void main() {
  group('LocationService', () {
    late LocationService locationService;

    setUp(() {
      locationService = LocationService();
    });

    test('calculateDistance calculates distance correctly', () {
      // Distance entre deux points
      // Lomé (6.1924, 1.1908) et un point à 1km
      final distance = LocationService.calculateDistance(
        6.1924,
        1.1908,
        6.2024,
        1.1908,
      );

      // Devrait être environ 11 km (1 degré de latitude ≈ 111 km)
      expect(distance, greaterThan(10));
      expect(distance, lessThan(12));
    });

    test('LocationException throws with message', () {
      final exception = LocationException('Permission refusée');
      expect(exception.toString(), equals('Permission refusée'));
    });

    test('toRad converts degrees to radians correctly', () {
      final rad = LocationService._toRad(180);
      expect(rad, closeTo(3.14159, 0.01));
    });
  });
}
```

### 2. Tests pour ArtisanModel

Fichier : `test/unit/models/artisan_model_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:alonu_app/data/models/artisan_model.dart';

void main() {
  group('ArtisanModel', () {
    test('ArtisanModel.fromJson creates instance from JSON', () {
      final json = {
        'id': 'test-id',
        'userId': 'user-id',
        'numeroEnr': 'ART-123',
        'telephone': '1234567890',
        'adresse': 'Test Address',
        'latitude': 6.1924,
        'longitude': 1.1908,
        'countryId': 'country-id',
        'actif': true,
        'subscriptionPaid': true,
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
        'user': {
          'id': 'user-id',
          'nom': 'Doe',
          'prenom': 'John',
          'email': 'john@test.com',
          'telephone': '1234567890',
          'country': {
            'id': 'tg',
            'code': 'TG',
            'name': 'Togo',
            'nameFr': 'Togo',
            'flagEmoji': '🇹🇬',
            'createdAt': '2024-01-01T00:00:00Z',
            'updatedAt': '2024-01-01T00:00:00Z',
          },
        },
        'country': {
          'id': 'tg',
          'code': 'TG',
          'name': 'Togo',
          'nameFr': 'Togo',
          'flagEmoji': '🇹🇬',
          'createdAt': '2024-01-01T00:00:00Z',
          'updatedAt': '2024-01-01T00:00:00Z',
        },
        'subCategories': [],
        'distance': 5.5,
      };

      final model = ArtisanModel.fromJson(json);

      expect(model.id, equals('test-id'));
      expect(model.numeroEnr, equals('ART-123'));
      expect(model.latitude, equals(6.1924));
      expect(model.distance, equals(5.5));
    });

    test('ArtisanModel.toJson serializes to JSON', () {
      final model = ArtisanModel(
        id: 'test-id',
        userId: 'user-id',
        numeroEnr: 'ART-123',
        telephone: '1234567890',
        countryId: 'tg',
        actif: true,
        subscriptionPaid: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        user: ArtisanUserModel(
          id: 'user-id',
          nom: 'Doe',
          prenom: 'John',
          email: 'john@test.com',
          telephone: '1234567890',
          country: CountryModel(
            id: 'tg',
            code: 'TG',
            name: 'Togo',
            nameFr: 'Togo',
            flagEmoji: '🇹🇬',
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
        ),
        country: CountryModel(
          id: 'tg',
          code: 'TG',
          name: 'Togo',
          nameFr: 'Togo',
          flagEmoji: '🇹🇬',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
        subCategories: [],
      );

      final json = model.toJson();

      expect(json['id'], equals('test-id'));
      expect(json['numeroEnr'], equals('ART-123'));
      expect(json['telephone'], equals('1234567890'));
    });

    test('ArtisanModel handles null values correctly', () {
      final json = {
        'id': 'test-id',
        'userId': 'user-id',
        'numeroEnr': 'ART-123',
        'telephone': '1234567890',
        'latitude': null,
        'longitude': null,
        'distance': null,
        'countryId': 'tg',
        'actif': true,
        'subscriptionPaid': true,
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
        'user': {
          'id': 'user-id',
          'nom': 'Doe',
          'prenom': 'John',
          'email': 'john@test.com',
          'telephone': '1234567890',
          'country': {
            'id': 'tg',
            'code': 'TG',
            'name': 'Togo',
            'nameFr': 'Togo',
            'flagEmoji': '🇹🇬',
            'createdAt': '2024-01-01T00:00:00Z',
            'updatedAt': '2024-01-01T00:00:00Z',
          },
        },
        'country': {
          'id': 'tg',
          'code': 'TG',
          'name': 'Togo',
          'nameFr': 'Togo',
          'flagEmoji': '🇹🇬',
          'createdAt': '2024-01-01T00:00:00Z',
          'updatedAt': '2024-01-01T00:00:00Z',
        },
        'subCategories': [],
      };

      final model = ArtisanModel.fromJson(json);

      expect(model.latitude, isNull);
      expect(model.longitude, isNull);
      expect(model.distance, isNull);
    });
  });
}
```

### 3. Tests pour les providers

Fichier : `test/unit/providers/artisan_provider_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:alonu_app/presentation/providers/artisan_provider.dart';

// Mock classes
class MockArtisanRemoteDataSource extends Mock {
  // Implementation
}

void main() {
  group('Artisan Providers', () {
    test('ArtisanFilterState initializes correctly', () {
      final state = ArtisanFilterState();

      expect(state.selectedCategory, isNull);
      expect(state.maxDistance, isNull);
      expect(state.searchQuery, isNull);
      expect(state.sortByDistance, isTrue);
    });

    test('ArtisanFilterState copyWith works correctly', () {
      final state = ArtisanFilterState(
        selectedCategory: 'cat-1',
        maxDistance: 10.0,
      );

      final newState = state.copyWith(selectedCategory: 'cat-2');

      expect(newState.selectedCategory, equals('cat-2'));
      expect(newState.maxDistance, equals(10.0));
      expect(newState.sortByDistance, isTrue);
    });

    test('ArtisanFilterNotifier updates state correctly', () {
      final container = ProviderContainer();
      final notifier = container.read(artisanFilterProvider.notifier);

      notifier.setCategory('cat-1');
      var state = container.read(artisanFilterProvider);
      expect(state.selectedCategory, equals('cat-1'));

      notifier.setMaxDistance(15.0);
      state = container.read(artisanFilterProvider);
      expect(state.maxDistance, equals(15.0));

      notifier.setSearchQuery('menuisier');
      state = container.read(artisanFilterProvider);
      expect(state.searchQuery, equals('menuisier'));

      notifier.toggleSortByDistance();
      state = container.read(artisanFilterProvider);
      expect(state.sortByDistance, isFalse);

      notifier.reset();
      state = container.read(artisanFilterProvider);
      expect(state.selectedCategory, isNull);
      expect(state.maxDistance, isNull);
      expect(state.searchQuery, isNull);
      expect(state.sortByDistance, isTrue);
    });
  });
}
```

## Tests d'intégration

### Test d'API complète

Fichier : `test/integration/location_artisans_integration_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:alonu_app/data/datasources/artisan_remote_data_source.dart';

void main() {
  group('Artisan API Integration Tests', () {
    late ArtisanRemoteDataSource dataSource;
    late Dio dio;

    setUpAll(() {
      dio = Dio(BaseOptions(
        baseUrl: 'https://api.alonu.shop/api',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ));
      dataSource = ArtisanRemoteDataSourceImpl(dio);
    });

    test('getCategories returns non-empty list', () async {
      final categories = await dataSource.getCategories();
      
      expect(categories, isNotEmpty);
      expect(categories.first.id, isNotNull);
    });

    test('getArtisansByLocation returns sorted results', () async {
      final artisans = await dataSource.getArtisansByLocation(
        latitude: 6.1924326,
        longitude: 1.1908736,
      );

      expect(artisans, isNotEmpty);
      
      // Vérifier que les résultats sont triés par distance
      for (int i = 0; i < artisans.length - 1; i++) {
        final dist1 = artisans[i].distance ?? 0;
        final dist2 = artisans[i + 1].distance ?? 0;
        expect(dist1, lessThanOrEqualTo(dist2));
      }
    });

    test('getArtisanDetail returns valid artisan', () async {
      // Utiliser un ID réel si disponible
      final artisanId = 'c0117d1f-a81b-4931-9dcc-9352d5219704';
      
      final artisan = await dataSource.getArtisanDetail(artisanId);
      
      expect(artisan.id, equals(artisanId));
      expect(artisan.user.nom, isNotEmpty);
    });
  });
}
```

## Tests de performance

### Test de calcul de distance

Fichier : `test/performance/distance_calculation_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:alonu_app/core/services/location_service.dart';

void main() {
  group('Distance Calculation Performance', () {
    test('calculateDistance performs efficiently', () {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 10000; i++) {
        LocationService.calculateDistance(6.1924, 1.1908, 6.2024, 1.1908);
      }

      stopwatch.stop();
      
      // Devrait compléter en moins de 1 seconde
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
  });
}
```

## Exécuter les tests

### Tous les tests
```bash
flutter test
```

### Tests spécifiques
```bash
flutter test test/unit/location_service_test.dart
flutter test test/unit/models/
flutter test test/unit/providers/
```

### Avec couverture de code
```bash
flutter test --coverage
# Puis générer un rapport avec lcov (optionnel)
lcov -r coverage/lcov.info 'lib/generated*' -o coverage/lcov.info
genhtml coverage/lcov.info -o coverage/html
```

## Checklist de test

- [ ] Permission de localisation accordée
- [ ] Service de localisation activé
- [ ] Position retournée correctement
- [ ] Artisans triés par distance
- [ ] Filtres appliqués correctement
- [ ] Recherche fonctionne
- [ ] Rafraîchissement des données
- [ ] Gestion des erreurs
- [ ] Pas de fuite mémoire
- [ ] Performance acceptable
