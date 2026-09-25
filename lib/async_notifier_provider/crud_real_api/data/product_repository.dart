import 'package:riverpod_practice/async_notifier_provider/crud_real_api/data/product_api_service.dart';

import '../models/product.dart';

class ProductRepository {
  final ProductApiService productApiService;

  ProductRepository(this.productApiService);

  Future<List<Product>> getProducts() async {
    final data = await productApiService.getProducts();

    return data
        .map(
          (json) => Product.fromJson(json),
        )
        .toList();
  }
    Future<Product> createProduct({
    required String title,
    required double price,
    required String description,
    required String image,
  }) async {
    final data = await productApiService.createProduct(
      title: title,
      price: price,
      description: description,
      image: image,
    );

    return Product.fromJson(data);
  }
}