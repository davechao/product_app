import 'package:flutter/material.dart';
import 'package:product_app/pages/product_edit.dart';
import 'package:product_app/pages/product_list.dart';

class ProductsAdmin extends StatelessWidget {
  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('Choose'),
          ),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('All Products'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/products');
            },
          ),
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
            ProductList(),
          ],
        ),
      ),
    );
  }
}
