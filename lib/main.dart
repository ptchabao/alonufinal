import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'presentation/routes/app_router.dart';
import 'presentation/bloc/api_providers.dart' show themeModeProvider;
import 'presentation/bloc/favorites_provider.dart' show favoritesBoxName;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  // Favoris (produits/artisans) : purement local, l'API ALONU n'a pas de
  // notion de favoris/wishlist.
  await Hive.initFlutter();
  await Hive.openBox<List>(favoritesBoxName);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'ALONU',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
