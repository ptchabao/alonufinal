import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:alonu_app/data/datasources/artisan_remote_data_source.dart';
import 'package:alonu_app/data/models/artisan_model.dart';
import 'package:alonu_app/data/repositories/artisan_remote_repository_impl.dart';
import 'package:alonu_app/domain/entities/artisan.dart';

import 'artisan_remote_repository_impl_test.mocks.dart';

Map<String, dynamic> _artisanJson({String id = 'artisan-1'}) => {
  'id': id,
  'userId': 'user-1',
  'numeroEnr': 'REG123',
  'telephone': '+22890123456',
  'countryId': 'country-1',
  'actif': true,
  'subscriptionPaid': false,
  'createdAt': '2024-01-01T00:00:00.000Z',
  'updatedAt': '2024-01-01T00:00:00.000Z',
  'user': {
    'id': 'user-1',
    'nom': 'Doe',
    'prenom': 'John',
    'email': 'john@example.com',
    'telephone': '+22890123456',
    'country': {
      'id': 'country-1',
      'code': 'TG',
      'name': 'Togo',
      'nameFr': 'Togo',
      'flagEmoji': '🇹🇬',
      'createdAt': '2024-01-01T00:00:00.000Z',
      'updatedAt': '2024-01-01T00:00:00.000Z',
    },
  },
  'country': {
    'id': 'country-1',
    'code': 'TG',
    'name': 'Togo',
    'nameFr': 'Togo',
    'flagEmoji': '🇹🇬',
    'createdAt': '2024-01-01T00:00:00.000Z',
    'updatedAt': '2024-01-01T00:00:00.000Z',
  },
  'subCategories': [],
};

Artisan _artisanEntity({String id = 'artisan-1'}) => ArtisanModel.fromJson(_artisanJson(id: id)).toEntity();

@GenerateMocks([ArtisanRemoteDataSource])
void main() {
  group('RealisationModel', () {
    test('fromJson maps libelle to Realisation.title', () {
      final model = RealisationModel.fromJson({
        'id': 'r1',
        'artisanId': 'artisan-1',
        'libelle': 'Cuisine sur mesure',
        'description': 'Fabrication complète',
        'images': ['https://cdn.example.com/1.jpg'],
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      });

      expect(model.libelle, 'Cuisine sur mesure');
      final entity = model.toEntity();
      expect(entity.title, 'Cuisine sur mesure');
      expect(entity.imageUrls, ['https://cdn.example.com/1.jpg']);
    });
  });

  group('ArtisanRemoteRepositoryImpl.createArtisan', () {
    test('builds a CreateArtisanDto-shaped payload from the entity', () async {
      final mockDataSource = MockArtisanRemoteDataSource();
      final repository = ArtisanRemoteRepositoryImpl(mockDataSource);
      final artisan = _artisanEntity();

      when(mockDataSource.createArtisan(any)).thenAnswer(
        (_) async => ArtisanModel.fromJson(_artisanJson()),
      );

      final result = await repository.createArtisan(artisan);

      expect(result.isRight(), true);
      final captured = verify(mockDataSource.createArtisan(captureAny)).captured.single
          as Map<String, dynamic>;
      expect(captured['userId'], artisan.userId);
      expect(captured['numeroEnr'], artisan.numeroEnr);
      expect(captured['telephone'], artisan.telephone);
      expect(captured['countryId'], artisan.countryId);
      expect(captured['subCategoryIds'], isA<List>());
    });
  });

  group('ArtisanRemoteRepositoryImpl réalisations', () {
    test('getRealisations maps remote models to entities', () async {
      final mockDataSource = MockArtisanRemoteDataSource();
      final repository = ArtisanRemoteRepositoryImpl(mockDataSource);

      when(mockDataSource.getRealisations('artisan-1')).thenAnswer((_) async => [
            RealisationModel.fromJson({
              'id': 'r1',
              'artisanId': 'artisan-1',
              'libelle': 'Portfolio 1',
              'images': [],
              'createdAt': '2024-01-01T00:00:00.000Z',
              'updatedAt': '2024-01-01T00:00:00.000Z',
            }),
          ]);

      final result = await repository.getRealisations('artisan-1');

      expect(result.isRight(), true);
      result.fold((_) => fail('expected Right'), (list) {
        expect(list, hasLength(1));
        expect(list.first.title, 'Portfolio 1');
      });
    });

    test('deleteRealisation delegates to the data source', () async {
      final mockDataSource = MockArtisanRemoteDataSource();
      final repository = ArtisanRemoteRepositoryImpl(mockDataSource);

      when(mockDataSource.deleteRealisation('artisan-1', 'r1'))
          .thenAnswer((_) async {});

      final result = await repository.deleteRealisation('artisan-1', 'r1');

      expect(result.isRight(), true);
      verify(mockDataSource.deleteRealisation('artisan-1', 'r1')).called(1);
    });
  });

  group('RemoteProductRepositoryImpl mapping', () {
    test('maps isService=true and object-shaped images (regression: previously read type/imageUrls)', () async {
      final mockDataSource = MockArtisanRemoteDataSource();
      final repository = RemoteProductRepositoryImpl(mockDataSource);

      when(mockDataSource.getProductDetail('p1')).thenAnswer((_) async => {
            'id': 'p1',
            'artisanId': 'artisan-1',
            'title': 'Réparation plomberie',
            'price': 15000,
            'currency': 'XOF',
            'isService': true,
            'active': true,
            'images': [
              {'id': 'img1', 'url': 'https://cdn.example.com/img1.jpg', 'order': 0},
            ],
            'viewsCount': 3,
            'createdAt': '2024-01-01T00:00:00.000Z',
          });

      final result = await repository.getProduct('p1');

      expect(result.isRight(), true);
      result.fold((_) => fail('expected Right'), (product) {
        expect(product.type, ProductType.SERVICE);
        expect(product.imageUrls, ['https://cdn.example.com/img1.jpg']);
        expect(product.views, 3);
      });
    });
  });
}
