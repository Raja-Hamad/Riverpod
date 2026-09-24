// ✅ Product — jo shop mein available hai
class Product {
  final int id;
  final String name;
  final double price;

  const Product({required this.id, required this.name, required this.price});
}

// ✅ CartItem — jo user ke cart mein hai (quantity ke saath)
class CartItem {
  final Product product;
  final int quantity;

  const CartItem({required this.product, this.quantity = 1});

  // Total price for this item (price × quantity)
  double get totalPrice => product.price * quantity;

  // copyWith — naya CartItem banao, kuch fields change kar ke
  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
