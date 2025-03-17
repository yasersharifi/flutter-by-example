import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:grocery_store/modules/product/view_models/product_details_view_model.dart';
import 'package:provider/provider.dart';

import '../../../../ui/core/themes/my_theme.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key, required String productId});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final viewModel = Provider.of<ProductDetailsViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: InkWell(
          onTap: () => context.go('/'),
          child: Icon(
            Icons.arrow_back_sharp,
            color: MyTheme.textBlack,
            size: 24,
          ),
        ),
      ),
      body: Builder(
        builder: (_) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (viewModel.error != null) {
            return Center(child: Text(viewModel.error!));
          } else if (viewModel.product == null) {
            return Center(child: Text('Product not found.'));
          }

          final product = viewModel.product;

          return Container(
            width: screenSize.width,
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Image
                  Center(
                    child: SizedBox(
                      height: 324,
                      child: Image.network(
                        product.image,
                        height: 324,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  SizedBox(height: 33),

                  Container(
                    padding: EdgeInsets.fromLTRB(17, 26, 17, 26),
                    decoration: BoxDecoration(
                      color: Color(0xFFF4F5F9),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(children: [
                          // Price And Heart
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '\$${product.price}',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              Icon(
                                Icons.favorite_border,
                                color: MyTheme.textGray,
                                size: 24,
                              ),
                            ],
                          ),

                          // Title
                          Text(
                            product.title,
                            style: TextStyle(
                              color: MyTheme.textBlack,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                            // textAlign: TextAlign.start,
                          ),

                          // category
                          Text(
                            product.category,
                            style: TextStyle(
                              color: MyTheme.textGray,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            // textAlign: TextAlign.left,
                          ),
                          SizedBox(height: 9),

                          // Rating
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                product.rating.rate.toString(),
                                style: TextStyle(
                                  color: MyTheme.textBlack,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.start,
                              ),

                              RatingBar.builder(
                                initialRating: 3,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemSize: 20,
                                itemPadding: EdgeInsets.symmetric(
                                  horizontal: 0.0,
                                ),
                                itemBuilder:
                                    (context, _) => Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                ),

                                onRatingUpdate: (rating) {
                                  print(rating);
                                },
                              ),

                              Text(
                                '(${product.rating.count} reviews)',
                                style: TextStyle(
                                  color: MyTheme.textGray,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),

                          SizedBox(height: 16),
                          // Description
                          Text(
                            product.description,
                            style: TextStyle(
                              color: MyTheme.textGray,
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                            textAlign: TextAlign.start,
                          ),
                          SizedBox(height: 8),
                        ],),


                        Column(
                          children: [
                            // Quantity
                            Container(
                              padding: EdgeInsets.only(left:17.0 ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: SizedBox(
                                height: 50,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Quantity Text
                                    Text(
                                      'Quantity',
                                      style: TextStyle(
                                        color: MyTheme.textGray,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),

                                    // Quantity
                                    Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,

                                      children: [
                                        SizedBox(
                                          height: 50,
                                          width: 50,
                                          child: Icon(
                                            Icons.remove,
                                            size: 24,
                                            color: Colors.green,
                                          ),
                                        ),
                                        // Vertical line
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          height: 50,
                                          width: 1,
                                          color: Color(
                                            0xFFEBEBEB,
                                          ), // Line color
                                        ),

                                        SizedBox(
                                          height: 50,
                                          width: 50,
                                          child: Center(
                                            child: Text(
                                              '3',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 18,
                                                color: MyTheme.textBlack,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Vertical line
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          height: 50,
                                          width: 1,
                                          color: Color(
                                            0xFFEBEBEB,
                                          ), // Line color
                                        ),
                                        SizedBox(
                                          height: 50,
                                          width: 50,
                                          child: Icon(
                                            Icons.add,
                                            size: 24,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Add to cart Button
                            Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: SizedBox(
                                width: double.infinity, // 100% width
                                height: 60, // Fixed height
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // handle press
                                  },
                                  icon: const Icon(
                                    Icons.shopping_bag_outlined, // 👈 your prefix icon here
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Add to cart',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )


                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
