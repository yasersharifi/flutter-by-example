import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:grocery_store/ui/core/Home_search_bar.dart';
import 'package:grocery_store/ui/core/home_categories.dart';
import 'package:grocery_store/ui/core/themes/my_theme.dart';

import '../core/Category_box.dart';
import '../core/home_banner_slider.dart';
import '../data/categories_data.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final List<Category> _categories = Categories().categories.cast<Category>();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: MyTheme.textBlack,
          ),
        ),
        leading: InkWell(
          onTap: () => context.go('/'),
          child: Icon(
            Icons.arrow_back_sharp,
            color: MyTheme.textBlack,
            size: 24,
          ),
        ),
        actions: [Icon(Icons.settings, color: MyTheme.textBlack, size: 24)],
        actionsPadding: EdgeInsets.only(left: 17.0, right: 17.0),
      ),
      body: Container(
        width: screenSize.width,
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(14, 17, 17, 14),
        child: Column(
          children: [
            //

            // Categories
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children:
                  _categories.map((category) {
                    return CategoryBox(category: category);
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
