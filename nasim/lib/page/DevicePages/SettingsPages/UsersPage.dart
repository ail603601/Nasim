import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nasim/Model/User.dart';
import 'package:nasim/enums.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
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
        title: Text(user.name),
        subtitle: Text(user.mac),
        onChanged: (value) {
          setState(() {
            user.access = value;
          });
        },
        value: user.access,
      );

  final users_found = [
    new User(name: "Galaxy s9", mac: "XX XX XX XX", connectionState: ConnectionStatus.connected_internet),
    new User(name: "Galaxy s9", mac: "XX XX XX XX", connectionState: ConnectionStatus.connected_internet),
  ];

  Widget build_root_view() => Padding(
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
            ...users_found.map((e) => buildUserPhoneListTile(e)).toList()
          ],
        ),
      );
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
