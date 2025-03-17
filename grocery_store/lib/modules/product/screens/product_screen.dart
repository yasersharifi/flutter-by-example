import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grocery_store/modules/product/screens/widgets/product_card.dart';
import 'package:grocery_store/modules/product/screens/widgets/product_list.dart';
import 'package:provider/provider.dart';
import '../../../../ui/core/themes/my_theme.dart';
import '../view_models/product_view_model.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ProductViewModel>(context);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            'Vegetables',
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
          actionsPadding: const EdgeInsets.symmetric(horizontal: 17.0),
        ),

        // ✅ GridView for 2-column layout
        body: ProductList(
          isScrollable: true,
          products: viewModel.products,
          isLoading: viewModel.isLoading,
          error: viewModel.error,
        )

    );
  }
}
