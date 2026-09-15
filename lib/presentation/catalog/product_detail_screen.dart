import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/exceptions/app_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/async_error_view.dart';
import '../../core/widgets/product_network_image.dart';
import '../../providers/cart_icon_key_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/product_providers.dart';
import '../widgets/add_to_cart_animation.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productByIdProvider(productId));
    final isFavorite = ref.watch(isFavoriteProvider(productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.catalogTitle),
        actions: [
          IconButton(
            onPressed: () =>
                ref.read(favoritesProvider.notifier).toggle(productId),
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? AppColors.error : AppColors.textSecondary,
            ),
          ),
        ],
      ),
      body: productAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => AsyncErrorView(
          message: error is AppException ? error.message : AppStrings.loadError,
          onRetry: () => ref.invalidate(productByIdProvider(productId)),
        ),
        data: (product) {
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: AspectRatio(
                        aspectRatio: 1.1,
                        child: Hero(
                          tag: 'product-image-${product.id}',
                          child: ProductNetworkImage(url: product.imageUrl),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      product.category,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.star,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${product.rating.toStringAsFixed(1)}  ·  ${product.reviewCount} ${AppStrings.reviews}',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                        const Spacer(),
                        Text(
                          product.formattedPrice,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      product.isInStock
                          ? '${AppStrings.inStock} (${product.stock})'
                          : AppStrings.outOfStock,
                      style: TextStyle(
                        color: product.isInStock
                            ? AppColors.textSecondary
                            : AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      AppStrings.description,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: const TextStyle(
                        height: 1.45,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: FilledButton.icon(
                    onPressed: product.isInStock
                        ? () {
                            ref.read(cartProvider.notifier).add(product);
                            playAddToCartAnimation(
                              context: context,
                              targetKey: ref.read(cartIconKeyProvider),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text(AppStrings.addedToCart)),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: Text(
                      product.isInStock
                          ? AppStrings.addToCart
                          : AppStrings.outOfStock,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
