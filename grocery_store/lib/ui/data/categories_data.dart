import 'package:flutter/material.dart';

class Category {
  final String label;
  final String imagePath;
  final Color? bgColors;

  Category({
    required this.label,
    required this.imagePath,
    this.bgColors = Colors.grey,
  });
}

class Categories {
  final List<Category> _categories = [
    Category(
      label: 'Vegetables',
      imagePath: 'assets/categories/vegetables.svg',
      bgColors: Colors.green[50],
    ),
    Category(
      label: 'Fruits',
      imagePath: 'assets/categories/fruits.svg',
      bgColors: Colors.red[50],
    ),
    Category(
      label: 'Beverages',
      imagePath: 'assets/categories/beverage.svg',
      bgColors: Colors.orange[50],
    ),
    Category(
      label: 'Grocery',
      imagePath: 'assets/categories/grocery.svg',
      bgColors: Colors.purple[50],
    ),
    Category(
      label: 'Edible oil',
      imagePath: 'assets/categories/oil.svg',
      bgColors: Colors.blue[50],
    ),
    Category(
      label: 'Household',
      imagePath: 'assets/categories/vacuum.svg',
      bgColors: Colors.pink[50],
    ),
    Category(
      label: 'Baby care',
      imagePath: 'assets/categories/baby_care.svg',
      bgColors: Colors.blue[50],
    ),
  ];

  List<Category> get categories {
    return _categories;
  }
}
