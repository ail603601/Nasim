import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nasim/Model/User.dart';
import 'package:nasim/enums.dart';
import 'package:nasim/provider/ConnectionManager.dart';
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
    cs = 0;
    refresh();
  }

  late ConnectionManager cmg;
  var device_count = 1;
  refresh() async {
    device_count = int.parse(Utils.int_str(await cmg.getRequest("get82"), device_count));

    Utils.setTimeOut(1000, refresh);
  }

  Widget buildTitleBox(context) => Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0.0),
        ),
        child: Text(AppLocalizations.of(context)!.usersPageDescription, style: Theme.of(context).textTheme.bodyText1!),
      );

  Widget buildUserPhoneListTile(User user) => SwitchListTile(
        secondary: Icon(Icons.phone_android),
        title: Text(
          user.name,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        subtitle: Text(
          user.mac,
        ),
        onChanged: (value) {
          setState(() {
            // user.access = value;
            bools[1] = value;
          });
        },
        value: bools[1],
      );

  var users_found = [];
  var bools = [true, true, true, true, true, true];
  int cs = 0;
  Widget build_root_view() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildTitleBox(context),
          Divider(
            color: Theme.of(context).accentColor,
          ),
          SizedBox(height: 56),
          ...users_found
              .map((e) => buildUserPhoneListTile(
                    e,
                  ))
              .toList()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    users_found = [];
    for (var i = 0; i < device_count; i++) {
      users_found.add(User(name: "Device Name", mac: "XX XX XX XX", connectionState: ConnectionStatus.connected_internet));
    }
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
