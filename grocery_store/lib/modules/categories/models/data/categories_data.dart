import 'package:flutter/material.dart';

class Category {
  final String title;
  final String image;
  final Color? bgColors;

  Category({
    required this.title,
    required this.image,
    this.bgColors = Colors.grey,
  });
}

class Categories {
  final List<Category> _categories = [
    Category(
      title: 'Vegetables',
      image: 'assets/categories/vegetables.svg',
      bgColors: Colors.green[50],
    ),
    Category(
      title: 'Fruits',
      image: 'assets/categories/fruits.svg',
      bgColors: Colors.red[50],
    ),
    Category(
      title: 'Beverages',
      image: 'assets/categories/beverage.svg',
      bgColors: Colors.orange[50],
    ),
    Category(
      title: 'Grocery',
      image: 'assets/categories/grocery.svg',
      bgColors: Colors.purple[50],
    ),
    Category(
      title: 'Edible oil',
      image: 'assets/categories/oil.svg',
      bgColors: Colors.blue[50],
    ),
    Category(
      title: 'Household',
      image: 'assets/categories/vacuum.svg',
      bgColors: Colors.pink[50],
    ),
    Category(
      title: 'Baby care',
      image: 'assets/categories/baby_care.svg',
      bgColors: Colors.blue[50],
    ),
  ];

  List<Category> get categories {
    return _categories;
  }
}
