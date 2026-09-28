import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_practice/async_notifier_provider/crud_real_api/data/product_api_service.dart';

import '../data/product_repository.dart';
import '../models/product.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ),
  );
});

final apiServiceProvider = Provider<ProductApiService>((ref) {
  final dio = ref.watch(dioProvider);

  return ProductApiService(dio);
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);

  return ProductRepository(apiService);
});

final productsProvider = AsyncNotifierProvider<ProductsNotifier, List<Product>>(
  ProductsNotifier.new,
);

// provider for a single product by ID
final productProvider =
    AsyncNotifierProvider.autoDispose.family<ProductNotifier, Product, int>(
      ProductNotifier.new,
    );

class ProductNotifier extends AsyncNotifier<Product> {
  ProductNotifier(this.productId);

  final int productId;

  @override
  Future<Product> build() async {
    final product = await ref
        .read(productRepositoryProvider)
        .getProductById(productId);

    return product;
  }
}

class ProductsNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    final repository = ref.read(productRepositoryProvider);

    return repository.getProducts();
  }

  Future<void> addProduct({
    required String title,
    required double price,
    required String description,
    required String image,
  }) async {
    final currentProducts = state.value ?? [];

    try {
      state = const AsyncLoading<List<Product>>();

      final repository = ref.read(productRepositoryProvider);

      final newProduct = await repository.createProduct(
        title: title,
        price: price,
        description: description,
        image: image,
      );

      state = AsyncData([...currentProducts, newProduct]);
    } catch (error, stackTrace) {
      state = AsyncError<List<Product>>(error, stackTrace);
    }
  }

  Future<void> updateProduct({
    required int id,
    required String title,
    required double price,
    required String description,
    required String image,
  }) async {
    final currentProducts = state.value ?? [];

    try {
      state = const AsyncLoading<List<Product>>();

      final repository = ref.read(productRepositoryProvider);

      final updatedProduct = await repository.updateProduct(
        id: id,
        title: title,
        price: price,
        description: description,
        image: image,
      );

      final updatedProducts = currentProducts.map((product) {
        if (product.id == id) {
          return updatedProduct;
        }

        return product;
      }).toList();

      state = AsyncData(updatedProducts);
    } catch (error, stackTrace) {
      state = AsyncError<List<Product>>(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteProduct({required int id}) async {
    final currentProducts = state.value ?? [];

    try {
      state = const AsyncLoading<List<Product>>();

      final repository = ref.read(productRepositoryProvider);

      await repository.deleteProduct(id: id);

      final updatedProducts = currentProducts
          .where((product) => product.id != id)
          .toList();

      state = AsyncData(updatedProducts);
    } catch (error, stackTrace) {
      state = AsyncError<List<Product>>(error, stackTrace);
      rethrow;
    }
  }
}