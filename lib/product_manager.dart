import 'package:flutter/material.dart';
import 'package:product_app/product_listview.dart';

class ProductManager extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  ProductManager(this.products);

  @override
  Widget build(BuildContext context) {
    print('[ProductManager State] build()');
    return Column(
      children: <Widget>[
        Expanded(
          child: ProductListView(products),
        ),
      ],
    );
  }
}
