import 'dart:developer';
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nasim/Model/Device.dart';
import 'package:nasim/Model/menu_info.dart';
import 'package:nasim/page/DevicePages/ControllPages/AirSpeedPage.dart';
import 'package:nasim/page/DevicePages/ControllPages/HumidityPage.dart';
import 'package:nasim/page/DevicePages/ControllPages/InletFanSpeedPage.dart';
import 'package:nasim/page/DevicePages/ControllPages/LightPage.dart';
import 'package:nasim/page/DevicePages/ControllPages/TemperaturePage.dart';
import 'package:nasim/utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:math';

import '../../provider/ConnectionManager.dart';
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
  String initialroute = "";
  @override
  void initState() {
    super.initState();

    initialroute = WizardPage.flag_ask_to_config_internet ? '/internet' : "/";
    WizardPage.flag_ask_to_config_internet = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> didPopRoute() async {
    final NavigatorState navigator = widget.navigatorKey.currentState!;
    assert(navigator != null);
    return await navigator.maybePop();
  }

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
        color: Color.fromARGB(255, 56, 165, 255),
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
        color: Color.fromARGB(255, 96, 205, 255),
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
        color: Color.fromARGB(255, 255, 191, 95),
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
        color: Color.fromARGB(255, 213, 92, 235),
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
        color: Color.fromARGB(255, 25, 224, 32),
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
        color: Colors.grey[50],
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
        color: Color.fromARGB(255, 255, 31, 106),
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
        color: Color.fromARGB(255, 228, 231, 33),
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

  Widget build_Reset_card(context) => Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Color.fromARGB(255, 212, 49, 82),
        elevation: 10,
        child: InkWell(
          borderRadius: BorderRadius.circular(15.0),
          onTap: () {
            AwesomeDialog(
              context: context,
              useRootNavigator: true,
              dialogType: DialogType.WARNING,
              animType: AnimType.BOTTOMSLIDE,
              title: "Confirm",
              desc: "Current Page Settings will be restored to factory defaults",
              btnOkOnPress: () async {
                await Provider.of<ConnectionManager>(context, listen: false).setRequest(128, '8');
                Utils.showSnackBar(context, "Your device will restart.");
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              btnCancelOnPress: () {},
            )..show();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: Text('Reset All Settings To Factory Defaults', style: Theme.of(context).textTheme.bodyText1),
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
    return WillPopScope(
      onWillPop: () async {
        return !await didPopRoute();
      },
      child: SafeArea(
          child: Navigator(
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
                        build_Reset_card(context)
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
