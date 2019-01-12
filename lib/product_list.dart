import 'package:flutter/material.dart';
import 'package:product_app/pages/product.dart';

class ProductList extends StatelessWidget {
  final List<Map<String, String>> products;
  final Function deleteProduct;

  ProductList(this.products, this.deleteProduct) {
    print('[Products Widget] Constructor');
  }

  Widget _buildProductItem(context, index) {
    return Card(
      child: Column(
        children: <Widget>[
          Image.asset(products[index]['image']),
          Text(products[index]['title']),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                child: Text('Details'),
                onPressed: () {
                  Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Product(
                          products[index]['title'], products[index]['image']),
                    ),
                  ).then((bool value) {
                    if (value) {
                      deleteProduct(index);
                    }
                  });
                },
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildProductList() {
    Widget productCards;
    if (products.length > 0) {
      productCards = ListView.builder(
        itemBuilder: _buildProductItem,
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
    return _buildProductList();
  }
}
