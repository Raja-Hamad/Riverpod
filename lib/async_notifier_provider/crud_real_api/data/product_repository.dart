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
}