import 'package:flutter/material.dart';
import 'package:product_app/pages/auth.dart';
import 'package:product_app/pages/product_detail.dart';
import 'package:product_app/pages/product_card_list.dart';
import 'package:product_app/pages/products_admin.dart';
import 'package:product_app/models/product.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  List<Product> _products = [];

  void _addProduct(Product product) {
    setState(() {
      _products.add(product);
    });
    print(_products);
  }

  void _updateProduct(int index, Product product) {
    setState(() {
      _products[index] = product;
    });
  }

  void _deleteProduct(int index) {
    setState(() {
      _products.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepOrange,
        accentColor: Colors.deepOrangeAccent,
      ),
      routes: {
        '/': (context) => Auth(),
        '/products': (context) => ProductCardList(_products),
        '/admin': (context) => ProductsAdmin(
              _addProduct,
              _updateProduct,
              _deleteProduct,
              _products,
            ),
      },
      onGenerateRoute: (RouteSettings settings) {
        final List<String> pathElements = settings.name.split('/');
        if (pathElements[0] != '') {
          return null;
        }
        if (pathElements[1] == 'product') {
          final int index = int.parse(pathElements[2]);
          return MaterialPageRoute<bool>(
            builder: (context) => ProductDetail(
                  _products[index].title,
                  _products[index].image,
                  _products[index].price,
                  _products[index].description,
                ),
          );
        }
        return null;
      },
      onUnknownRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          builder: (context) => ProductCardList(_products),
        );
      },
    );
  }
}
