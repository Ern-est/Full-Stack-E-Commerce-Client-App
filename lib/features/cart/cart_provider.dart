import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:full_stack_e_commerce_app/features/products/models/product.dart';

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartItem {
  final Product product;
  final int quantity;
  final String selectedVariant;

  CartItem({
    required this.product,
    required this.quantity,
    required this.selectedVariant,
  });

  // Helper to copy with updated quantity
  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
      selectedVariant: selectedVariant,
    );
  }
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  /// Add product to cart or update quantity if already exists
  void addToCart(Product product, int quantityChange, String variant) {
    final index = state.indexWhere(
      (item) =>
          item.product.id == product.id && item.selectedVariant == variant,
    );

    if (index >= 0) {
      final updatedItem = state[index];
      final newQuantity = updatedItem.quantity + quantityChange;

      if (newQuantity <= 0) {
        removeFromCart(product.id, variant);
      } else {
        // ✅ Create new state list to trigger rebuild
        final newState = [...state];
        newState[index] = updatedItem.copyWith(quantity: newQuantity);
        state = newState;
      }
    } else if (quantityChange > 0) {
      state = [
        ...state,
        CartItem(
          product: product,
          quantity: quantityChange,
          selectedVariant: variant,
        ),
      ];
    }
  }

  /// Remove a specific product-variant from cart
  void removeFromCart(String productId, String variant) {
    state = state
        .where(
          (item) =>
              item.product.id != productId || item.selectedVariant != variant,
        )
        .toList();
  }

  /// Clear the entire cart
  void clearCart() => state = [];

  /// Calculate total price
  double get totalPrice {
    return state.fold(
      0,
      (sum, item) => sum + item.product.displayPrice * item.quantity,
    );
  }

  /// Calculate total quantity of items in cart
  int get totalItems {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }
}
