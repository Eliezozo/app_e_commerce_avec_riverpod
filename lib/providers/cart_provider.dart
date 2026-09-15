import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/cart_item.dart';
import '../data/models/product.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super(const []);

  void add(Product product) {
    if (!product.isInStock) return;
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index < 0) {
      state = [...state, CartItem(product: product, quantity: 1)];
      return;
    }
    final current = state[index];
    if (current.quantity >= product.stock) return;
    state = [
      for (var i = 0; i < state.length; i++)
        if (i == index)
          current.copyWith(quantity: current.quantity + 1)
        else
          state[i],
    ];
  }

  void increment(String productId) {
    final index = state.indexWhere((item) => item.product.id == productId);
    if (index < 0) return;
    final current = state[index];
    if (current.quantity >= current.product.stock) return;
    state = [
      for (var i = 0; i < state.length; i++)
        if (i == index)
          current.copyWith(quantity: current.quantity + 1)
        else
          state[i],
    ];
  }

  void decrement(String productId) {
    final index = state.indexWhere((item) => item.product.id == productId);
    if (index < 0) return;
    final current = state[index];
    if (current.quantity <= 1) {
      remove(productId);
      return;
    }
    state = [
      for (var i = 0; i < state.length; i++)
        if (i == index)
          current.copyWith(quantity: current.quantity - 1)
        else
          state[i],
    ];
  }

  void remove(String productId) {
    state = [
      for (final item in state)
        if (item.product.id != productId) item,
    ];
  }

  void clear() {
    state = const [];
  }
}

final cartProvider =
    StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).fold<int>(
        0,
        (sum, item) => sum + item.quantity,
      );
});

final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).fold<double>(
        0,
        (sum, item) => sum + item.lineTotal,
      );
});

final formattedCartTotalProvider = Provider<String>((ref) {
  return '${ref.watch(cartTotalProvider).toStringAsFixed(2)} €';
});
