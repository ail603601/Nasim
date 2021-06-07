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
  }

  late ConnectionManager cmg;

  Future<void> process_user(i) async {
    String name_n = await cmg.getRequest("get${i + 16}");

    if (name_n.startsWith("_")) {
      String user_name_to_add = name_n.substring(1);

      if (!users_found.any((element) => element.name == user_name_to_add)) users_found.add(User(name: user_name_to_add, id_table: i + 16));
    }
    return;
  }

  List<User> users_found = [];
  refresh() async {
    await Utils.show_loading_timed(
        context: context,
        done: () async {
          if (!mounted) {
            return;
          }
          await process_user(0);
          await process_user(1);
          await process_user(2);
          await process_user(3);
          await process_user(4);
          await process_user(5);

          if (!users_found.any((element) {
            if ("_" + element.name == SavedDevicesChangeNotifier.selected_device!.username) {
              element.is_self = true;
              return true;
            }
            return false;
          })) {
            await Provider.of<SavedDevicesChangeNotifier>(context, listen: false).updateSelecteduser_name("");
          } else {}
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
            title: Text('Choose a name for this device', style: Theme.of(context).textTheme.bodyText1),
            content: TextField(
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
          subtitle: Text(user.is_self ? "Current Device" : ""),
          trailing: (!user.is_self)
              ? FlatButton(
                  child: Text("Delete", style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.red)),
                  onPressed: () async {
                    await cmg.set_request(user.id_table, "0000000000");
                    await cmg.set_request(user.id_table + 12, "0000000000");
                    users_found = [];
                    refresh();
                  },
                )
              : null,
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
                // buildTitleBox(context),
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
