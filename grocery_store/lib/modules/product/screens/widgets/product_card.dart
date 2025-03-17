import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grocery_store/modules/product/models/product_model.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, this.onAddToCart});

  final Product product;
  final VoidCallback? onAddToCart;

  void _navigateToDetails(BuildContext context) {
    context.pushNamed('ProductDetails', pathParameters: {'id': product.id.toString()});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              // Product Image
              Center(
                child: _ProductImage( imageUrl: product.image,),
              ),

              const SizedBox(height: 18),

              // Product Price
              Center(
                child: _ProductPrice(price: product.price),
              ),

              const SizedBox(height: 4),

              // Product title
              GestureDetector(
                onTap: () => _navigateToDetails(context),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                  ),
                  child: _ProductTitle(title: product.title),
                ),
              ),
            ],
          ),

          Column(
            children: [
              Container(color: Color(0xFFEBEBEB), height: 1),

              InkWell(
                onTap: onAddToCart,
                child: SizedBox(
                  height: 40,
                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart,
                        color: Colors.green,
                        size: 16,
                      ),

                      SizedBox(width: 9),

                      Text(
                        'Add to cart',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Product Image
class _ProductImage extends StatelessWidget {
  const _ProductImage({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 91,
      height: 113,
      child: Stack(
        children: [
          // 🟩 Background box with top: 21
          Positioned(
            top: 21,
            left: 0,
            right: 0,
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: Colors.lightGreen.shade100,
                borderRadius: BorderRadius.circular(
                  42,
                ),
              ),
            ),
          ),

          // 🖼️ Image with top: 43
          Positioned(
            top: 43,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                8,
              ),
              child: Image.network(
                imageUrl,
                // fit: BoxFit.cover,
                width: 91,
                height: 72,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


/// Product Title
class _ProductTitle extends StatelessWidget {
  const _ProductTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
    );
  }
}

/// Product Price
class _ProductPrice extends StatelessWidget {
  const _ProductPrice({super.key, required this.price});

  final double price;

  @override
  Widget build(BuildContext context) {
    return Text(
      '\$${price.toStringAsFixed(2)}',
      style: const TextStyle(
        color: Colors.green,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}



