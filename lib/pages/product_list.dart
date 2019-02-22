import 'package:flutter/material.dart';
import 'package:product_app/pages/product_edit.dart';
import 'package:product_app/scoped_models/main_model.dart';
import 'package:scoped_model/scoped_model.dart';

class ProductList extends StatefulWidget {
  final MainModel model;

  ProductList(this.model);

  @override
  State<StatefulWidget> createState() {
    return _ProductListState();
  }
}

class _ProductListState extends State<ProductList> {
  Widget _buildEditButton(BuildContext context, int index, MainModel model) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        model.selectProduct(model.allProducts[index].id);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return ProductEdit();
            },
          ),
        ).then((_) {
          model.selectProduct(null);
        });
      },
    );
  }

  @override
  void initState() {
    widget.model.fetchProducts(onlyForUser: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return Dismissible(
              key: Key(model.allProducts[index].title),
              background: Container(color: Colors.red),
              direction: DismissDirection.endToStart,
              onDismissed: (DismissDirection direction) {
                if (direction == DismissDirection.endToStart) {
                  model.selectProduct(model.allProducts[index].id);
                  model.deleteProduct();
                }
              },
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        model.allProducts[index].image,
                      ),
                    ),
                    title: Text(model.allProducts[index].title),
                    subtitle:
                        Text('\$${model.allProducts[index].price.toString()}'),
                    trailing: _buildEditButton(context, index, model),
                  ),
                  Divider(),
                ],
              ),
            );
          },
          itemCount: model.allProducts.length,
        );
      },
    );
  }
}
