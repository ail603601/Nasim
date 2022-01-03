import 'dart:async';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nasim/IntroductionScreen/introduction_screen.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../../utils.dart';
import '../Wizardpage.dart';

class wpage_controller_status extends StatefulWidget {
  @override
  wpage_controller_statusState createState() => wpage_controller_statusState();

  bool Function()? Next = null;
  bool Function()? Back = null;
}

class wpage_controller_statusState extends State<wpage_controller_status> with SingleTickerProviderStateMixin {
  late ConnectionManager cmg;
  TabController? _tabController;
  bool is_night = false;
  bool MODIFIED = false;
  String Old_Cooler_Controller_Day_Mode = "";
  String Old_Cooler_Controller_Night_Mod = "";
  String Old_Heater_Controller_Day_Mode = "";
  String Old_Heater_Controller_Night_Mode = "";
  String Old_Humidity_Controller_Day_Mode = "";
  String Old_Humidity_Controller_Night_Mode = "";
  String Old_Air_Purifier_Controller_Day_Mode = "";
  String Old_Air_Purifier_Controller_Night_Mode = "";
  // bool check_modification() {
  //   if (is_night) {
  //     if (Old_Max_Night_IAQ == max_iaq_controller.text &&
  //         Old_Min_Night_IAQ == min_iaq_controller.text &&
  //         Old_Max_Night_CO2 == max_co2_controller.text &&
  //         Old_Min_Night_CO2 == min_co2_controller.text) {
  //       MODIFIED = false;
  //     } else
  //       MODIFIED = true;
  //   } else {
  //     if (Old_Max_Day_IAQ == max_iaq_controller.text &&
  //         Old_Min_Day_IAQ == min_iaq_controller.text &&
  //         Old_Max_Day_CO2 == max_co2_controller.text &&
  //         Old_Min_Day_CO2 == min_co2_controller.text) {
  //       MODIFIED = false;
  //     } else
  //       MODIFIED = true;
  //   }

  //   return MODIFIED;
  // }

  @override
  void initState() {
    super.initState();
    widget.Back = () {
      if (_tabController!.index == 1) {
        _tabController!.animateTo(0);
        return false;
      }
      return true;
    };
    widget.Next = () {
      if (_tabController!.index == 0) {
        _tabController!.animateTo(1);
      } else if (_tabController!.index == 1) {
        return true;
      }
      return false;
    };
    _tabController = new TabController(vsync: this, length: tabs.length);

    _tabController!.addListener(() {
      is_night = _tabController!.index == 1;
      refresh();
    });
    cmg = Provider.of<ConnectionManager>(context, listen: false);

    Utils.setTimeOut(0, refresh);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController!.dispose();
  }

  refresh() async {
    await Utils.show_loading_timed(
        context: context,
        done: () async {
          ConnectionManager.Cooler_Controller_Day_Mode = (int.tryParse(await cmg.getRequest(112, context)) ?? 0).toString();
          ConnectionManager.Cooler_Controller_Night_Mod = (int.tryParse(await cmg.getRequest(113, context)) ?? 0).toString();
          ConnectionManager.Heater_Controller_Day_Mode = (int.tryParse(await cmg.getRequest(114, context)) ?? 0).toString();
          ConnectionManager.Heater_Controller_Night_Mode = (int.tryParse(await cmg.getRequest(115, context)) ?? 0).toString();
          ConnectionManager.Humidity_Controller_Day_Mode = (int.tryParse(await cmg.getRequest(116, context)) ?? 0).toString();
          ConnectionManager.Humidity_Controller_Night_Mode = (int.tryParse(await cmg.getRequest(117, context)) ?? 0).toString();
          ConnectionManager.Air_Purifier_Controller_Day_Mode = (int.tryParse(await cmg.getRequest(118, context)) ?? 0).toString();
          ConnectionManager.Air_Purifier_Controller_Night_Mode = (int.tryParse(await cmg.getRequest(119, context)) ?? 0).toString();

          if (is_night) {
            cooler_mod_val = ConnectionManager.Cooler_Controller_Night_Mod == "1" ? true : false;
            heater_mod_val = ConnectionManager.Heater_Controller_Night_Mode == "1" ? true : false;
            humidity_mod_val = ConnectionManager.Humidity_Controller_Night_Mode == "1" ? true : false;
            ap_mod_val = ConnectionManager.Air_Purifier_Controller_Night_Mode == "1" ? true : false;
          } else {
            cooler_mod_val = ConnectionManager.Cooler_Controller_Day_Mode == "1" ? true : false;
            heater_mod_val = ConnectionManager.Heater_Controller_Day_Mode == "1" ? true : false;
            humidity_mod_val = ConnectionManager.Humidity_Controller_Day_Mode == "1" ? true : false;
            ap_mod_val = ConnectionManager.Air_Purifier_Controller_Day_Mode == "1" ? true : false;
          }
          if (mounted) setState(() {});
        });
  }

