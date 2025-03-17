import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class FeaturedProductViewModel extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchFeaturedProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _productService.fetchFeaturedProducts();
    } catch (e) {
      _error = 'Could not load product details.';
      debugPrint('Error fetching products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

  }
}
