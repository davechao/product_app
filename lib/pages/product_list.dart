import 'package:flutter/material.dart';
import 'package:product_app/pages/product_edit.dart';

class ProductList extends StatelessWidget {
  final Function updateProduct;
  final List<Map<String, dynamic>> products;

  ProductList(this.products, this.updateProduct);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: <Widget>[
            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(
                  products[index]['image'],
                ),
              ),
              title: Text(products[index]['title']),
              subtitle: Text('\$${products[index]['price'].toString()}'),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return ProductEdit(
                          product: products[index],
                          updateProduct: updateProduct,
                          productIndex: index,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Divider(),
          ],
        );
      },
      itemCount: products.length,
    );
  }
}
