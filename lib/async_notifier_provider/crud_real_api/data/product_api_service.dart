
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
}