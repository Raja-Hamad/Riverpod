import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_practice/notifier_provider/cart_states.dart';
import 'package:riverpod_practice/notifier_provider/models.dart';

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    // ✅ Initial state — khaali cart
    return const CartState();
  }

  // ✅ 1. Add to cart (agar already hai to quantity +1)
  void addToCart(Product product) {
    final index = state.items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (index == -1) {
      // Naya item — cart mein add karo
      state = state.copyWith(
        items: [...state.items, CartItem(product: product)],
      );
    } else {
      // Already hai — quantity +1 karo
      final updatedItems = [...state.items];
      updatedItems[index] = updatedItems[index].copyWith(
        quantity: updatedItems[index].quantity + 1,
      );
      state = state.copyWith(items: updatedItems);
    }
  }

  // ✅ 2. Increase quantity
  void increaseQuantity(int productId) {
    final index = state.items.indexWhere(
      (item) => item.product.id == productId,
    );

    if (index == -1) return; // Item cart mein nahi hai

    final updatedItems = [...state.items];
    updatedItems[index] = updatedItems[index].copyWith(
      quantity: updatedItems[index].quantity + 1,
    );
    state = state.copyWith(items: updatedItems);
  }

  // ✅ 3. Decrease quantity (agar 1 hai to remove)
  void decreaseQuantity(int productId) {
    final index = state.items.indexWhere(
      (item) => item.product.id == productId,
    );

    if (index == -1) return;

    final currentQuantity = state.items[index].quantity;

    if (currentQuantity <= 1) {
      // 1 ya kam hai — remove karo
      removeFromCart(productId);
    } else {
      // Quantity -1 karo
      final updatedItems = [...state.items];
      updatedItems[index] = updatedItems[index].copyWith(
        quantity: currentQuantity - 1,
      );
      state = state.copyWith(items: updatedItems);
    }
  }

  // ✅ 4. Remove from cart
  void removeFromCart(int productId) {
    state = state.copyWith(
      items: state.items
          .where((item) => item.product.id != productId)
          .toList(),
    );
  }

  // ✅ 5. Clear cart
  void clearCart() {
    state = state.copyWith(items: []);
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(() {
  return CartNotifier();
});