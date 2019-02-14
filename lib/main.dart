import 'package:flutter/material.dart';
import 'package:product_app/models/product.dart';
import 'package:product_app/pages/auth.dart';
import 'package:product_app/pages/product_detail.dart';
import 'package:product_app/pages/product_card_list.dart';
import 'package:product_app/pages/products_admin.dart';
import 'package:product_app/scoped_models/main_model.dart';
import 'package:scoped_model/scoped_model.dart';

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
  Widget _buildMaterialApp(MainModel model) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepOrange,
        accentColor: Colors.deepOrangeAccent,
      ),
      routes: {
        '/': (context) => Auth(),
        '/products': (context) => ProductCardList(model),
        '/admin': (context) => ProductsAdmin(model),
      },
      onGenerateRoute: (RouteSettings settings) {
        final List<String> pathElements = settings.name.split('/');
        if (pathElements[0] != '') {
          return null;
        }
        if (pathElements[1] == 'product') {
          final String productId = pathElements[2];
          final Product product =
              model.allProducts.firstWhere((Product product) {
            return product.id == productId;
          });
          return MaterialPageRoute<bool>(
            builder: (context) => ProductDetail(product),
          );
        }
        return null;
      },
      onUnknownRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          builder: (context) => ProductCardList(model),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final MainModel model = MainModel();
    return ScopedModel<MainModel>(
      model: model,
      child: _buildMaterialApp(model),
    );
  }
}
