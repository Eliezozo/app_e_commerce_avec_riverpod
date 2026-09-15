import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/product_network_image.dart';
import '../../../data/models/product.dart';
import '../../../providers/cart_icon_key_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/favorites_provider.dart';
import '../../widgets/add_to_cart_animation.dart';
import '../product_detail_screen.dart';

class ProductCard extends ConsumerWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(isFavoriteProvider(product.id));

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ProductDetailScreen(productId: product.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'product-image-${product.id}',
                    child: ProductNetworkImage(url: product.imageUrl),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Material(
                      color: AppColors.background.withValues(alpha: 0.55),
                      shape: const CircleBorder(),
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => ref
                            .read(favoritesProvider.notifier)
                            .toggle(product.id),
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite
                              ? AppColors.error
                              : AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 16, color: AppColors.star),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _AddButton(product: product),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends ConsumerStatefulWidget {
  const _AddButton({required this.product});

  final Product product;

  @override
  ConsumerState<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends ConsumerState<_AddButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.product.isInStock;

    return AnimatedScale(
      scale: _pressed ? 0.92 : 1,
      duration: const Duration(milliseconds: 120),
      child: SizedBox(
        width: double.infinity,
        height: 36,
        child: FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(36),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          onPressed: enabled
              ? () {
                  setState(() => _pressed = true);
                  ref.read(cartProvider.notifier).add(widget.product);
                  playAddToCartAnimation(
                    context: context,
                    targetKey: ref.read(cartIconKeyProvider),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${widget.product.name} — ${AppStrings.addedToCart}',
                      ),
                      duration: const Duration(milliseconds: 900),
                    ),
                  );
                  Future<void>.delayed(const Duration(milliseconds: 140), () {
                    if (mounted) setState(() => _pressed = false);
                  });
                }
              : null,
          child: Text(
            enabled ? AppStrings.addToCart : AppStrings.outOfStock,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }
}
