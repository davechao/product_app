import 'package:flutter/material.dart';
import 'package:product_app/product_manager.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Products"),
      ),
      body: ProductManager(),
    );
  }
}
