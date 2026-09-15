import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/product.dart';
import 'dependency_providers.dart';

/// Catalogue asynchrone (JSON local + latence simulée) via [AsyncValue].
final productsProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).getProducts();
});

final productByIdProvider =
    FutureProvider.family<Product, String>((ref, id) async {
  final products = await ref.watch(productsProvider.future);
  for (final product in products) {
    if (product.id == id) return product;
  }
  return ref.watch(productRepositoryProvider).getProductById(id);
});

final productCategoriesProvider = Provider<List<String>>((ref) {
  return ref.watch(productsProvider).maybeWhen(
        data: (products) {
          final categories = products.map((p) => p.category).toSet().toList()
            ..sort();
          return categories;
        },
        orElse: () => const <String>[],
      );
});