  apply() async {
    await cmg.setRequest(112, Utils.lim_0_100(ConnectionManager.Cooler_Controller_Day_Mode), context);
    await cmg.setRequest(113, (ConnectionManager.Cooler_Controller_Night_Mod), context);
    await cmg.setRequest(114, (ConnectionManager.Heater_Controller_Day_Mode), context);
    await cmg.setRequest(115, (ConnectionManager.Heater_Controller_Night_Mode), context);
    await cmg.setRequest(116, (ConnectionManager.Humidity_Controller_Day_Mode), context);
    await cmg.setRequest(117, (ConnectionManager.Humidity_Controller_Night_Mode), context);
    await cmg.setRequest(118, (ConnectionManager.Air_Purifier_Controller_Day_Mode), context);
    await cmg.setRequest(119, (ConnectionManager.Air_Purifier_Controller_Night_Mode), context);
    if (_tabController!.index == 0) {
      _tabController!.animateTo(1);
    } else if (_tabController!.index == 1) {
      IntroductionScreenState.force_next();
      return;
    }
  }

  bool cooler_mod_val = false;
  List<Widget> cooler_mod() {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
        child: Row(
          children: [
            Expanded(child: Text("Cooler Controller", style: Theme.of(context).textTheme.bodyText1)),
            ToggleSwitch(
              minWidth: 60.0,
              initialLabelIndex: cooler_mod_val ? 1 : 0,
              cornerRadius: 0.0,
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.grey,
              inactiveFgColor: Colors.white,
              activeBgColors: [Colors.blue, Colors.blue],
              labels: ['Off', 'Auto'],
              onToggle: (index) {
                if (is_night)
                  ConnectionManager.Cooler_Controller_Night_Mod = index.toString();
                else
                  ConnectionManager.Cooler_Controller_Day_Mode = index.toString();
                setState(() {
                  cooler_mod_val = index == 1;
                });
              },
            ),
          ],
        ),
      ),
      Divider(
        height: 2,
        thickness: 2,
      )
    ];
  }

  bool heater_mod_val = false;
  List<Widget> heater_mod() {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
        child: Row(
          children: [
            Expanded(child: Text("Heater Controller", style: Theme.of(context).textTheme.bodyText1)),
            ToggleSwitch(
              minWidth: 60.0,
              initialLabelIndex: heater_mod_val ? 1 : 0,
              cornerRadius: 0.0,
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.grey,
              inactiveFgColor: Colors.white,
              activeBgColors: [Colors.blue, Colors.blue],
              labels: ['Off', 'Auto'],
              onToggle: (index) {
                if (is_night)
                  ConnectionManager.Heater_Controller_Night_Mode = index.toString();
                else
                  ConnectionManager.Heater_Controller_Day_Mode = index.toString();
                setState(() {
                  heater_mod_val = index == 1;
                });
              },
            ),
          ],
        ),
      ),
      Divider(
        height: 2,
        thickness: 2,
      )
    ];
  }

  bool humidity_mod_val = false;
  List<Widget> humidity_mod() {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
        child: Row(
          children: [
            Expanded(child: Text("Humidity Controller", style: Theme.of(context).textTheme.bodyText1)),
            ToggleSwitch(
              minWidth: 60.0,
              initialLabelIndex: humidity_mod_val ? 1 : 0,
              cornerRadius: 0.0,
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.grey,
              inactiveFgColor: Colors.white,
              activeBgColors: [Colors.blue, Colors.blue],
              labels: ['Off', 'Auto'],
              onToggle: (index) {
                if (is_night)
                  ConnectionManager.Humidity_Controller_Night_Mode = index.toString();
                else
                  ConnectionManager.Humidity_Controller_Day_Mode = index.toString();
                setState(() {
                  humidity_mod_val = index == 1;
                });
              },
            ),
          ],
        ),
      ),
      Divider(
        height: 2,
        thickness: 2,
      )
    ];
  }

  bool ap_mod_val = false;
  List<Widget> ap_mod() {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
        child: Row(
          children: [
            Expanded(child: Text("Air Purifier Controller", style: Theme.of(context).textTheme.bodyText1)),
            ToggleSwitch(
              minWidth: 60.0,
              initialLabelIndex: ap_mod_val ? 1 : 0,
              cornerRadius: 0.0,
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.grey,
              inactiveFgColor: Colors.white,
              activeBgColors: [Colors.blue, Colors.blue],
              labels: ['Off', 'Auto'],
              onToggle: (index) {
                if (is_night)
                  ConnectionManager.Air_Purifier_Controller_Night_Mode = index.toString();
                else
                  ConnectionManager.Air_Purifier_Controller_Day_Mode = index.toString();
                setState(() {
                  ap_mod_val = index == 1;
                });
              },
            ),
          ],
        ),
      ),
      Divider(
        height: 2,
        thickness: 2,
      )
    ];
  }

  build_apply_button() => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 15),
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: OutlinedButton(
            onPressed: MODIFIED ? apply : null,
            style: OutlinedButton.styleFrom(
                padding: EdgeInsets.only(top: 16, bottom: 10, left: 28, right: 28),
                side: BorderSide(width: 2, color: MODIFIED ? Theme.of(context).primaryColor : Colors.grey),
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(8.0))),
            child: Text("Apply", style: Theme.of(context).textTheme.bodyText1),
          ),
        ),
      );
  build_reset_button() => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 15),
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: OutlinedButton(
            onPressed: () {
              AwesomeDialog(
                context: context,
                useRootNavigator: true,
                dialogType: DialogType.WARNING,
                animType: AnimType.BOTTOMSLIDE,
                title: "Confirm",
                desc: "Current Page Settings will be restored to factory defaults",
                btnOkOnPress: () async {
                  refresh();
                },
                btnCancelOnPress: () {},
              )..show();
            },
            style: OutlinedButton.styleFrom(
                padding: EdgeInsets.only(top: 16, bottom: 16, left: 28, right: 28),
                side: BorderSide(width: 2, color: Theme.of(context).primaryColor),
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(8.0))),
            child: Text("Restore To Factory Defaults", style: Theme.of(context).textTheme.bodyText1),
          ),
        ),
      );

  final List<Tab> tabs = <Tab>[
    new Tab(
      text: "Day",
    ),
    new Tab(
      text: "Night",
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(children: [
          Container(
            color: Colors.black12,
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Text("Controler status", style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 24)),
                Align(
                  alignment: Alignment.centerRight,
                  child: TabBar(
                    isScrollable: false,
                    unselectedLabelColor: Colors.grey,
                    labelColor: Colors.white,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: new BubbleTabIndicator(
                      indicatorHeight: 25.0,
                      indicatorColor: Colors.blueAccent,
                      tabBarIndicatorSize: TabBarIndicatorSize.tab,
                    ),
                    labelStyle: Theme.of(context).textTheme.bodyText1,
                    tabs: tabs,
                    controller: _tabController,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Expanded(
              child: Column(
            children: [
              ...cooler_mod(),
              ...heater_mod(),
              ...humidity_mod(),
              ...ap_mod(),
            ],
          )),
          build_apply_button(),
          build_reset_button(),
          SizedBox(
            height: 64,
          )
        ]));
  }
}
