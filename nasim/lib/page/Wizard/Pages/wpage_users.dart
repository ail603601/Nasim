import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nasim/IntroductionScreen/introduction_screen.dart';
import 'package:nasim/Model/User.dart';
import 'package:nasim/enums.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/provider/LicenseChangeNotifier.dart';
import 'package:nasim/provider/SavedevicesChangeNofiter.dart';
import 'package:provider/provider.dart';

import '../../../utils.dart';
import '../../DevicesListConnect.dart';
import '../Wizardpage.dart';

class wpage_users extends StatefulWidget {
  @override
  wpage_usersState createState() => wpage_usersState();

  bool Function()? Next = null;
}

class wpage_usersState extends State<wpage_users> {
  @override
  void initState() {
    super.initState();
    widget.Next = () {
      return can_next;
    };
    cmg = Provider.of<ConnectionManager>(context, listen: false);
    Utils.setTimeOut(0, refresh);
    can_next = false;
  }

  static bool can_next = false;

  add_device() async {
    Stopwatch stopwatch = new Stopwatch()..start();
    await refresh();
    print('refresh() executed in ${stopwatch.elapsed}');

    if (SavedDevicesChangeNotifier.selected_device!.username != "") {
      Utils.showSnackBar(context, "you can't add your phone again.");
      return;
    }

    var lcn = Provider.of<LicenseChangeNotifier>(context, listen: false);

    if (users_found.length > 2) {
      if (!lcn.six_mobiles) {
        var data = await Utils.ask_serial("only 3 mobiles can be added by free, delete one mobile or provide the 6 mobiles serial number", context);
        if (data == "") {
          return;
        }
        await Provider.of<ConnectionManager>(context, listen: false).set_request(76, "6");

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
      if (users_found.any((element) => element.name == name)) {
        Utils.showSnackBar(context, "this name already exists");
      } else {
        if (await cmg.set_request(users_found.length + 16, name)) {
          var saved_chn = Provider.of<SavedDevicesChangeNotifier>(context, listen: false);
          await saved_chn.addDevice(SavedDevicesChangeNotifier.selected_device!);

          await saved_chn.updateSelecteduser_name(name);
          await Provider.of<ConnectionManager>(context, listen: false)
              .set_request(users_found.length + 28, SavedDevicesChangeNotifier.selected_device!.serial + name);
          await refresh();
          Utils.showSnackBar(context, "Done.");
          can_next = true;
          if (DevicesListConnectState.flag_only_user == false) Utils.setTimeOut(100, IntroductionScreenState.force_next);
        } else {
          Utils.showSnackBar(context, "communication failed.");
        }
      }
    });
  }

  late ConnectionManager cmg;

  Future<void> process_user(i) async {
    String name_n = await cmg.getRequest_non0("get${i + 16}");

    if (name_n != "") {
      String user_name_to_add = name_n;

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
            return element.name == SavedDevicesChangeNotifier.selected_device!.username;
          })) {
            await Provider.of<SavedDevicesChangeNotifier>(context, listen: false).updateSelecteduser_name("");
            can_next = false;
          } else {
            can_next = true;
          }
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
                  if (DevicesListConnectState.flag_only_user == false) IntroductionScreenState.force_next();
                },
              ),
            ],
          );
        });
    // Provider.of<SavedDevicesChangeNotifier>(context, listen: false)..addDevice(d);

    // Navigator.of(context).popUntil((route) => route.isFirst);
  }

  DeleteUser(User user) async {
    if (SavedDevicesChangeNotifier.selected_device!.username == user.name) {
      await Provider.of<SavedDevicesChangeNotifier>(context, listen: false).updateSelecteduser_name("");
      Provider.of<SavedDevicesChangeNotifier>(context, listen: false).removeDevice(SavedDevicesChangeNotifier.selected_device!);
      can_next = false;
    }
    await cmg.set_request(user.id_table, "00000000000");
    await cmg.set_request(user.id_table + 12, "00000000000000000000");
    users_found = [];
    refresh();
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
