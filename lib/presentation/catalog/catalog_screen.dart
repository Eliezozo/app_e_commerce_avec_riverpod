import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/exceptions/app_exception.dart';
import '../../core/widgets/async_error_view.dart';
import '../../core/widgets/catalog_skeleton.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/catalog_filter_provider.dart';
import '../../providers/product_providers.dart';
import 'widgets/catalog_filter_bar.dart';
import 'widgets/product_card.dart';

class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(filteredProductsProvider);

    return Column(
      children: [
        const CatalogFilterBar(),
        Expanded(
          child: productsAsync.when(
            loading: () => const CatalogSkeleton(),
            error: (error, _) => AsyncErrorView(
              message: error is AppException
                  ? error.message
                  : AppStrings.loadError,
              onRetry: () => ref.invalidate(productsProvider),
            ),
            data: (products) {
              if (products.isEmpty) {
                return const EmptyState(
                  icon: Icons.search_off_rounded,
                  title: AppStrings.emptySearch,
                  subtitle: '',
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
          ),
        ),
      ],
    );
  }
}
