import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_practice/async_notifier_provider/crud_real_api/data/product_api_service.dart';

import '../data/product_repository.dart';
import '../models/product.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

final apiServiceProvider = Provider<ProductApiService>((ref) {
  final dio = ref.watch(dioProvider);

  return ProductApiService(dio);
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);

  return ProductRepository(apiService);
});

final productsProvider =
    AsyncNotifierProvider<ProductsNotifier, List<Product>>(
  ProductsNotifier.new,
);

class ProductsNotifier extends AsyncNotifier<List<Product>> {
  late final ProductRepository repository;

  @override
  Future<List<Product>> build() async {
    repository = ref.read(productRepositoryProvider);

    return repository.getProducts();
  }
}