import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nasim/Model/User.dart';
import 'package:nasim/enums.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/provider/LicenseChangeNotifier.dart';
import 'package:nasim/provider/SavedevicesChangeNofiter.dart';
import 'package:provider/provider.dart';

import '../../../utils.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  @override
  void initState() {
    super.initState();

    cmg = Provider.of<ConnectionManager>(context, listen: false);
    Utils.setTimeOut(0, refresh);
    can_next = false;
  }

  static bool can_next = false;

  add_device() async {
    await refresh();

    if (can_next) {
      Utils.showSnackBar(context, "you can't add your phone again.");
      return;
    }

    var lcn = Provider.of<LicenseChangeNotifier>(context, listen: false);

    if (users_found.length > 2) {
      if (!lcn.six_mobiles) {
        var data = await Utils.ask_serial("Only 3 mobiles can be added by free, delete one mobile or provide the 6 mobiles serial number", context);
        if (data == "") {
          return;
        }
        await Provider.of<ConnectionManager>(context, listen: false).setRequest(76, "6", context);

        bool is_valid = await Provider.of<ConnectionManager>(context, listen: false).setRequest(78, data, context);
        if (is_valid) {
          lcn.license_6_mobiles(context);
        } else {
          Utils.showSnackBar(context, "Wrong serial number.");

          return;
        }
      }
    }
    await _displayTextInputDialog(context, (name) async {
      name = name.trim();
      if (users_found.any((element) => element.name == name)) {
        Utils.showSnackBar(context, "this name already exists");
      } else {
        bool user_added = await cmg.setRequest(users_found.length + 16, name, context);
        if (user_added) {
          var saved_chn = Provider.of<SavedDevicesChangeNotifier>(context, listen: false);
          await saved_chn.addDevice(SavedDevicesChangeNotifier.getSelectedDevice()!);

          await saved_chn.updateSelectedDeviceUserName(name);

          await Provider.of<ConnectionManager>(context, listen: false)
              .setRequest(users_found.length + 28, SavedDevicesChangeNotifier.getSelectedDevice()!.serial + name, context);
          await refresh();
          can_next = true;
        } else {
          Utils.showSnackBar(context, "communication failed.");
        }
      }
    });
  }

  late ConnectionManager cmg;

  Future<void> process_user(i) async {
    String name_n = await cmg.getRequest(i + 16, context);
    name_n = name_n.trim();
    if (name_n != "") users_found.add(User(name: name_n, id_table: i + 16));
    // String user_key = await cmg.getRequest(${i + 16 + 12}");

    // if (name_n != "" && user_key.contains(SavedDevicesChangeNotifier.getSelectedDevice()!.serial + name_n)) {
    //   String user_name_to_add = name_n;

    //   if (!users_found.any((element) => element.name == user_name_to_add)) users_found.add(User(name: user_name_to_add, id_table: i + 16));
    // }
    return;
  }

  List<User> users_found = [];
  Future<void> refresh() async {
    await Utils.show_loading_timed(
        context: context,
        done: () async {
          users_found = [];
          can_next = false;
          await process_user(0);
          await process_user(1);
          await process_user(2);
          await process_user(3);
          await process_user(4);
          await process_user(5);
          String usernaem = SavedDevicesChangeNotifier.getSelectedDevice()!.username;

          users_found.forEach((element) {
            if (element.name == usernaem) {
              can_next = true;
            }
          });

          if (!can_next) {
            print("user not found username:${usernaem}");
          }

          // await Provider.of<SavedDevicesChangeNotifier>(context, listen: false).updateSelectedDeviceUserName("");

          if (mounted) {
            setState(() {});
          }
        });
  }

  var last_dialog_text = "manager";
  Future<void> _displayTextInputDialog(BuildContext context, Function(String) cb) async {
    last_dialog_text = "manager";
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Choose a name ', style: Theme.of(context).textTheme.bodyText1),
            content: TextField(
              inputFormatters: [WhitelistingTextInputFormatter(RegExp(r"[a-zA-Z0-9]+|\s"))],
              maxLength: 9,
              style: Theme.of(context).textTheme.bodyText1,
              onChanged: (value) {
                setState(() {
                  last_dialog_text = value;
                });
              },
              decoration: InputDecoration(hintText: "manager"),
            ),
            actions: <Widget>[
              FlatButton(
                // color: Colors.red,
                textColor: Colors.black,
                child: Text('CANCEL', style: Theme.of(context).textTheme.bodyText1),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                // color: Colors.green,
                textColor: Colors.black,
                child: Text('OK', style: Theme.of(context).textTheme.bodyText1),
                onPressed: () {
                  if (last_dialog_text.trim() == "") last_dialog_text = "manager";

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

  DeleteUser(User user) async {
    if (SavedDevicesChangeNotifier.getSelectedDevice()!.username == user.name) {
      // await Provider.of<SavedDevicesChangeNotifier>(context, listen: false).updateSelectedDeviceUserName("");
      // Provider.of<SavedDevicesChangeNotifier>(context, listen: false).removeDevice(SavedDevicesChangeNotifier.getSelectedDevice()!);
      can_next = false;
    }
    await cmg.setRequest(user.id_table, "???????????", context);
    await cmg.setRequest(user.id_table + 12, "???????????????????", context);
    users_found = [];
    refresh();
  }

  Widget buildTitleBox(context) => Container(
        padding: EdgeInsets.fromLTRB(7, 7, 7, 7),
        color: Theme.of(context).hintColor,
        child: Text(AppLocalizations.of(context)!.usersPageDescription, style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.white)),
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
          trailing: SavedDevicesChangeNotifier.getSelectedDevice()!.accessibility == DeviceAccessibility.AccessibleInternet
              ? null
              : FlatButton(
                  child: Text("Delete", style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.red)),
                  onPressed: () {
                    DeleteUser(user);
                  },
                ),
        ),
      );

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
            child: Text("Add your phone", style: Theme.of(context).textTheme.bodyText1),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: Theme.of(context).canvasColor, child: SafeArea(child: build_root_view()));
  }
}
