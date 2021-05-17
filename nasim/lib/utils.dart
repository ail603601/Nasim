import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  static String lim_0_20(String input) {
    int converted = int.tryParse(input) ?? -1;
    if (converted == -1) {
      return "00";
    } else {
      converted = min(20, converted);
      converted = max(0, converted);
      return converted.toString().padLeft(2, '0');
    }
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

  static String lim_0_9999(String input) {
    int converted = int.tryParse(input) ?? -1;
    if (converted == -1) {
      return "0";
    } else {
      converted = min(9999, converted);
      converted = max(0, converted);
      return converted.toString().padLeft(4, '0');
    }
  }

  static String sign_int_999(String input) {
    int converted = int.tryParse(input) ?? -1;
    if (converted == -1) {
      return "+000";
    } else {
      converted = min(999, converted);
      converted = max(-999, converted);
      String raw = converted.toString().padLeft(3, '0');
      String sign = converted < 0 ? "-" : "+";
      return "$sign$raw";
    }
  }

  static String sign_int_100(String input) {
    int converted = int.tryParse(input) ?? -1;
    if (converted == -1) {
      return "+000";
    } else {
      converted = min(100, converted);
      converted = max(-100, converted);
      String raw = converted.toString().padLeft(3, '0');
      String sign = converted < 0 ? "-" : "+";
      return "$sign$raw";
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

  static Future<void> alert(BuildContext mcontext, title, msg, [Function? andthen]) async {
    // set up the button

    // show the dialog
    await showDialog(
      context: mcontext,
      builder: (BuildContext context) {
        Widget okButton = FlatButton(
          child: Text("OK", style: Theme.of(context).textTheme.bodyText1!),
          onPressed: () {
            Navigator.of(context).pop();
          },
        );

        // set up the AlertDialog
        AlertDialog alert = AlertDialog(
          title: Text(title, style: Theme.of(context).textTheme.bodyText1!),
          content: Text(msg, style: Theme.of(context).textTheme.bodyText1!),
          actions: [
            okButton,
          ],
        );
        return alert;
      },
    );
    if (andthen != null) {
      andthen();
    }
  }

  static Future<String> ask_serial(String title, context) async {
    String return_value = "";
    Widget buildTextField(BuildContext context) => TextField(
          style: Theme.of(context).textTheme.bodyText1!,
          // controller: controller,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            return_value = value;
          },

          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.enterSerialNumber,
            hintStyle: Theme.of(context).textTheme.bodyText1!,
          ),
        );

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) => Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Text(title, style: Theme.of(context).textTheme.bodyText1!),
              ),
              ListTile(
                  leading: Icon(Icons.qr_code),
                  title: Text(AppLocalizations.of(context)!.scanQrCode, style: Theme.of(context).textTheme.bodyText1!),
                  onTap: () async {
                    return_value = (await Navigator.pushNamed(context, "/scan_barcode")).toString();
                    Navigator.pop(context);
                  }),
              Divider(
                color: Theme.of(context).accentColor,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 60),
                child: Row(
                  children: [
                    Expanded(child: buildTextField(context)),
                    const SizedBox(width: 12),
                    FloatingActionButton(
                      backgroundColor: Theme.of(context).primaryColor,
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.done, size: 30),
                      // onPressed: () => setState(() {}),
                    )
                  ],
                ),
              ),
            ]));

    return return_value;
  }
}
