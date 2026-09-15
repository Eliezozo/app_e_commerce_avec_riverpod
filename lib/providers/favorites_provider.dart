import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/exceptions/app_exception.dart';
import '../data/models/product.dart';
import '../data/repositories/favorites_repository.dart';
import 'dependency_providers.dart';
import 'product_providers.dart';

class FavoritesNotifier extends StateNotifier<AsyncValue<Set<String>>> {
  FavoritesNotifier(this._repository) : super(const AsyncValue.loading()) {
    _load();
  }

  final FavoritesRepository _repository;

  Future<void> _load() async {
    state = await AsyncValue.guard(_repository.loadIds);
  }

  Future<void> refresh() => _load();

  Future<void> toggle(String productId) async {
    final current = {...?state.valueOrNull};
    if (!current.add(productId)) {
      current.remove(productId);
    }
    state = AsyncValue.data(current);
    try {
      await _repository.saveIds(current);
    } on AppException catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  bool contains(String productId) {
    return state.valueOrNull?.contains(productId) ?? false;
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, AsyncValue<Set<String>>>((ref) {
  return FavoritesNotifier(ref.watch(favoritesRepositoryProvider));
});

final isFavoriteProvider = Provider.family<bool, String>((ref, productId) {
  return ref.watch(favoritesProvider).maybeWhen(
        data: (ids) => ids.contains(productId),
        orElse: () => false,
      );
});

final favoriteProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final favorites = ref.watch(favoritesProvider);
  final products = ref.watch(productsProvider);

  return products.when(
    loading: () => const AsyncValue.loading(),
    error: AsyncValue.error,
    data: (catalog) {
      return favorites.when(
        loading: () => const AsyncValue.loading(),
        error: AsyncValue.error,
        data: (ids) {
          final items = catalog
              .where((product) => ids.contains(product.id))
              .toList(growable: false);
          return AsyncValue.data(items);
        },
      );
    },
  );
});
