import 'package:riverpod_practice/notifier_provider/models.dart';

class CartState {
  final List<CartItem> items;

  const CartState({
    this.items = const [],
  });

  // ✅ Total price — saare items ka sum
  double get totalPrice {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // ✅ Total items count — saari quantities ka sum
  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  // ✅ Is product ka cart mein quantity (0 = cart mein nahi hai)
  int quantityOf(int productId) {
    final index = items.indexWhere((item) => item.product.id == productId);
    if (index == -1) return 0;
    return items[index].quantity;
  }

  // ✅ copyWith — naya CartState banao
  CartState copyWith({List<CartItem>? items}) {
    return CartState(
      items: items ?? this.items,
    );
  }
}