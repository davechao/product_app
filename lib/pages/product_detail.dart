import 'package:flutter/material.dart';
import 'package:product_app/models/product.dart';
import 'package:product_app/scoped_models/main_model.dart';
import 'package:product_app/widgets/ui_elements/title_default.dart';
import 'package:scoped_model/scoped_model.dart';

class ProductDetail extends StatelessWidget {
  final int productIndex;

  ProductDetail(this.productIndex);

  Widget _buildAddressPriceRow(double price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Union Square, Sun Francisco',
          style: TextStyle(
            fontFamily: 'Oswald',
            color: Colors.grey,
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          child: Text(
            '|',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        Text(
          '\$${price.toString()}',
          style: TextStyle(
            fontFamily: 'Oswald',
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildPageContent(Product product) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(product.image),
          Container(
            padding: EdgeInsets.all(10.0),
            child: TitleDefault(product.title),
          ),
          _buildAddressPriceRow(product.price),
          Container(
            padding: EdgeInsets.all(10.0),
            child: Text(
              product.description,
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        print('Back button pressed!');
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
          final Product product = model.products[productIndex];
          return _buildPageContent(product);
        },
      ),
    );
  }
}
