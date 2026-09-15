import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/datasources/favorites_local_datasource.dart';
import '../data/datasources/product_local_datasource.dart';
import '../data/repositories/favorites_repository.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/user_repository.dart';

/// Injecté au démarrage via `ProviderScope.overrides`.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences doit être fourni au lancement.');
});

final productLocalDataSourceProvider = Provider<ProductLocalDataSource>((ref) {
  return ProductLocalDataSource();
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(productLocalDataSourceProvider));
});

final favoritesLocalDataSourceProvider =
    Provider<FavoritesLocalDataSource>((ref) {
  return FavoritesLocalDataSource(ref.watch(sharedPreferencesProvider));
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository(ref.watch(favoritesLocalDataSourceProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});
