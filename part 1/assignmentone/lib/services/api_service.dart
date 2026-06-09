import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String baseUrl = "https://dummyjson.com/products";

  Future<List<Product>> fetchProducts(int limit, int skip) async {
    final response = await http.get(
      Uri.parse("$baseUrl?limit=$limit&skip=$skip"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List products = data['products'];

      return products.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load products");
    }
  }
}
