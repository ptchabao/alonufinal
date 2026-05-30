import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alonu_app/presentation/pages/artisan_detail_screen.dart';
import 'package:alonu_app/presentation/bloc/api_providers.dart';

void main() {
  testWidgets('ArtisanDetail shows contact email and whatsapp', (tester) async {
    final mockArtisan = {
      'id': 'test',
      'user': {
        'prenom': 'Jean',
        'nom': 'Dupont',
        'email': 'jean.dupont@example.com',
        'telephone': '+22912345678',
      },
      'whatsapp': '+22912345678',
      'adresse': 'Cotonou',
      // lat/lng included but we won't assert map rendering in widget test
      'latitude': 6.3703,
      'longitude': 2.3912,
      'subCategories': [],
      'actif': true,
    };

    // Create fake providers that return our mock data
    final fakeDetail = FutureProvider.autoDispose.family<dynamic, String>((ref, id) async => mockArtisan);
    final fakeProducts = FutureProvider.autoDispose<List<dynamic>>((ref) async => []);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          artisanDetailProvider.overrideWithProvider(fakeDetail),
          productsProvider.overrideWithProvider(fakeProducts),
        ],
        child: MaterialApp(
          home: ArtisanDetailScreen(artisanId: 'test'),
        ),
      ),
    );

    // Allow async widgets to settle
    await tester.pumpAndSettle();

    expect(find.text('Jean Dupont'), findsOneWidget);
    expect(find.text('jean.dupont@example.com'), findsOneWidget);
    expect(find.text('+22912345678'), findsWidgets);
    expect(find.text('Contact'), findsOneWidget);
  });
}
