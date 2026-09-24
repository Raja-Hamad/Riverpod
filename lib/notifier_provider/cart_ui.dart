import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_practice/notifier_provider/cart_notifier.dart';

import 'package:riverpod_practice/notifier_provider/models.dart';

class ShoppingCartScreen extends ConsumerWidget {
  const ShoppingCartScreen({super.key});

  // ✅ Demo products
  final List<Product> products = const [
    Product(id: 1, name: 'Apple', price: 1.50),
    Product(id: 2, name: 'Banana', price: 0.80),
    Product(id: 3, name: 'Orange', price: 2.00),
    Product(id: 4, name: 'Mango', price: 3.50),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ State sunna
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          // ✅ Total items badge
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Items: ${cartState.totalItems}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ Products list
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final quantity = cartState.quantityOf(product.id);

                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                  trailing: quantity == 0
                      // ✅ Not in cart — Add button
                      ? ElevatedButton(
                          onPressed: () {
                            ref.read(cartProvider.notifier).addToCart(product);
                          },
                          child: const Text('Add'),
                        )
                      // ✅ In cart — Quantity controls
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                ref
                                    .read(cartProvider.notifier)
                                    .decreaseQuantity(product.id);
                              },
                            ),
                            Text('$quantity'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                ref
                                    .read(cartProvider.notifier)
                                    .increaseQuantity(product.id);
                              },
                            ),
                          ],
                        ),
                );
              },
            ),
          ),

          // ✅ Divider
          const Divider(thickness: 2),

          // ✅ Cart summary
          Expanded(
            flex: 1,
            child: cartState.items.isEmpty
                ? const Center(
                    child: Text(
                      'Cart is empty',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: cartState.items.length,
                          itemBuilder: (context, index) {
                            final item = cartState.items[index];
                            return ListTile(
                              dense: true,
                              title: Text(item.product.name),
                              subtitle: Text(
                                '${item.quantity} × \$${item.product.price.toStringAsFixed(2)}',
                              ),
                              trailing: Text(
                                '\$${item.totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // ✅ Total price
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${cartState.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ✅ Clear cart button
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(cartProvider.notifier).clearCart();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Clear Cart'),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
