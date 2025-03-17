import 'package:flutter/cupertino.dart';
import 'package:grocery_store/modules/product/services/product_service.dart';

import '../models/product_model.dart';

class ProductDetailsViewModel extends ChangeNotifier {
  final ProductService _productService = ProductService();

  late Product _product;
  bool _isLoading = false;
  String? _error;

  Product get product => _product;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProductById(String productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _product = await _productService.fetchProductById(productId);
    } catch (e) {
      _error = 'Could not found product by id ${productId}';
      debugPrint('Error fetching product by id ${productId}: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }


  }
}
