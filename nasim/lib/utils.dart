import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Utils {
  static void showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void setTimeOut(int duration, Function() function) {
    Future<void>.delayed(new Duration(milliseconds: duration), function);
  }

  static Future<void> waitMsec(int duration) {
    return Future<void>.delayed(new Duration(milliseconds: duration), () => {});
  }

  static void alert(BuildContext context, title, msg) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK", style: Theme.of(context).textTheme.headline6!),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title, style: Theme.of(context).textTheme.headline6!),
      content: Text(msg, style: Theme.of(context).textTheme.bodyText2!),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
