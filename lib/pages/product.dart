import 'package:flutter/material.dart';

class Product extends StatelessWidget {
  final String title;
  final String imageUrl;

  Product(this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(imageUrl),
          Container(
            padding: EdgeInsets.all(10.0),
            child: Text('Details'),
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            child: RaisedButton(
              color: Theme.of(context).accentColor,
              child: Text('DELETE'),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          )
        ],
      ),
    );
  }
}
