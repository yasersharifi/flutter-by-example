import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grocery_store/ui/page/categories_page.dart';
import 'package:grocery_store/ui/page/home_page.dart';
import 'package:grocery_store/ui/page/product_details_page.dart';

void main() => runApp(const MyApp());

/// The route configuration.
final _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) => const HomePage(),
    ),
    GoRoute(
      path: '/categories',
      builder: (context, state) => const CategoriesPage(),
    ),    GoRoute(
      path: '/product-details',
      builder: (context, state) => const ProductDetailsPage(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
    );
  }
}
