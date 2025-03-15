import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:grocery_store/ui/core/Home_search_bar.dart';
import 'package:grocery_store/ui/core/home_categories.dart';
import 'package:grocery_store/ui/core/themes/my_theme.dart';

import '../core/home_banner_slider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(14, 17, 17, 14),
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

              SizedBox(height: 32,),

              // Featured collections
              Column(
                children: [
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
                          context.go('/product-details');
                        },
                        child: Icon(
                          Icons.chevron_right,
                          size: 24,
                          color: MyTheme.textGray,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
