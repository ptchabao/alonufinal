import 'package:alonu_app/presentation/pages/main_bottom_nav_bar.dart';
import 'package:alonu_app/presentation/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets(
    'MainBottomNavBar builds inside a shell route without GoRouter state assertion',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          ShellRoute(
            builder: (context, state, child) => MainBottomNavBar(child: child),
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const Scaffold(body: Text('Home')),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pump();

      expect(find.text('Accueil'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
    },
  );

  test('AppRouter.createRouter returns independent router instances', () {
    final firstRouter = AppRouter.createRouter(false);
    final secondRouter = AppRouter.createRouter(false);

    expect(firstRouter, isNot(same(secondRouter)));
  });
}
