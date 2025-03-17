import 'dart:ui';

class CategoryModel {
  final int id;
  final String title;
  final String image;
  final Color bgColors;

  CategoryModel({
    required this.id,
    required this.title,
    required this.image,
    required this.bgColors,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      bgColors: json['bgColor'],
    );
  }
}

