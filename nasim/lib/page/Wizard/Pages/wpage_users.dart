import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nasim/Model/User.dart';
import 'package:nasim/enums.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/provider/LicenseChangeNotifier.dart';
import 'package:nasim/provider/SavedevicesChangeNofiter.dart';
import 'package:provider/provider.dart';

import '../../../utils.dart';
import '../Wizardpage.dart';

class wpage_users extends StatefulWidget {
  @override
  _wpage_usersState createState() => _wpage_usersState();
}

class _wpage_usersState extends State<wpage_users> {
  @override
  void initState() {
    super.initState();
    WizardPage.can_next = false;

    cmg = Provider.of<ConnectionManager>(context, listen: false);
    cs = 0;
    refresh();
  }

  add_device() async {
    if (await refresh()) {
      if (SavedDevicesChangeNotifier.selected_device!.username != "") {
        Utils.showSnackBar(context, "you can't add your phone again.");
        return;
      }

      var lcn = Provider.of<LicenseChangeNotifier>(context, listen: false);

      if (users_found.length > 3) {
        if (!lcn.six_mobiles) {
          var data = await Utils.ask_serial("only 3 mobiles can be added by free, delete one mobile or provide the 6 mobiles serial number", context);
          if (data == "") {
            return;
          }
          bool is_valid = await Provider.of<ConnectionManager>(context, listen: false).set_request(78, data);
          if (is_valid) {
            lcn.license_6_mobiles();
          } else {
            Utils.showSnackBar(context, "Wrong serial number.");
            return;
          }
        }
      }
      await _displayTextInputDialog(context, (name) async {
        name = "_" + name;
        if (users_found.any((element) => "_" + element.name == name)) {
          Utils.showSnackBar(context, "this name already exists");
        } else {
          if (await cmg.set_request(users_found.length + 16, name)) {
            await Provider.of<SavedDevicesChangeNotifier>(context, listen: false).updateSelecteduser_name(name);

            await refresh();
            Utils.showSnackBar(context, "Done.");
            WizardPage.can_next = true;
          } else {
            Utils.showSnackBar(context, "cummunication failed");
          }
        }
      });
      return;
    }
  }

  late ConnectionManager cmg;

  List<User> users_found = [];
  Future<bool> refresh() async {
    users_found = [];

    for (var i = 0; i < 6; i++) {
      String name_n = await cmg.getRequest("get${i + 16}");
      if (name_n == 'timeout') {
        Utils.handleError(context);
        return false;
      }
      if (name_n.startsWith("_")) {
        users_found.add(User(name: name_n.substring(1), id_table: i + 16));
      }
    }
    if (!users_found.any((element) => "_" + element.name == SavedDevicesChangeNotifier.selected_device!.username)) {
      await Provider.of<SavedDevicesChangeNotifier>(context, listen: false).updateSelecteduser_name("");
      WizardPage.can_next = false;
    } else {
      WizardPage.can_next = true;
    }

    setState(() {});
    return true;
  }

  var last_dialog_text = "moderator 1";
  Future<void> _displayTextInputDialog(BuildContext context, Function(String) cb) async {
    last_dialog_text = "moderator 1";
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Choose a name for this device', style: Theme.of(context).textTheme.bodyText1),
            content: TextField(
              maxLength: 10,
              style: Theme.of(context).textTheme.bodyText1,
              onChanged: (value) {
                setState(() {
                  last_dialog_text = value;
                });
              },
              decoration: InputDecoration(hintText: "moderator 1"),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('CANCEL', style: Theme.of(context).textTheme.bodyText1),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('OK', style: Theme.of(context).textTheme.bodyText1),
                onPressed: () {
                  if (last_dialog_text.trim() == "") last_dialog_text = "moderator 1";

                  cb(last_dialog_text);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
    // Provider.of<SavedDevicesChangeNotifier>(context, listen: false)..addDevice(d);

    // Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Widget buildTitleBox(context) => Container(
        padding: EdgeInsets.all(16),
        color: Theme.of(context).hintColor,
        child: Text(AppLocalizations.of(context)!.usersPageDescription, style: Theme.of(context).textTheme.headline6!),
      );

  Widget buildUserPhoneListTile(User user) => Padding(
        padding: const EdgeInsets.only(left: 8),
        child: ListTile(
          leading: Icon(Icons.phone_android),
          title: Text(
            user.name,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          subtitle: Text(
              // user.mac,
              ""),
          trailing: FlatButton(
            child: Text("Delete", style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.red)),
            onPressed: () async {
              if (SavedDevicesChangeNotifier.selected_device!.username == user.name) {
                await Provider.of<SavedDevicesChangeNotifier>(context, listen: false).updateSelecteduser_name("");
                WizardPage.can_next = false;
              }
              await cmg.set_request(user.id_table, "0");
              refresh();
            },
          ),
        ),
      );

  int cs = 0;
  Widget build_root_view() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                buildTitleBox(context),
                // Divider(
                //   color: Theme.of(context).accentColor,
                // ),
                SizedBox(height: 56),
                ...users_found
                    .map((e) => buildUserPhoneListTile(
                          e,
                        ))
                    .toList()
              ],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 15),
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 26),
          child: OutlinedButton(
            onPressed: () {
              add_device();
            },
            style: OutlinedButton.styleFrom(
                padding: EdgeInsets.only(top: 16, bottom: 16, left: 28, right: 28),
                side: BorderSide(width: 2, color: Theme.of(context).primaryColor),
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(8.0))),
            child: Text("Add yourphone", style: Theme.of(context).textTheme.bodyText1),
          ),
        ),
        SizedBox(
          height: 56,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: Theme.of(context).canvasColor, child: SafeArea(child: build_root_view()));

    // return SafeArea(
    //     child: Navigator(
    //   initialRoute: "/",
    //   onGenerateRoute: (settings) {
    //     if (settings.name == "/") {
    //       return CupertinoPageRoute(builder: (context) => build_root_view());
    //     }
    //     return CupertinoPageRoute(builder: (context) => build_root_view());
    //   },
    // ));

    // AppLocalizations.of(context)!.devices
  }
}
