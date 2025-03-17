import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery_store/modules/categories/models/category_model.dart';
import 'package:grocery_store/ui/core/themes/my_theme.dart';

import '../../../../ui/data/categories_data.dart';

class CategoryBox extends StatelessWidget {
  const CategoryBox({
    super.key,
    required this.category,
    this.width = 120,
    this.height=120,
    this.imageContainerSize = 120,
    this.imageSize = 66,
  });

  final CategoryModel category;
  final double width;
  final double height;
  final double imageContainerSize;
  final double imageSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          // Logo
          Container(
            width: imageContainerSize,
            height: imageContainerSize,
            decoration: BoxDecoration(
              color: category.bgColors,
              borderRadius: BorderRadius.circular(imageContainerSize / 2),
            ),
            child: Center(
              child: SizedBox(
                height: imageSize,
                child: SvgPicture.asset(
                  category.image,
                  semanticsLabel: '${category.title} Logo',
                ),
              ),
            ),
          ),

          SizedBox(height: 11.0),

          // Label
          Text(
            category.title,
            style: TextStyle(
              fontSize: 10,
              color: MyTheme.textGray,
              fontWeight: FontWeight.normal,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
