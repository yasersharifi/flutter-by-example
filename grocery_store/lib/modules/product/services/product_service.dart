import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class ProductService {
  final String baseUrl = 'https://fakestoreapi.com';

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    final List data = jsonDecode(response.body);
    return data.map((json) => Product.fromJson(json)).toList();
  }

  Future<List<Product>> fetchFeaturedProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    final List data = jsonDecode(response.body);
    return data.map((json) => Product.fromJson(json)).take(8).toList();
  }

  Future<Product> fetchProductById(String productId) async {
    final response = await http.get(Uri.parse('$baseUrl/products/$productId'));
    final data = jsonDecode(response.body);
    return Product.fromJson(data);
  }
}
