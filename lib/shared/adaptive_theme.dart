import 'package:flutter/material.dart';

final ThemeData _androidTheme = ThemeData(
  primarySwatch: Colors.deepOrange,
  accentColor: Colors.deepOrangeAccent,
);

final ThemeData _iosTheme = ThemeData(
  primarySwatch: Colors.deepOrange,
  accentColor: Colors.deepOrangeAccent,
);

ThemeData getAdaptiveTheme(context) {
  return Theme.of(context).platform == TargetPlatform.android
      ? _androidTheme
      : _iosTheme;
}
