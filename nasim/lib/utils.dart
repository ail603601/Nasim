import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Utils {
  static void showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void setTimeOut(int duration, Function() function) {
    Future<void>.delayed(new Duration(seconds: duration), function);
  }
}
