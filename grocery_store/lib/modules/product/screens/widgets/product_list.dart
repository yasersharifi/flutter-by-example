import 'package:flutter/material.dart';
import 'package:grocery_store/modules/product/models/product_model.dart';
import 'package:grocery_store/modules/product/screens/widgets/product_card.dart';

class ProductList extends StatelessWidget {
  const ProductList({
    super.key,
    required this.isScrollable,
    required this.products,
    required this.isLoading,
    this.error,
  });

  final bool isScrollable;
  final List<Product> products;
  final bool isLoading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (_) {
        if (isLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (error != null) {
          return Center(child: Text(error!));
        } else if (products.isEmpty) {
          return Center(child: Text('Product not found.'));
        }

        return GridView.builder(
          shrinkWrap: !isScrollable,
          physics:
              isScrollable
                  ? const BouncingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            left: 17.0,
            top: 25.0,
            right: 17.0,
            bottom: 17.0,
          ),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // two columns
            crossAxisSpacing: 18, // horizontal gap
            mainAxisSpacing: 20, // vertical gap
            childAspectRatio: 0.7, // adjust based on your content
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(product: product);
          },
        );
      },
    );
  }
}
