import 'package:flutter/material.dart';
import 'package:grocery_store/modules/categories/models/category_model.dart';
import '../services/category_service.dart';

class CategoryViewModel extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _categoryService.fetchCategories();
    } catch (e) {
      _error = 'Could not load categories.';
      debugPrint('Error fetching categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

  }
}
