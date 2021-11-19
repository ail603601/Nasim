import 'dart:async';
import 'dart:developer';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Utils {
  static void showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message), duration: const Duration(milliseconds: 1500));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static Future<void> setTimeOut(int duration, Function() function) {
    return Future<void>.delayed(new Duration(milliseconds: duration), function);
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

  static String double_str(input, defalt) {
    double converted = double.tryParse(input) ?? -1;
    if (converted == -1) {
      return defalt;
    } else {
      return converted.toString();
    }
  }

  static Future<void> alert_license_invalid(context) async {
    return await Utils.show_error_dialog(context, "Oh no", "License not accepted,make sure to purchase licenses from Official shops", () {});
  }

  static Future<void> alert_license_valid(context) async {
    return await Utils.show_done_dialog(context, "Success", "License accepted.", () {});
  }

  static Future<void> show_done_dialog(BuildContext context, title, msg, Function? done) async {
    // set up the button
    Completer<void> completer = new Completer<void>();

    AwesomeDialog(
      context: context,
      dialogType: DialogType.SUCCES,
      animType: AnimType.BOTTOMSLIDE,
      title: title,
      desc: msg,
      btnOkOnPress: done,
      onDissmissCallback: (blabla) {
        completer.complete();
        // if (done != null) done();
      },
    )..show();
    return completer.future;
  }

  static Future<void> show_error_dialog(BuildContext context, title, msg, Function? done) async {
    // set up the button
    Completer<void> completer = new Completer<void>();

    AwesomeDialog(
      context: context,
      dialogType: DialogType.ERROR,
      animType: AnimType.BOTTOMSLIDE,
      title: title,
      desc: msg,
      onDissmissCallback: (blabla) {
        completer.complete();
        // if (done != null) done();
      },
    )..show();
    return completer.future;
  }

  static Future<void> alert(BuildContext context, title, msg, [Function? andthen]) async {
    // set up the button
    Completer<void> completer = new Completer<void>();

    AwesomeDialog(
      context: Navigator.of(context, rootNavigator: true).context,
      dialogType: DialogType.INFO,
      animType: AnimType.BOTTOMSLIDE,
      title: title,
      dismissOnBackKeyPress: true,
      desc: msg,
      // useRootNavigator: true,
      // btnCancelOnPress: () {},
      btnOkOnPress: () {
        // Navigator.of(context).pop(false);
        // Navigator.of(context, rootNavigator: true).pop(); //pop dialog
      },
      onDissmissCallback: (type) {
        if (andthen != null) {
          andthen();
        }
      },
    )..show();
    return completer.future;

    // show the dialog
    // await showDialog(
    //   context: mcontext,
    //   builder: (BuildContext context) {
    //     Widget okButton = FlatButton(
    //       child: Text("OK", style: Theme.of(context).textTheme.bodyText1!),
    //       onPressed: () {
    //         Navigator.of(context).pop();
    //       },
    //     );

    //     // set up the AlertDialog
    //     AlertDialog alert = AlertDialog(
    //       title: Text(title, style: Theme.of(context).textTheme.bodyText1!),
    //       content: Text(msg, style: Theme.of(context).textTheme.bodyText1!),
    //       actions: [
    //         okButton,
    //       ],
    //     );
    //     return alert;
    //   },
    // );
  }

  static Future<String> ask_serial(String title, context) async {
    String return_value = "";
    Widget buildTextField(BuildContext context) => TextField(
          style: Theme.of(context).textTheme.bodyText1!,
          // controller: controller,
          maxLength: 10,
          keyboardType: TextInputType.numberWithOptions(decimal: false, signed: true),
          onChanged: (value) {
            return_value = value;
          },
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],

          decoration:
              InputDecoration(hintText: AppLocalizations.of(context)!.enterSerialNumber, hintStyle: Theme.of(context).textTheme.bodyText1!, counterText: ""),
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
                  title: Text("Scan Qr Code", style: Theme.of(context).textTheme.bodyText1!),
                  onTap: () async {
                    return_value = (await Navigator.pushNamed(context, "/scan_barcode")).toString();
                    if (return_value == "null") {
                      return_value = "";
                    }
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
              SizedBox(
                height: MediaQuery.of(context).viewInsets.bottom,
              )
            ]));

    return return_value;
  }

  static Future<void> ask_license_type_serial(context, String title, String subtitle, List<String> Options, String Option_selected,
      Future<void> Function(String serial, String selected_option) done) async {
    String return_value = "";

    List<DropdownMenuItem<String>> _dropDownMenuItems = [];
    for (String option in Options) {
      _dropDownMenuItems.add(new DropdownMenuItem(value: option, child: new Text(option)));
    }

    Widget buildTextField(BuildContext context) => TextField(
          style: Theme.of(context).textTheme.bodyText1!,
          // controller: controller,
          maxLength: 10,
          keyboardType: TextInputType.numberWithOptions(decimal: false, signed: true),
          onChanged: (value) {
            return_value = value;
          },

          decoration:
              InputDecoration(hintText: AppLocalizations.of(context)!.enterSerialNumber, hintStyle: Theme.of(context).textTheme.bodyText1!, counterText: ""),
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
                title: Text(subtitle, style: Theme.of(context).textTheme.bodyText1!),
                trailing: StatefulBuilder(
                  builder: (BuildContext context, StateSetter dropDownState) {
                    return DropdownButton(
                        value: Option_selected,
                        items: _dropDownMenuItems,
                        onChanged: (String? selected_op) {
                          if (selected_op != null) {
                            dropDownState(() {
                              Option_selected = selected_op;
                            });
                          }
                        });
                  },
                ),
              ),
              ListTile(
                  leading: Icon(Icons.qr_code),
                  title: Text("Scan Qr Code", style: Theme.of(context).textTheme.bodyText1!),
                  onTap: () async {
                    return_value = (await Navigator.pushNamed(context, "/scan_barcode")).toString();
                    if (return_value == "null") {
                      return_value = "";
                    }
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
              SizedBox(
                height: MediaQuery.of(context).viewInsets.bottom,
              )
            ]));

    await done(return_value, Option_selected);
  }

  static Future<void> show_loading(context, Future<void> Function() done, {String? title = "please wait"}) async {
    showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: new Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  new CircularProgressIndicator(),
                  SizedBox(
                    width: 10,
                  ),
                  new Text(title!),
                ],
              ),
            ),
          ),
        );
      },
    );
    await done();
    Navigator.of(context, rootNavigator: true).pop(); //pop dialog
  }

  static Future<void> show_loading_timed({context, String title = "Fetching data...", int duration = 5000, required Future<void> Function() done}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: new Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  new CircularProgressIndicator(),
                  SizedBox(
                    width: 10,
                  ),
                  new Text(title),
                ],
              ),
            ),
          ),
        );
      },
    );
    Timer t = Timer(Duration(milliseconds: duration), () {
      Navigator.of(context, rootNavigator: true).pop(); //pop dialog
    });

    await done();
    if (t.isActive) {
      t.cancel();
      Navigator.of(context, rootNavigator: true).pop(); //pop dialog

    }
  }
}
