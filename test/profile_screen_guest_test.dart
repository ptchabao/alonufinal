import 'package:alonu_app/presentation/bloc/auth_provider.dart';
import 'package:alonu_app/presentation/pages/search_orders_profile_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAuthNotifier extends StateNotifier<AuthState> {
  MockAuthNotifier() : super(AuthState());
}

void main() {
  testWidgets('ProfileScreen shows login/register CTA when logged out', (
    tester,
  ) async {
    final mockNotifier = MockAuthNotifier();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authProvider.overrideWith((ref) => mockNotifier)],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    expect(
      find.text('Connectez-vous pour accéder à votre profil'),
      findsOneWidget,
    );
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.text('Créer un compte'), findsOneWidget);
    expect(find.text('Mes Commandes'), findsNothing);
  });
}
