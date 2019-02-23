import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:product_app/models/product.dart';
import 'package:product_app/pages/auth.dart';
import 'package:product_app/pages/product_detail.dart';
import 'package:product_app/pages/product_card_list.dart';
import 'package:product_app/pages/products_admin.dart';
import 'package:product_app/scoped_models/main_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:map_view/map_view.dart';

void main() {
  MapView.setApiKey('AIzaSyDFqHBKELFROGyjfMkXVGoQcGHB_tT3vrw');
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainModel _model = MainModel();
  bool _isAuthenticated = false;

  @override
  void initState() {
    _model.autoAuthenticate();
    _model.userSubject.listen((bool isAuthenticated) {
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.deepOrange,
          accentColor: Colors.deepOrangeAccent,
        ),
        routes: {
          '/': (context) => _isAuthenticated ? ProductCardList(_model) : Auth(),
          '/admin': (context) =>
              _isAuthenticated ? ProductsAdmin(_model) : Auth(),
        },
        onGenerateRoute: (RouteSettings settings) {
          if (!_isAuthenticated) {
            return MaterialPageRoute<bool>(
              builder: (context) => Auth(),
            );
          }
          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }
          if (pathElements[1] == 'product') {
            final String productId = pathElements[2];
            final Product product =
                _model.allProducts.firstWhere((Product product) {
              return product.id == productId;
            });
            return MaterialPageRoute<bool>(
              builder: (context) =>
                  _isAuthenticated ? ProductDetail(product) : Auth(),
            );
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            builder: (context) =>
                _isAuthenticated ? ProductCardList(_model) : Auth(),
          );
        },
      ),
    );
  }
}
