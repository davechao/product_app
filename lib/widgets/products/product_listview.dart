import 'package:flutter/material.dart';
import 'package:product_app/models/product.dart';
import 'package:product_app/scoped_models/main_model.dart';
import 'package:product_app/widgets/products/product_card.dart';
import 'package:scoped_model/scoped_model.dart';

class ProductListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        List<Product> products = model.displayedProducts;
        return ListView.builder(
          itemBuilder: (BuildContext context, int index) =>
              ProductCard(products[index]),
          itemCount: products.length,
        );
      },
    );
  }
}
