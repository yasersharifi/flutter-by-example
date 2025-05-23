import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:grocery_store/ui/core/themes/my_theme.dart';
import 'package:grocery_store/ui/data/categories_data.dart';
import 'package:provider/provider.dart';

import '../../../categories/screens/widgets/Category_box.dart';
import '../../../categories/view_model/category_view_model.dart';

class HomeCategories extends StatefulWidget {
  const HomeCategories({super.key});

  @override
  State<HomeCategories> createState() => _HomeCategoriesState();
}

class _HomeCategoriesState extends State<HomeCategories> {

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final viewModel = Provider.of<CategoryViewModel>(context);

    if (viewModel.isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (viewModel.error != null) {
      return Container(); // Not show anything
    } else if (viewModel.categories == null) {
      return Container(); // Not show anything
    }

    final categories = viewModel.categories;

    return Column(
      children: [
        // Title and Arrow Icon
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Text
            Text(
              'Categories',
              style: TextStyle(
                color: MyTheme.textBlack,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),

            // Arrow
            InkWell(
              onTap: () {
                context.go('/categories');
              },
              child: Icon(
                Icons.chevron_right,
                size: 24,
                color: MyTheme.textGray,
              ),
            ),
          ],
        ),

        SizedBox(height: 17),

        // Categories box
        FlutterCarousel(
          options: FlutterCarouselOptions(
            height: 78.0,
            // aspectRatio: 58 / 78,
            viewportFraction: 77 / screenSize.width,
            // 58 + 19 (spacing between pages)
            padEnds: false,
            initialPage: 0,
            autoPlay: false,
            showIndicator: false,
            pageSnapping: true,
          ),
          items:
              categories.map((category) {
                return Builder(
                  builder: (BuildContext context) {
                    return CategoryBox(
                      category: category,
                      width: 54.0,
                      height: 78.0,
                      imageContainerSize: 52.0,
                      imageSize: 26.0,
                    );
                  },
                );
              }).toList(),
        ),
      ],
    );
  }
}
