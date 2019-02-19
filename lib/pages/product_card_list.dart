import 'package:flutter/material.dart';
import 'package:product_app/scoped_models/main_model.dart';
import 'package:product_app/widgets/products/product_listview.dart';
import 'package:product_app/widgets/ui_elements/logout_list_tile.dart';
import 'package:scoped_model/scoped_model.dart';

class ProductCardList extends StatefulWidget {
  final MainModel model;

  ProductCardList(this.model);

  @override
  State<StatefulWidget> createState() {
    return _ProductCardListState();
  }
}

class _ProductCardListState extends State<ProductCardList> {
  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('Choose'),
          ),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Manage Products'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/admin');
            },
          ),
          Divider(),
          LogoutListTile(),
        ],
      ),
    );
  }

  Widget _buildFavoriteIconButton() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return IconButton(
          icon: Icon(model.displayFavoritesOnly
              ? Icons.favorite
              : Icons.favorite_border),
          onPressed: () {
            model.toggleDisplayMode();
          },
        );
      },
    );
  }

  Widget _buildProductListView() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        Widget content = Center(child: Text('No Products Found!'));
        if (model.displayedProducts.length > 0 && !model.isLoading) {
          content = ProductListView();
        } else if (model.isLoading) {
          content = Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          child: content,
          onRefresh: model.fetchProducts,
        );
      },
    );
  }

  @override
  void initState() {
    widget.model.fetchProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildSideDrawer(context),
      appBar: AppBar(
        title: Text("Products"),
        actions: <Widget>[
          _buildFavoriteIconButton(),
        ],
      ),
      body: _buildProductListView(),
    );
  }
}
