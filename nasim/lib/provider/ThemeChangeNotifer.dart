import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nasim/Themes/LightTheme.dart';
import 'package:nasim/Themes/LightTheme.dart';

class ThemeChangeNotifer extends ChangeNotifier {
  ThemeData current = LightTheme().theme;
  bool _is_light = true;

  /// Removes all items from the cart.
  void switchtheme() {
    // if(_is_light){

    // }
    notifyListeners();
  }
}
