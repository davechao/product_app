import 'package:flutter/material.dart';

class ProductFab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProductFabState();
  }
}

class _ProductFabState extends State<ProductFab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 70.0,
          width: 56.0,
          alignment: FractionalOffset.topCenter,
          child: FloatingActionButton(
            heroTag: 'contact',
            backgroundColor: Theme.of(context).cardColor,
            child: Icon(
              Icons.mail,
              color: Colors.cyan,
            ),
            mini: true,
            onPressed: () {},
          ),
        ),
        Container(
          height: 70.0,
          width: 56.0,
          alignment: FractionalOffset.topCenter,
          child: FloatingActionButton(
            heroTag: 'favorite',
            backgroundColor: Theme.of(context).cardColor,
            child: Icon(
              Icons.favorite,
              color: Colors.red,
            ),
            mini: true,
            onPressed: () {},
          ),
        ),
        FloatingActionButton(
          heroTag: 'options',
          child: Icon(Icons.more_vert),
          onPressed: () {},
        ),
      ],
    );
  }
}
