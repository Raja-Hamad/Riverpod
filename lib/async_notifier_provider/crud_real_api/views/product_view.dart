import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_practice/async_notifier_provider/crud_real_api/providers/product_providers.dart';

import '../models/product.dart';

class ProductsPage extends ConsumerWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Products',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),
            Text(
              'Manage your products',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(productsProvider);
            },
            icon: const Icon(Icons.refresh_rounded),
          ),

          const SizedBox(width: 8),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddProductSheet(context: context, ref: ref);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Product'),
      ),

      body: productsAsync.when(
        loading: () {
          return const _LoadingView();
        },

        error: (error, stackTrace) {
          return _ErrorView(
            error: error,
            onRetry: () {
              ref.invalidate(productsProvider);
            },
          );
        },

        data: (products) {
          if (products.isEmpty) {
            return _EmptyView(
              onAdd: () {
                _showAddProductSheet(context: context, ref: ref);
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(productsProvider);

              await ref.read(productsProvider.future);
            },

            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),

              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),

              children: [
                _SummaryCard(count: products.length),

                const SizedBox(height: 24),

                const Text(
                  'All Products',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                ),

                const SizedBox(height: 14),

                ...products.map((product) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),

                    child: _ProductCard(
                      product: product,
                      onEdit: () {
                        _showEditProductSheet(
                          context: context,
                          ref: ref,
                          product: product,
                        );
                      },
                      onDelete: () {
                        _deleteProduct(
                          context: context,
                          ref: ref,
                          product: product,
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // ADD PRODUCT SHEET
  // ============================================================

  static void _showAddProductSheet({
    required BuildContext context,
    required WidgetRef ref,
  }) {
    final formKey = GlobalKey<FormState>();

    final titleController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();
    final imageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (sheetContext) {
        return _AddProductSheet(
          formKey: formKey,
          titleController: titleController,
          priceController: priceController,
          descriptionController: descriptionController,
          imageController: imageController,

          onSubmit: () async {
            // --------------------------------------------------
            // Validate form
            // --------------------------------------------------

            if (!formKey.currentState!.validate()) {
              return;
            }

            final title = titleController.text.trim();

            final price = double.parse(priceController.text.trim());

            final description = descriptionController.text.trim();

            final image = imageController.text.trim();

            // --------------------------------------------------
            // Close bottom sheet
            // --------------------------------------------------

            Navigator.pop(sheetContext);

            // --------------------------------------------------
            // Call AsyncNotifier method
            // --------------------------------------------------

            try {
              await ref
                  .read(productsProvider.notifier)
                  .addProduct(
                    title: title,
                    price: price,
                    description: description,
                    image: image,
                  );

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product added successfully')),
              );
            } catch (error) {
              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to add product: $error')),
              );
            }
          },
        );
      },
    );
  }
}

void _showEditProductSheet({
  required BuildContext context,
  required WidgetRef ref,
  required Product product,
}) {
  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController(text: product.title);

  final priceController = TextEditingController(text: product.price.toString());

  final descriptionController = TextEditingController(
    text: product.description,
  );

  final imageController = TextEditingController(text: product.image);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,

    builder: (sheetContext) {
      return _EditProductSheet(
        formKey: formKey,

        titleController: titleController,
        priceController: priceController,
        descriptionController: descriptionController,
        imageController: imageController,

        onSubmit: () async {
          // --------------------------------------------------
          // Validate form
          // --------------------------------------------------

          if (!formKey.currentState!.validate()) {
            return;
          }

          final title = titleController.text.trim();

          final price = double.parse(priceController.text.trim());

          final description = descriptionController.text.trim();

          final image = imageController.text.trim();

          // --------------------------------------------------
          // Close bottom sheet
          // --------------------------------------------------

          Navigator.pop(sheetContext);

          // --------------------------------------------------
          // Call UPDATE method
          // --------------------------------------------------

          try {
            await ref
                .read(productsProvider.notifier)
                .updateProduct(
                  id: product.id,
                  title: title,
                  price: price,
                  description: description,
                  image: image,
                );

            if (!context.mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product updated successfully')),
            );
          } catch (error) {
            if (!context.mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update product: $error')),
            );
          }
        },
      );
    },
  );
}

// ============================================================
// PRODUCT CARD
// ============================================================

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // --------------------------------------------------
          // IMAGE
          // --------------------------------------------------
          ClipRRect(
            borderRadius: BorderRadius.circular(16),

            child: Container(
              width: 85,
              height: 85,

              color: const Color(0xFFF5F5F5),

              child: Image.network(
                product.image,
                fit: BoxFit.contain,

                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.grey,
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 14),

          // --------------------------------------------------
          // DETAILS
          // --------------------------------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  product.title,

                  maxLines: 2,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  product.description,

                  maxLines: 2,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '\$${product.price.toStringAsFixed(2)}',

                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    // ------------------------------------------------
                    // EDIT BUTTON
                    // ------------------------------------------------
                    IconButton(
                      tooltip: 'Edit Product',

                      onPressed: onEdit,

                      icon: const Icon(Icons.edit_outlined, size: 20),
                    ),
                    IconButton(
                      tooltip: 'Delete Product',
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _deleteProduct({
  required BuildContext context,
  required WidgetRef ref,
  required Product product,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.title}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  if (confirmed != true) return;

  try {
    await ref.read(productsProvider.notifier).deleteProduct(id: product.id);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product deleted successfully')),
    );
  } catch (error) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Failed to delete product: $error')));
  }
}

// ============================================================
// SUMMARY CARD
// ============================================================

class _SummaryCard extends StatelessWidget {
  final int count;

  const _SummaryCard({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),

        gradient: const LinearGradient(
          colors: [Color(0xFF5B5FEF), Color(0xFF7B61FF)],
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(17),
            ),

            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'Product Collection',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),

                const SizedBox(height: 4),

                Text(
                  '$count products',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
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

// ============================================================
// ADD PRODUCT SHEET
// ============================================================

class _AddProductSheet extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  final TextEditingController titleController;
  final TextEditingController priceController;
  final TextEditingController descriptionController;
  final TextEditingController imageController;

  final VoidCallback onSubmit;

  const _AddProductSheet({
    required this.formKey,
    required this.titleController,
    required this.priceController,
    required this.descriptionController,
    required this.imageController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),

      decoration: const BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),

      child: SingleChildScrollView(
        child: Form(
          key: formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ------------------------------------------------
              // HANDLE
              // ------------------------------------------------
              Center(
                child: Container(
                  width: 42,
                  height: 4,

                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'Add New Product',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
              ),

              const SizedBox(height: 6),

              const Text(
                'Enter the product details below',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),

              const SizedBox(height: 24),

              // ------------------------------------------------
              // TITLE
              // ------------------------------------------------
              TextFormField(
                controller: titleController,

                textInputAction: TextInputAction.next,

                decoration: _inputDecoration(
                  label: 'Product Title',
                  hint: 'e.g. Wireless Headphones',
                  icon: Icons.inventory_2_outlined,
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter product title';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              // ------------------------------------------------
              // PRICE
              // ------------------------------------------------
              TextFormField(
                controller: priceController,

                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),

                textInputAction: TextInputAction.next,

                decoration: _inputDecoration(
                  label: 'Price',
                  hint: 'e.g. 99.99',
                  icon: Icons.attach_money_rounded,
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter price';
                  }

                  final price = double.tryParse(value.trim());

                  if (price == null) {
                    return 'Please enter a valid price';
                  }

                  if (price <= 0) {
                    return 'Price must be greater than 0';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              // ------------------------------------------------
              // DESCRIPTION
              // ------------------------------------------------
              TextFormField(
                controller: descriptionController,

                maxLines: 3,

                textInputAction: TextInputAction.newline,

                decoration: _inputDecoration(
                  label: 'Description',
                  hint: 'Enter product description',
                  icon: Icons.description_outlined,
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter description';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              // ------------------------------------------------
              // IMAGE URL
              // ------------------------------------------------
              TextFormField(
                controller: imageController,

                keyboardType: TextInputType.url,

                textInputAction: TextInputAction.done,

                decoration: _inputDecoration(
                  label: 'Image URL',
                  hint: 'https://example.com/image.jpg',
                  icon: Icons.image_outlined,
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter image URL';
                  }

                  final uri = Uri.tryParse(value.trim());

                  if (uri == null || !uri.hasScheme) {
                    return 'Please enter a valid URL';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              // ------------------------------------------------
              // SUBMIT
              // ------------------------------------------------
              SizedBox(
                width: double.infinity,
                height: 54,

                child: FilledButton.icon(
                  onPressed: onSubmit,

                  icon: const Icon(Icons.add_rounded),

                  label: const Text(
                    'Create Product',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,

      prefixIcon: Icon(icon),

      filled: true,

      fillColor: const Color(0xFFF8F9FB),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),

        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),

        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),

        borderSide: const BorderSide(color: Color(0xFF5B5FEF), width: 1.5),
      ),
    );
  }
}

// ============================================================
// EDIT PRODUCT SHEET
// ============================================================

class _EditProductSheet extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  final TextEditingController titleController;
  final TextEditingController priceController;
  final TextEditingController descriptionController;
  final TextEditingController imageController;

  final VoidCallback onSubmit;

  const _EditProductSheet({
    required this.formKey,
    required this.titleController,
    required this.priceController,
    required this.descriptionController,
    required this.imageController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),

      decoration: const BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),

      child: SingleChildScrollView(
        child: Form(
          key: formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ------------------------------------------------
              // HANDLE
              // ------------------------------------------------
              Center(
                child: Container(
                  width: 42,
                  height: 4,

                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'Edit Product',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
              ),

              const SizedBox(height: 6),

              Text(
                'Update product #${titleController.text.isEmpty ? '' : ''}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),

              const SizedBox(height: 24),

              // ------------------------------------------------
              // TITLE
              // ------------------------------------------------
              TextFormField(
                controller: titleController,

                textInputAction: TextInputAction.next,

                decoration: _inputDecoration(
                  label: 'Product Title',
                  hint: 'e.g. Wireless Headphones',
                  icon: Icons.inventory_2_outlined,
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter product title';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              // ------------------------------------------------
              // PRICE
              // ------------------------------------------------
              TextFormField(
                controller: priceController,

                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),

                textInputAction: TextInputAction.next,

                decoration: _inputDecoration(
                  label: 'Price',
                  hint: 'e.g. 99.99',
                  icon: Icons.attach_money_rounded,
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter price';
                  }

                  final price = double.tryParse(value.trim());

                  if (price == null) {
                    return 'Please enter a valid price';
                  }

                  if (price <= 0) {
                    return 'Price must be greater than 0';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              // ------------------------------------------------
              // DESCRIPTION
              // ------------------------------------------------
              TextFormField(
                controller: descriptionController,

                maxLines: 3,

                textInputAction: TextInputAction.newline,

                decoration: _inputDecoration(
                  label: 'Description',
                  hint: 'Enter product description',
                  icon: Icons.description_outlined,
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter description';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              // ------------------------------------------------
              // IMAGE URL
              // ------------------------------------------------
              TextFormField(
                controller: imageController,

                keyboardType: TextInputType.url,

                textInputAction: TextInputAction.done,

                decoration: _inputDecoration(
                  label: 'Image URL',
                  hint: 'https://example.com/image.jpg',
                  icon: Icons.image_outlined,
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter image URL';
                  }

                  final uri = Uri.tryParse(value.trim());

                  if (uri == null || !uri.hasScheme) {
                    return 'Please enter a valid URL';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              // ------------------------------------------------
              // UPDATE BUTTON
              // ------------------------------------------------
              SizedBox(
                width: double.infinity,
                height: 54,

                child: FilledButton.icon(
                  onPressed: onSubmit,

                  icon: const Icon(Icons.check_rounded),

                  label: const Text(
                    'Update Product',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,

      prefixIcon: Icon(icon),

      filled: true,

      fillColor: const Color(0xFFF8F9FB),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF5B5FEF), width: 1.5),
      ),
    );
  }
}
// ============================================================
// EDIT PRODUCT SHEET
// ============================================================

// ============================================================
// LOADING VIEW
// ============================================================

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),

      children: [
        const SizedBox(height: 20),

        Container(
          height: 110,

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        const SizedBox(height: 20),

        ...List.generate(5, (index) {
          return Container(
            height: 115,

            margin: const EdgeInsets.only(bottom: 12),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          );
        }),
      ],
    );
  }
}

// ============================================================
// EMPTY VIEW
// ============================================================

class _EmptyView extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 90,
              height: 90,

              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.inventory_2_outlined,
                size: 42,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No Products Yet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 8),

            const Text(
              'Your product collection is empty. '
              'Add your first product to get started.',
              textAlign: TextAlign.center,

              style: TextStyle(color: Colors.grey, height: 1.5),
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: onAdd,

              icon: const Icon(Icons.add_rounded),

              label: const Text('Add First Product'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ERROR VIEW
// ============================================================

class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 80,
              height: 80,

              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons.error_outline_rounded,
                size: 42,
                color: Colors.red.shade400,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 8),

            Text(
              error.toString(),
              textAlign: TextAlign.center,

              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 22),

            FilledButton.icon(
              onPressed: onRetry,

              icon: const Icon(Icons.refresh_rounded),

              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
