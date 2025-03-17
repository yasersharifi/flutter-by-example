import 'package:go_router/go_router.dart';
import 'package:grocery_store/modules/categories/screens/categories_screen.dart';
import 'package:grocery_store/modules/categories/view_model/category_view_model.dart';
import 'package:provider/provider.dart';

import 'modules/home/screens/home_screen.dart';
import 'modules/product/screens/product_details_screen.dart';
import 'modules/product/screens/product_screen.dart';
import 'modules/product/view_models/featured_product_view_model.dart';
import 'modules/product/view_models/product_details_view_model.dart';
import 'modules/product/view_models/product_view_model.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'Home',
      builder: (context, state) => MultiProvider(providers: [
        ChangeNotifierProvider(create: (_) => CategoryViewModel()..fetchCategories()),
        ChangeNotifierProvider(create: (_) => FeaturedProductViewModel()..fetchFeaturedProducts()),
      ], child: const HomeScreen(),)
    ),
    GoRoute(
      path: '/categories',
      name: 'Categories',
      builder:
          (context, state) => ChangeNotifierProvider(
            create: (_) => CategoryViewModel()..fetchCategories(),
            child: const CategoriesScreen(),
          ),
    ),
    GoRoute(
      path: '/products',
      name: 'Products',
      builder:
          (context, state) => ChangeNotifierProvider(
            create: (_) => ProductViewModel()..fetchProducts(),
            child: const ProductScreen(),
          ),
    ),
    GoRoute(
      path: '/products/:id',
      name: 'ProductDetails',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ChangeNotifierProvider(
          create: (_) => ProductDetailsViewModel()..fetchProductById((id)),
          child: ProductDetailsScreen(productId: id),
        );
      },
    ),
  ],
);
