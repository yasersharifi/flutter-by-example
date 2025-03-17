import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:grocery_store/modules/product/screens/widgets/product_list.dart';
import 'package:grocery_store/modules/product/view_models/featured_product_view_model.dart';
import 'package:grocery_store/modules/home/screens/widgets/Home_search_bar.dart';
import 'package:grocery_store/modules/home/screens/widgets/home_categories.dart';
import 'package:grocery_store/ui/core/themes/my_theme.dart';
import 'package:provider/provider.dart';

import 'widgets/home_banner_slider.dart';
import '../../product/view_models/product_view_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<FeaturedProductViewModel>(context);

    

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(14, 17, 17, 14),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Search bar
                HomeSearchBar(),
            
                SizedBox(height: 10),
            
                // Banner
                HomeBannerSlider(
                  images: [
                    'assets/home_banner.jpg',
                    'assets/home_banner.jpg',
                    'assets/home_banner.jpg',
                  ],
                ),
            
                SizedBox(height: 20),
            
                // Categories
                HomeCategories(),
            
                SizedBox(height: 32),
            
                // Featured Products
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Text
                        Text(
                          'Featured products',
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
                            context.pushNamed('Products');
                          },
                          child: Icon(
                            Icons.chevron_right,
                            size: 24,
                            color: MyTheme.textGray,
                          ),
                        ),
                      ],
                    ),
            
                    // Products
                    ProductList(
                      isScrollable: false,
                      products: viewModel.products,
                      isLoading: viewModel.isLoading,
                      error: viewModel.error,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
