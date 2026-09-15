import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_strings.dart';
import '../data/models/catalog_filter.dart';
import '../data/models/product.dart';
import 'product_providers.dart';

class CatalogFilterNotifier extends StateNotifier<CatalogFilter> {
  CatalogFilterNotifier() : super(const CatalogFilter());

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setCategory(String? category) {
    if (category == null) {
      state = state.copyWith(clearCategory: true);
      return;
    }
    state = state.copyWith(category: category);
  }

  void setSort(ProductSort sort) {
    state = state.copyWith(sort: sort);
  }

  void reset() {
    state = const CatalogFilter();
  }
}

final catalogFilterProvider =
    StateNotifierProvider<CatalogFilterNotifier, CatalogFilter>((ref) {
  return CatalogFilterNotifier();
});

/// Liste dérivée : filtre + tri, sans I/O.
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final filter = ref.watch(catalogFilterProvider);
  return ref.watch(productsProvider).whenData((products) {
    final query = filter.query.trim().toLowerCase();
    var result = products.where((product) {
      final matchesCategory =
          filter.category == null || product.category == filter.category;
      final matchesQuery = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();

    result.sort((a, b) {
      switch (filter.sort) {
        case ProductSort.nameAsc:
          return a.name.compareTo(b.name);
        case ProductSort.priceAsc:
          return a.price.compareTo(b.price);
        case ProductSort.priceDesc:
          return b.price.compareTo(a.price);
        case ProductSort.ratingDesc:
          return b.rating.compareTo(a.rating);
      }
    });
    return result;
  });
});

String labelForSort(ProductSort sort) {
  switch (sort) {
    case ProductSort.nameAsc:
      return AppStrings.sortNameAsc;
    case ProductSort.priceAsc:
      return AppStrings.sortPriceAsc;
    case ProductSort.priceDesc:
      return AppStrings.sortPriceDesc;
    case ProductSort.ratingDesc:
      return AppStrings.sortRatingDesc;
  }
}
