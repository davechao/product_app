import 'package:flutter/material.dart';
import 'package:product_app/models/product.dart';
import 'package:product_app/scoped_models/main_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:math' as math;

class ProductFab extends StatefulWidget {
  final Product product;

  ProductFab(this.product);

  @override
  State<StatefulWidget> createState() {
    return _ProductFabState();
  }
}

class _ProductFabState extends State<ProductFab> with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 70.0,
              width: 56.0,
              alignment: FractionalOffset.topCenter,
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: _controller,
                  curve: Interval(0.0, 1.0, curve: Curves.easeOut),
                ),
                child: FloatingActionButton(
                  heroTag: 'contact',
                  backgroundColor: Theme.of(context).cardColor,
                  child: Icon(
                    Icons.mail,
                    color: Colors.cyan,
                  ),
                  mini: true,
                  onPressed: () async {
                    final url = 'mailto:${widget.product.userEmail}';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                ),
              ),
            ),
            Container(
              height: 70.0,
              width: 56.0,
              alignment: FractionalOffset.topCenter,
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: _controller,
                  curve: Interval(0.0, 0.5, curve: Curves.easeOut),
                ),
                child: FloatingActionButton(
                  heroTag: 'favorite',
                  backgroundColor: Theme.of(context).cardColor,
                  child: Icon(
                    model.selectedProduct.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  mini: true,
                  onPressed: () => model.toggleProductFavoriteStatus(),
                ),
              ),
            ),
            FloatingActionButton(
              heroTag: 'options',
              child: AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget child) {
                  return Transform(
                    alignment: FractionalOffset.center,
                    transform: Matrix4.rotationZ(
                      _controller.value * 0.5 * math.pi,
                    ),
                    child: Icon(_controller.isDismissed
                        ? Icons.more_vert
                        : Icons.close),
                  );
                },
              ),
              onPressed: () {
                if (_controller.isDismissed) {
                  _controller.forward();
                } else {
                  _controller.reverse();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
