import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:product_app/models/product.dart';
import 'package:product_app/pages/auth.dart';
import 'package:product_app/pages/product_detail.dart';
import 'package:product_app/pages/product_card_list.dart';
import 'package:product_app/pages/products_admin.dart';
import 'package:product_app/scoped_models/main_model.dart';
import 'package:product_app/shared/adaptive_theme.dart';
import 'package:product_app/shared/global_config.dart';
import 'package:product_app/widgets/helpers/custom_route.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:map_view/map_view.dart';

void main() {
  MapView.setApiKey(apiKey);
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
  final _platformChannel = MethodChannel('flutter-product/battery');
  bool _isAuthenticated = false;

  Future<Null> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await _platformChannel.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level is $result %.';
    } catch (error) {
      batteryLevel = 'Failed to get battery level.';
    }
    print(batteryLevel);
  }

  @override
  void initState() {
    _model.autoAuthenticate();
    _model.userSubject.listen((bool isAuthenticated) {
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
    });
    _getBatteryLevel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        title: 'ProductApp',
        debugShowCheckedModeBanner: false,
        theme: getAdaptiveTheme(context),
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
            return CustomRoute<bool>(
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
