import 'dart:math';

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

  static void handleError(context) {
    Utils.alert(context, "Error", "Commiunication Failed.");
  }

  static String lim_0_100(String input) {
    int converted = int.tryParse(input) ?? -1;
    if (converted == -1) {
      return "0";
    } else {
      converted = min(100, converted);
      converted = max(0, converted);
      return converted.toString().padLeft(3, '0');
    }
  }

  static String int_str(input, defalt) {
    int converted = int.tryParse(input) ?? -1;
    if (converted == -1) {
      return defalt;
    } else {
      return converted.toString();
    }
  }

  static void alert(BuildContext mcontext, title, msg, [Function? andthen]) {
    // set up the button

    // show the dialog
    showDialog(
      context: mcontext,
      builder: (BuildContext context) {
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
        return alert;
      },
    ).then((value) {
      if (andthen != null) {
        andthen();
      }
    });
  }
}
