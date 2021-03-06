import 'package:flutter/material.dart';
import 'package:product_app/pages/product_edit.dart';
import 'package:product_app/pages/product_list.dart';
import 'package:product_app/scoped_models/main_model.dart';
import 'package:product_app/widgets/ui_elements/logout_list_tile.dart';

class ProductsAdmin extends StatelessWidget {
  final MainModel model;

  ProductsAdmin(this.model);

  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('Choose'),
            elevation:
                Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
          ),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('All Products'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          Divider(),
          LogoutListTile(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: _buildSideDrawer(context),
        appBar: AppBar(
          title: Text("Manage Products"),
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
          bottom: TabBar(tabs: <Widget>[
            Tab(
              icon: Icon(Icons.create),
              text: 'Create Product',
            ),
            Tab(
              icon: Icon(Icons.list),
              text: 'My Products',
            ),
          ]),
        ),
        body: TabBarView(
          children: <Widget>[
            ProductEdit(),
            ProductList(model),
          ],
        ),
      ),
    );
  }
}
