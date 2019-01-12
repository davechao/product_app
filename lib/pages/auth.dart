import 'package:flutter/material.dart';
import 'package:product_app/pages/products.dart';

class Auth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('LOGIN'),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Products(),
              ),
            );
          },
        ),
      ),
    );
  }
}
