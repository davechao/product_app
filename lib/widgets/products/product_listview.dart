import 'package:flutter/material.dart';
import 'package:product_app/models/product.dart';
import 'package:product_app/scoped_models/main_model.dart';
import 'package:product_app/widgets/products/product_card.dart';
import 'package:scoped_model/scoped_model.dart';

class ProductListView extends StatelessWidget {
  Widget _buildProductListView(List<Product> products) {
    Widget productCards;
    if (products.length > 0) {
      productCards = ListView.builder(
        itemBuilder: (BuildContext context, int index) =>
            ProductCard(products[index], index),
        itemCount: products.length,
      );
    } else {
      productCards = Center(
        child: Text('No products found, please add some'),
      );
    }
    return productCards;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return _buildProductListView(model.displayedProducts);
      },
    );
  }
}
