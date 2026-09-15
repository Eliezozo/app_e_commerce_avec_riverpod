import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/exceptions/app_exception.dart';
import '../../core/widgets/async_error_view.dart';
import '../../core/widgets/catalog_skeleton.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/product_providers.dart';
import '../catalog/widgets/product_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteProductsProvider);

    return favoritesAsync.when(
      loading: () => const CatalogSkeleton(),
      error: (error, _) => AsyncErrorView(
        message: error is AppException ? error.message : AppStrings.loadError,
        onRetry: () {
          ref.invalidate(productsProvider);
          ref.read(favoritesProvider.notifier).refresh();
        },
      ),
      data: (products) {
        if (products.isEmpty) {
          return const EmptyState(
            icon: Icons.favorite_border,
            title: AppStrings.emptyFavorites,
            subtitle: AppStrings.emptyFavoritesHint,
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 268,
          ),
          itemBuilder: (context, index) {
            return ProductCard(product: products[index]);
          },
        );
      },
    );
  }
}
