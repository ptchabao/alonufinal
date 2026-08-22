import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod/riverpod.dart';

/// Favoris (produits + artisans) — purement local : l'API ALONU n'expose
/// aucune notion de favoris/wishlist, donc rien n'est synchronisé côté
/// serveur. Persisté via Hive (box ouverte dans main.dart avant runApp).
const favoritesBoxName = 'favorites';
const _productIdsKey = 'productIds';
const _artisanIdsKey = 'artisanIds';

class FavoritesState {
  final Set<String> productIds;
  final Set<String> artisanIds;

  const FavoritesState({
    this.productIds = const {},
    this.artisanIds = const {},
  });

  bool isProductFavorite(String id) => productIds.contains(id);
  bool isArtisanFavorite(String id) => artisanIds.contains(id);

  FavoritesState copyWith({Set<String>? productIds, Set<String>? artisanIds}) {
    return FavoritesState(
      productIds: productIds ?? this.productIds,
      artisanIds: artisanIds ?? this.artisanIds,
    );
  }
}

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  FavoritesNotifier() : super(const FavoritesState()) {
    _load();
  }

  Box<List> get _box => Hive.box<List>(favoritesBoxName);

  void _load() {
    final products = _box.get(_productIdsKey)?.cast<String>().toSet() ?? {};
    final artisans = _box.get(_artisanIdsKey)?.cast<String>().toSet() ?? {};
    state = FavoritesState(productIds: products, artisanIds: artisans);
  }

  void toggleProduct(String productId) {
    final updated = {...state.productIds};
    if (!updated.remove(productId)) {
      updated.add(productId);
    }
    state = state.copyWith(productIds: updated);
    _box.put(_productIdsKey, updated.toList());
  }

  void toggleArtisan(String artisanId) {
    final updated = {...state.artisanIds};
    if (!updated.remove(artisanId)) {
      updated.add(artisanId);
    }
    state = state.copyWith(artisanIds: updated);
    _box.put(_artisanIdsKey, updated.toList());
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier();
});
