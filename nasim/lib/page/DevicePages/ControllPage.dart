import 'dart:developer';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nasim/Model/Device.dart';
import 'package:nasim/Model/menu_info.dart';
import 'package:nasim/page/DevicePages/ControllPages/AirSpeedPage.dart';
import 'package:nasim/page/DevicePages/ControllPages/HumidityPage.dart';
import 'package:nasim/page/DevicePages/ControllPages/InletFanSpeedPage.dart';
import 'package:nasim/page/DevicePages/ControllPages/LightPage.dart';
import 'package:nasim/page/DevicePages/ControllPages/TemperaturePage.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:math';

import '../BarCodeScanPage.dart';
import 'ControllPages/AirQualityPage.dart';
import 'ControllPages/ControllersStatusPage.dart';
import 'ControllPages/InternetPage.dart';
import 'ControllPages/SmsPage.dart';
import 'ControllPages/UsersPage.dart';
import 'package:nasim/page/Wizard/Wizardpage.dart';

class ControllPage extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey = new GlobalKey();

  @override
  _ControllPageState createState() => _ControllPageState();
}

class _ControllPageState extends State<ControllPage> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  String initialroute = "";
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  Future<bool> didPopRoute() async {
    final NavigatorState navigator = widget.navigatorKey.currentState!;
    assert(navigator != null);
    return await navigator.maybePop();
  }

  Widget make_animated_icon(tag, path, Color? color) => Hero(
      tag: tag,
      child: AnimatedBuilder(
        animation: _controller!,
        builder: (_, child) {
          return Transform.rotate(
            angle: _controller!.value * 2 * pi,
            child: child,
          );
        },
        child: Image.asset(
          path,
          color: color,
        ),
      ));

  List<Widget> row_detail(x, y, z) => [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                  flex: 2,
                  child: Text(
                    x,
                    textAlign: TextAlign.left,
                  )),
              Expanded(
                flex: 1,
                child: Text(
                  y,
                  textAlign: TextAlign.left,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  z,
                  textAlign: TextAlign.left,
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 6,
        ),
      ];

  Widget build_air_speed_animated_card(context) => Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Colors.blue[200],
        elevation: 10,
        child: InkWell(
          borderRadius: BorderRadius.circular(15.0),
          onTap: () {
            Navigator.pushNamed(context, "/airspeed");
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: Text('Air Speed', style: Theme.of(context).textTheme.bodyText1),
                  trailing: Icon(Icons.arrow_forward_ios),
                  // subtitle: Text('TWICE', style: TextStyle(color: Colors.white)),
                ),

                // ...row_detail("fan speed:", "5W", "10W"),
                // ...row_detail("fan power:", "5W", "10W"),
                // ...row_detail("Pressure Change", "-100", "-100"),
              ],
            ),
          ),
        ),
      );

  Widget build_inlet_fan_speed_animated_card(context) => Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Colors.blueGrey[100],
        elevation: 10,
        child: InkWell(
          borderRadius: BorderRadius.circular(15.0),
          onTap: () {
            Navigator.pushNamed(context, "/inletfanspeed");
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: Text('Inlet Fan Speed', style: Theme.of(context).textTheme.bodyText1),
                  trailing: Icon(Icons.arrow_forward_ios),
                  // subtitle: Text('TWICE', style: TextStyle(color: Colors.white)),
                ),

                // ...row_detail("Day inlet fan speed:", "5W", "10W"),
                // ...row_detail("NIght inlet fan speed:", "5W", "10W"),
                // ...row_detail("Day inlet fan power:", "5W", "10W"),
                // ...row_detail("NIght inlet fan power:", "5W", "10W"),
              ],
            ),
          ),
        ),
      );
  Widget build_temperatutre_card(context) => Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Colors.orange[200],
        elevation: 10,
        child: InkWell(
          borderRadius: BorderRadius.circular(15.0),
          onTap: () {
            Navigator.pushNamed(context, "/temperature");
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: Text('Temperature', style: Theme.of(context).textTheme.bodyText1),
                  trailing: Icon(Icons.arrow_forward_ios),
                  // subtitle: Text('TWICE', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );

  Widget build_humidity_card(context) => Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Colors.purple[200],
        elevation: 10,
        child: InkWell(
          borderRadius: BorderRadius.circular(15.0),
          onTap: () {
            Navigator.pushNamed(context, "/humidity");
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: Text(' Humidity', style: Theme.of(context).textTheme.bodyText1),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
          ),
        ),
      );

  Widget build_air_quality_card(context) => Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Colors.green[400],
        elevation: 10,
        child: InkWell(
          borderRadius: BorderRadius.circular(15.0),
          onTap: () {
            Navigator.pushNamed(context, "/airquality");
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: Text('Air Quality', style: Theme.of(context).textTheme.bodyText1),
                  trailing: Icon(Icons.arrow_forward_ios),
                  // subtitle: Text('TWICE', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );

  Widget build_light_level_card(context) => Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Colors.grey[800],
        elevation: 10,
        child: InkWell(
          borderRadius: BorderRadius.circular(15.0),
          onTap: () {
            Navigator.pushNamed(context, "/light");
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: Text('Light', style: Theme.of(context).textTheme.bodyText1),
                  trailing: Icon(Icons.arrow_forward_ios),
                  // subtitle: Text('TWICE', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );

  Widget build_sms_card(context) => Card(
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
          onTap: () {
            Navigator.pushNamed(context, "/internet");
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
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
                  title: Text('Controllers Status', style: Theme.of(context).textTheme.bodyText1),
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
                  title: Text('Users', style: Theme.of(context).textTheme.bodyText1),
                  trailing: Icon(Icons.arrow_forward_ios),
                  // subtitle: Text('TWICE', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    initialroute = WizardPage.flag_ask_to_config_internet ? '/internet' : "/";
    WizardPage.flag_ask_to_config_internet = false;

    return WillPopScope(
      onWillPop: () async {
        return !await didPopRoute();
      },
      child: SafeArea(
          child: Navigator(
        observers: [
          HeroController(),
        ],
        key: widget.navigatorKey,
        initialRoute: initialroute,
        onGenerateRoute: (settings) {
          if (settings.name == "/") {
            return CupertinoPageRoute(
                builder: (context) => ListView(
                      children: [
                        build_air_speed_animated_card(context),
                        build_inlet_fan_speed_animated_card(context),
                        build_temperatutre_card(context),
                        build_humidity_card(context),
                        build_air_quality_card(context),
                        build_light_level_card(context),
                        build_sms_card(context),
                        build_internet_card(context),
                        build_conterollers_status_card(context),
                        build_users_status_card(context),
                      ],
                    ));
          }
          if (settings.name == "/airspeed") {
            return CupertinoPageRoute(builder: (context) => BackdropFilter(filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), child: AirSpeedPage()));
          }
          if (settings.name == "/inletfanspeed") {
            return CupertinoPageRoute(
                builder: (context) => BackdropFilter(filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), child: InletFanSpeedPage()));
          }
          if (settings.name == "/temperature") {
            return CupertinoPageRoute(builder: (context) => BackdropFilter(filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), child: TemperaturePage()));
          }
          if (settings.name == "/humidity") {
            return CupertinoPageRoute(builder: (context) => BackdropFilter(filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), child: HumidityPage()));
          }
          if (settings.name == "/airquality") {
            return CupertinoPageRoute(builder: (context) => BackdropFilter(filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), child: AirQualityPage()));
          }
          if (settings.name == "/light") {
            return CupertinoPageRoute(builder: (context) => BackdropFilter(filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), child: LightPage()));
          }

          if (settings.name == "/sms") {
            return CupertinoPageRoute(builder: (context) => BackdropFilter(filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), child: SmsPage()));
          }
          if (settings.name == "/cstatus") {
            return CupertinoPageRoute(
                builder: (context) => BackdropFilter(filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), child: ControllersStatusPage()));
          }
          if (settings.name == "/users") {
            return CupertinoPageRoute(builder: (context) => BackdropFilter(filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), child: UsersPage()));
          }
          if (settings.name == "/internet") {
            return CupertinoPageRoute(builder: (context) => BackdropFilter(filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), child: InternetPage()));
          }

          return CupertinoPageRoute(builder: (context) => build_inlet_fan_speed_animated_card(context));
        },
      )),
    );
  }
}
