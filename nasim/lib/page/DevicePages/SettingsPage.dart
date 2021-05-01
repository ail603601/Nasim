import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nasim/Model/Device.dart';
import 'package:nasim/Model/menu_info.dart';
import 'package:nasim/page/DevicePages/SettingsPages/SmsPage.dart';
import 'package:nasim/page/DevicePages/SettingsPages/UsersPage.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:math';
import 'package:nasim/page/DevicePages/SettingsPages/ControllersStatusPage.dart';

class SettingsPage extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey = new GlobalKey();

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Widget build_temperatutre_humidity_card(context) => Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Colors.pinkAccent[200],
        elevation: 10,
        child: InkWell(
          borderRadius: BorderRadius.circular(15.0),
          onTap: () {
            Navigator.pushNamed(context, "/sms");
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Image.asset("assets/text-message.png"),
                  title: Text('SMS', style: Theme.of(context).textTheme.bodyText1),
                  trailing: Icon(Icons.arrow_forward_ios),
                  // subtitle: Text('TWICE', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
  Widget build_internet_card(context) => Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Colors.brown[500],
        elevation: 10,
        child: InkWell(
          borderRadius: BorderRadius.circular(15.0),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Image.asset("assets/internet.png"),
                  title: Text('Internet', style: Theme.of(context).textTheme.bodyText1),
                  trailing: Icon(Icons.arrow_forward_ios),
                  // subtitle: Text('TWICE', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );

  Widget build_conterollers_status_card(context) => Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Colors.blueGrey[700],
        elevation: 10,
        child: InkWell(
          borderRadius: BorderRadius.circular(15.0),
          onTap: () {
            Navigator.pushNamed(context, "/cstatus");
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Image.asset("assets/controllers-status.png"),
                  title: Text('Controllers status', style: Theme.of(context).textTheme.bodyText1),
                  trailing: Icon(Icons.arrow_forward_ios),
                  // subtitle: Text('TWICE', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );

  Widget build_users_status_card(context) => Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Colors.amber[700],
        elevation: 10,
        child: InkWell(
          borderRadius: BorderRadius.circular(15.0),
          onTap: () {
            Navigator.pushNamed(context, "/users");
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Image.asset("assets/user_icon.png"),
                  title: Text('Users', style: Theme.of(context).textTheme.bodyText1),
                  trailing: Icon(Icons.arrow_forward_ios),
                  // subtitle: Text('TWICE', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );

  Future<bool> didPopRoute() async {
    final NavigatorState navigator = widget.navigatorKey.currentState!;
    assert(navigator != null);
    return await navigator.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !await didPopRoute();
      },
      child: SafeArea(
          child: Navigator(
        key: widget.navigatorKey,
        initialRoute: "/",
        onGenerateRoute: (settings) {
          if (settings.name == "/") {
            return CupertinoPageRoute(
                builder: (context) => ListView(
                      children: [
                        build_temperatutre_humidity_card(context),
                        build_internet_card(context),
                        build_conterollers_status_card(context),
                        build_users_status_card(context)
                      ],
                    ));
          }
          if (settings.name == "/sms") {
            return CupertinoPageRoute(builder: (context) => SmsPage());
          }
          if (settings.name == "/cstatus") {
            return CupertinoPageRoute(builder: (context) => ControllersStatusPage());
          }
          if (settings.name == "/users") {
            return CupertinoPageRoute(builder: (context) => UsersPage());
          }

          return CupertinoPageRoute(builder: (context) => build_temperatutre_humidity_card(context));
        },
      )),
    );
  }
}
