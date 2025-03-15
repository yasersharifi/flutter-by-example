import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';

import '../core/themes/my_theme.dart';

const description = '''
Organic Mountain works as a seller for many organic growers of organic lemons. Organic lemons are easy to spot in your produce aisle. They are just like regular lemons, but they will usually have a few more scars on the outside of the lemon skin. Organic lemons are considered to be the world's finest lemon for juicing
''';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

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
      body: Container(
        width: screenSize.width,
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(14, 17, 17, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Center(child: Image.asset('assets/products/p1.png')),

            SizedBox(height: 33),

            // Price And Heart
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '\$2.22',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                Icon(Icons.favorite_border, color: MyTheme.textGray, size: 24),
              ],
            ),

            // Title
            Text(
              'Organic Lemons',
              style: TextStyle(
                color: MyTheme.textBlack,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.start,
            ),
            // 1.50 Ibs
            Text(
              '1.50 lbs',
              style: TextStyle(
                color: MyTheme.textGray,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 9),

            // Rating
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '4.5',
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
                  itemPadding: EdgeInsets.symmetric(horizontal: 0.0),
                  itemBuilder:
                      (context, _) =>
                          Icon(Icons.star_rounded, color: Colors.amber),

                  onRatingUpdate: (rating) {
                    print(rating);
                  },
                ),

                Text(
                  '(89 reviews)',
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
              description,
              style: TextStyle(
                color: MyTheme.textGray,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 8),

            // Quantity
            SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    crossAxisAlignment: CrossAxisAlignment.center,

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
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        height: 50,
                        width: 1,
                        color: Color(0xFFEBEBEB), // Line color
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
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        height: 50,
                        width: 1,
                        color: Color(0xFFEBEBEB), // Line color
                      ),
                      SizedBox(
                        height: 50,
                        width: 50,
                        child: Icon(Icons.add, size: 24, color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 13),
            // Button
            SizedBox(
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
          ],
        ),
      ),
    );
  }
}
