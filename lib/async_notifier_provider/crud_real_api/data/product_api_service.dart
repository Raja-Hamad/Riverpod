
import 'package:dio/dio.dart';

class ProductApiService {
  final Dio dio;

  ProductApiService(this.dio);

  Future<List<dynamic>> getProducts() async {
    final response = await dio.get(
      'https://fakestoreapi.com/products',
    );

    return response.data;
  }
    Future<Map<String, dynamic>> createProduct({
    required String title,
    required double price,
    required String description,
    required String image,
  }) async {
    final response = await dio.post(
      'https://fakestoreapi.com/products',
      data: {
        'title': title,
        'price': price,
        'description': description,
        'image': image,
        'category': 'general',
      },
    );

    return response.data;
  }
  Future<Map<String, dynamic>> updateProduct({
  required int id,
  required String title,
  required double price,
  required String description,
  required String image,
}) async {
  final response = await dio.put(
    'https://fakestoreapi.com/products/$id',
    data: {
      'title': title,
      'price': price,
      'description': description,
      'image': image,
      'category': 'general',
    },
  );

  return response.data;
}
Future<void> deleteProduct({
  required int id,
}) async {
  await dio.delete(
    'https://fakestoreapi.com/products/$id',
  );
}
}