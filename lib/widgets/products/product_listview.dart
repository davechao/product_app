import 'package:flutter/material.dart';
import 'package:product_app/widgets/products/product_card.dart';

class ProductListView extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  ProductListView(this.products) {
    print('[Products Widget] Constructor');
  }

  Widget _buildProductListView() {
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
    print('[Products Widget] build');
    return _buildProductListView();
  }
}
