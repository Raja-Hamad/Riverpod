import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_practice/async_notifier_provider/crud_real_api/providers/product_providers.dart';

import '../models/product.dart';

class ProductDetailsPage extends ConsumerWidget {
  final int productId;

  const ProductDetailsPage({
    super.key,
    required this.productId,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final productAsync = ref.watch(
      productProvider(productId),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,

        title: const Text(
          'Product Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: productAsync.when(
        // ------------------------------------------------------
        // LOADING
        // ------------------------------------------------------

        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },

        // ------------------------------------------------------
        // ERROR
        // ------------------------------------------------------

        error: (
          error,
          stackTrace,
        ) {
          return _ErrorView(
            error: error,

            onRetry: () {
              ref.invalidate(
                productProvider(productId),
              );
            },
          );
        },

        // ------------------------------------------------------
        // DATA
        // ------------------------------------------------------

        data: (product) {
          return _ProductDetails(
            product: product,
          );
        },
      ),
    );
  }
}
class _ProductDetails extends StatelessWidget {
  final Product product;

  const _ProductDetails({
    required this.product,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // --------------------------------------------------
          // IMAGE
          // --------------------------------------------------

          Container(
            width: double.infinity,
            height: 300,

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(24),
            ),

            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(24),

              child: Image.network(
                product.image,

                fit: BoxFit.contain,

                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return const Icon(
                    Icons.image_not_supported_outlined,
                    size: 60,
                    color: Colors.grey,
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // --------------------------------------------------
          // TITLE
          // --------------------------------------------------

          Text(
            product.title,

            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          // --------------------------------------------------
          // PRICE
          // --------------------------------------------------

          Text(
            '\$${product.price.toStringAsFixed(2)}',

            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 24),

          // --------------------------------------------------
          // DESCRIPTION
          // --------------------------------------------------

          const Text(
            'Description',

            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            product.description,

            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.red,
            ),

            const SizedBox(height: 20),

            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              error.toString(),
              textAlign: TextAlign.center,

              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: onRetry,

              icon: const Icon(
                Icons.refresh_rounded,
              ),

              label: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}