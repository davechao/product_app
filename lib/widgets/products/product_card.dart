import 'package:flutter/material.dart';
import 'package:product_app/models/product.dart';
import 'package:product_app/scoped_models/main_model.dart';
import 'package:product_app/widgets/products/address_tag.dart';
import 'package:product_app/widgets/products/price_tag.dart';
import 'package:product_app/widgets/ui_elements/title_default.dart';
import 'package:scoped_model/scoped_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  ProductCard(this.product);

  Widget _buildTitlePriceRow() {
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(child: TitleDefault(product.title)),
          Flexible(child: SizedBox(width: 8.0)),
          Flexible(child: PriceTag(product.price.toString())),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ButtonBar(
        alignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.info),
            color: Colors.blue,
            onPressed: () {
              model.selectProduct(product.id);
              Navigator.pushNamed<bool>(
                context,
                '/product/' + product.id,
              ).then((_) => model.selectProduct(null));
            },
          ),
          IconButton(
            icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border),
            color: Colors.red,
            onPressed: () {
              model.toggleProductFavoriteStatus(product);
            },
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Hero(
            tag: product.id,
            child: FadeInImage(
              image: NetworkImage(product.image),
              height: 300.0,
              fit: BoxFit.cover,
              placeholder: AssetImage('assets/food.jpg'),
            ),
          ),
          _buildTitlePriceRow(),
          SizedBox(height: 10.0),
          AddressTag(product.location.address),
          _buildActionButtons(context)
        ],
      ),
    );
  }
}
