import 'dart:convert';

import 'package:grocery_store/modules/categories/models/category_model.dart';
import 'package:http/http.dart' as http;

import '../../../ui/data/categories_data.dart';


class CategoryService {
  final String baseUrl = 'https://fakestoreapi.com';

  Future<List<CategoryModel>> fetchCategories() async {
    await Future.delayed(Duration(seconds: 8));
    // In future replace by categories api
    // final response = await http.get(Uri.parse('$baseUrl/products'));
    // final List data = jsonDecode(response.body);
    // return data.map((json) => CategoryModel.fromJson(json)).toList();
    final response = Categories().categories;
    final List data = jsonDecode(response.toString());
    return data.map((json) => CategoryModel.fromJson(json)).toList();
  }

}
