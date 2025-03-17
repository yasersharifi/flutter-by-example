import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

class HomeBannerSlider extends StatelessWidget {
  const HomeBannerSlider({super.key, required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return SizedBox.shrink();
    }

    return FlutterCarousel(
      options: FlutterCarouselOptions(
        viewportFraction: 1.0,
        height: 283.0,
        showIndicator: true,
        slideIndicator: CircularSlideIndicator(
          slideIndicatorOptions: SlideIndicatorOptions(
            alignment: Alignment.bottomLeft,
            padding: EdgeInsets.only(left: 16, bottom: 30),
            currentIndicatorColor: Colors.green,
          ),
        ),
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        floatingIndicator: true,
      ),
      items:
          images.map((imagePath) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(color: Colors.black12),
                  child: Image.asset(imagePath, width: 380.0, height: 283.0, fit: BoxFit.cover,),
                );
              },
            );
          }).toList(),
    );
  }
}
