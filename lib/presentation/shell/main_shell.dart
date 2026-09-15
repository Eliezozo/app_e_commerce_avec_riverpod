import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/cart_icon_key_provider.dart';
import '../../providers/cart_provider.dart';
import '../cart/cart_screen.dart';
import '../catalog/catalog_screen.dart';
import '../favorites/favorites_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;

  static const _titles = [
    AppStrings.catalogTitle,
    AppStrings.favoritesTitle,
    AppStrings.cartTitle,
    AppStrings.profileTitle,
  ];

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartItemCountProvider);
    final cartIconKey = ref.watch(cartIconKeyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          CatalogScreen(),
          FavoritesScreen(),
          CartScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: AppStrings.catalogTitle,
          ),
          const NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: AppStrings.favoritesTitle,
          ),
          NavigationDestination(
            icon: KeyedSubtree(
              key: cartIconKey,
              child: _CartBadgeIcon(
                count: cartCount,
                outlined: true,
              ),
            ),
            selectedIcon: _CartBadgeIcon(count: cartCount, outlined: false),
            label: AppStrings.cartTitle,
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: AppStrings.profileTitle,
          ),
        ],
      ),
    );
  }
}

class _CartBadgeIcon extends StatelessWidget {
  const _CartBadgeIcon({required this.count, required this.outlined});

  final int count;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(count),
      tween: Tween(begin: 0.82, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Badge(
        isLabelVisible: count > 0,
        backgroundColor: AppColors.primary,
        label: Text('$count'),
        child: Icon(
          outlined ? Icons.shopping_bag_outlined : Icons.shopping_bag,
        ),
      ),
    );
  }
}
