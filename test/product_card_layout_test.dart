import 'package:alonu_app/presentation/widgets/app_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ProductCard fits inside constrained grid cell without overflow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 180,
              height: 272,
              child: ProductCard(
                imageUrl: 'https://example.com/image.jpg',
                title:
                    'Produit artisanal très long avec un nom qui peut prendre plusieurs lignes',
                artisanName:
                    'Artisan très long pour vérifier la condensation du texte',
                price: '8000 XOF',
                type: 'Produit',
                rating: 4.8,
                onTap: () {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('ArtisanCard fits inside constrained height without overflow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 180,
              height: 232,
              child: ArtisanCard(
                imageUrl: 'https://example.com/image.jpg',
                name: 'Amadou Diallo',
                specialty: 'Menuiserie artisanale de luxe',
                rating: 4.9,
                reviewCount: 128,
                distance: '1.2 km',
                isMasterArtisan: true,
                onTap: () {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'ProductCard renders without overflow when height is unconstrained',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ProductCard(
                imageUrl: 'https://example.com/image.jpg',
                title:
                    'Produit artisanal très long avec un nom qui peut prendre plusieurs lignes',
                artisanName:
                    'Artisan très long pour vérifier la condensation du texte',
                price: '8000 XOF',
                type: 'Produit',
                rating: 4.8,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'ArtisanCard renders without overflow when height is unconstrained',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ArtisanCard(
                imageUrl: 'https://example.com/image.jpg',
                name: 'Amadou Diallo',
                specialty: 'Menuiserie artisanale de luxe',
                rating: 4.9,
                reviewCount: 128,
                distance: '1.2 km',
                isMasterArtisan: true,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    },
  );
}
