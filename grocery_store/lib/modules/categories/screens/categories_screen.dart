import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:grocery_store/modules/categories/view_model/category_view_model.dart';
import 'package:grocery_store/modules/home/screens/widgets/Home_search_bar.dart';
import 'package:grocery_store/modules/home/screens/widgets/home_categories.dart';
import 'package:grocery_store/ui/core/themes/my_theme.dart';
import 'package:provider/provider.dart';

import 'widgets/Category_box.dart';
import '../../home/screens/widgets/home_banner_slider.dart';
import '../../../ui/data/categories_data.dart';


class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final viewModel = Provider.of<CategoryViewModel>(context);


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
      body: Builder(
        builder: (_) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (viewModel.error != null) {
            return Center(child: Text(viewModel.error!));
          } else if (viewModel.categories == null) {
            return Center(child: Text('Product not found.'));
          }

          final categories = viewModel.categories;

          return  Container(
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
                  categories.map((category) {
                    return CategoryBox(category: category);
                  }).toList(),
                ),
              ],
            ),
          );
        })

    );
  }
}

