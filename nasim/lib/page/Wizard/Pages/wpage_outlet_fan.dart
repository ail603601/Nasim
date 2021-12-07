import 'dart:async';
import 'dart:math';

import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:holding_gesture/holding_gesture.dart';
import 'package:nasim/IntroductionScreen/introduction_screen.dart';
import 'package:nasim/page/Wizard/Pages/wpage_inlet_fan.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/provider/LicenseChangeNotifier.dart';
import 'package:nasim/utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Wizardpage.dart';

class wpage_outlet_fan extends StatefulWidget {
  @override
  wpage_outlet_fanState createState() => wpage_outlet_fanState();

  bool Function()? Next = null;
}

class wpage_outlet_fanState extends State<wpage_outlet_fan> with SingleTickerProviderStateMixin {
  late ConnectionManager cmg;
  double minimum_negative_presure_fan_speed = 0;
  double maximum_negative_presure_fan_speed = 0;
  int real_output_fan_power = 0;
  late Timer soft_reftresh_timer;

  static bool is_minimum_set = false;
  static bool is_maximum_set = false;

  List<String> fan_power_licenses = ["600 W", "900 W", "1200 W", "1500 W", "1800 W", "2100 W"];

  late String current_license_selected;

  void soft_refresh() async {
    ConnectionManager.Elevation = (int.tryParse(await cmg.getRequest(34)) ?? "0").toString();
    ConnectionManager.Pressure = (int.tryParse(await cmg.getRequest(35)) ?? "0").toString();
    ConnectionManager.Pressure_change = (int.tryParse(await cmg.getRequest(36)) ?? "0").toString();

    if (mounted)
      setState(() {
        real_output_fan_power = (int.tryParse(ConnectionManager.Real_Output_Fan_Power) ?? real_output_fan_power).toInt();
      });
  }

  @override
  void initState() {
    super.initState();

    soft_reftresh_timer = Timer.periodic(new Duration(seconds: 1), (timer) async {
      soft_refresh();
    });

    widget.Next = () {
      if (_tabController!.index == 0) {
        if (!is_minimum_set) {
          Utils.alert(context, " ", "please set minimum fan speed");
          return false;
        } else {
          setState(() {});
          _tabController!.animateTo(1);

          return false;
        }
      } else if (_tabController!.index == 1) {
        if (!is_minimum_set) {
          Utils.alert(context, " ", "please set minimum fan speed");
          return false;
        }
        if (!is_maximum_set) {
          Utils.alert(context, " ", "please set maximum fan speed");
          return false;
        } else {
          return true;
        }
      }

      return false;
    };

    cmg = Provider.of<ConnectionManager>(context, listen: false);

    minimum_negative_presure_fan_speed = (int.tryParse(ConnectionManager.Min_Valid_Output_Fan_Speed) ?? 0.0).toDouble();
    maximum_negative_presure_fan_speed = (int.tryParse(ConnectionManager.Max_Valid_Output_Fan_Speed) ?? 0.0).toDouble();

    _tabController = new TabController(vsync: this, length: tabs.length);

    current_license_selected = fan_power_licenses[0];
    Utils.setTimeOut(0, refresh);
  }

  refresh() async {
    await Utils.show_loading_timed(
        context: context,
        done: () async {
          ConnectionManager.Min_Valid_Output_Fan_Speed = await cmg.getRequest(37);
          ConnectionManager.Real_Output_Fan_Power = await cmg.getRequest(39);
          ConnectionManager.Pressure_change = await cmg.getRequest(36);
          ConnectionManager.Max_Valid_Output_Fan_Speed = await cmg.getRequest(38);
          ConnectionManager.Elevation = (int.tryParse(await cmg.getRequest(34)) ?? "").toString();
          ConnectionManager.Pressure = (int.tryParse(await cmg.getRequest(35)) ?? "").toString();

          if (mounted)
            setState(() {
              real_output_fan_power = (int.tryParse(ConnectionManager.Real_Output_Fan_Power) ?? real_output_fan_power).toInt();

              minimum_negative_presure_fan_speed =
                  (int.tryParse(ConnectionManager.Min_Valid_Output_Fan_Speed) ?? minimum_negative_presure_fan_speed).toDouble();
              maximum_negative_presure_fan_speed =
                  (int.tryParse(ConnectionManager.Max_Valid_Output_Fan_Speed) ?? maximum_negative_presure_fan_speed).toDouble();
            });
        });
  }

  int parse_device_fan(int i) {
    if (i == 0) return 600;
    if (i == 1) return 900;
    if (i == 2) return 1200;
    if (i == 3) return 1500;
    if (i == 4) return 1800;
    if (i == 5) return 2100;

    return 0;
  }

  Future<bool> wait_for_fan_power() async {
    await Utils.show_loading(context, () async {
      await Utils.waitMsec(10 * 1000);
    }, title: "waiting for fan power...");
    // await Utils.waitMsec(10 * 1000);

    int device_fan_power = int.tryParse(await cmg.getRequest(3)) ?? 0;
    int output_fan_power = int.tryParse(await cmg.getRequest(39)) ?? 0;
    device_fan_power = parse_device_fan(device_fan_power);

    if (device_fan_power < output_fan_power) {
      await Utils.ask_license_type_serial(
          context, "You must provide license in order to increase your fan power limit", "Fan power to:", fan_power_licenses, fan_power_licenses[0],
          (String serial, String selected_option) async {
        if (serial != "") {
          int index_selected = fan_power_licenses.indexOf(selected_option);
          await cmg.setRequest(76, index_selected.toString(), context);
          bool isvalid = await cmg.setRequest(77, serial);
          if (isvalid) {
            await Utils.alert_license_valid(context);
          } else {
            await Utils.alert_license_invalid(context);
          }
        }
      });
    }
    return false;
  }

  List<Widget> make_title(titile) {
    return [
      Container(
        padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
        alignment: Alignment.centerLeft,
        child: Text(titile, style: Theme.of(context).textTheme.bodyText1),
      ),
      Divider(
        color: Theme.of(context).accentColor,
      )
    ];
  }

  Widget build_boxed_titlebox({required title, required child}) {
    // debugger();
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: new InputDecorator(
            decoration: InputDecoration(
                labelText: title, labelStyle: Theme.of(context).textTheme.bodyText1, border: OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow))),
            child: child));
  }

  Widget build_elevation_presure() => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: build_boxed_titlebox(
                title: "Elevatoin",
                child: Center(child: Text((int.tryParse(ConnectionManager.Elevation) ?? 0).toString() + " m", style: Theme.of(context).textTheme.bodyText1)),
              ),
            ),
            Expanded(
                child: build_boxed_titlebox(
                    title: "Pressure",
                    child:
                        Center(child: Text((int.tryParse(ConnectionManager.Pressure) ?? 0).toString() + " hpa", style: Theme.of(context).textTheme.bodyText1))))
          ],
        ),
      );

  Future<void> set_air_speed_min_negative_pressure(double value) async {
    try {
      ConnectionManager.Min_Valid_Output_Fan_Speed = value.toInt().toString().padLeft(3, '0');
      await cmg.setRequest(37, ConnectionManager.Min_Valid_Output_Fan_Speed, context);
      if (maximum_negative_presure_fan_speed < value + 5) {
        await set_air_speed_max_negative_pressure(value + 5);
      }

      is_minimum_set = true;
    } catch (e) {}
  }

  Future<void> set_air_speed_max_negative_pressure(double value) async {
    try {
      if (minimum_negative_presure_fan_speed + 5 > value) {
        await Utils.alert(context, "Error", "maximum negative fan presue must at least be 5 more than minimum.");
        return;
      }
      ConnectionManager.Max_Valid_Output_Fan_Speed = value.toInt().toString().padLeft(3, '0');
      cmg.setRequest(38, ConnectionManager.Max_Valid_Output_Fan_Speed, context);

      if (value >= minimum_negative_presure_fan_speed + 5) {
        is_maximum_set = true;
      }
    } catch (e) {}
  }

  build_icon_btn(bool up, Function() clicked) {}

  Widget build_air_speed_min_negative_pressure() {
    return build_boxed_titlebox(
      title: "Minimum Negative Presure",
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(
          children: [
            Text("Outlet Fan Speed: ", style: Theme.of(context).textTheme.bodyText1),
            Text(minimum_negative_presure_fan_speed.toString() + " %", style: Theme.of(context).textTheme.bodyText1),
          ],
        ),
        CupertinoSlider(
          value: minimum_negative_presure_fan_speed,
          min: 0.0,
          max: 95.0,
          divisions: 100,
          onChanged: (double newValue) {},
          onChangeEnd: (double newValue) async {},
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Text("Outlet Fan Power: ", style: Theme.of(context).textTheme.bodyText1)),
            Expanded(child: Center(child: Text((real_output_fan_power).toString() + " W", style: Theme.of(context).textTheme.bodyText1)))
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Text("Pressure Change: ", style: Theme.of(context).textTheme.bodyText1)),
            Expanded(
                child: Center(
                    child: Text((int.tryParse(ConnectionManager.Pressure_change) ?? 0).toString() + "hpa", style: Theme.of(context).textTheme.bodyText1)))
          ],
        ),
        SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Expanded(
            child: Material(
              clipBehavior: Clip.hardEdge,
              borderRadius: BorderRadius.circular(5.0),
              child: Ink(
                decoration: const ShapeDecoration(
                  color: Colors.blue,
                  shape: Border(),
                ),
                child: HoldDetector(
                  onHold: () async {
                    setState(() {
                      minimum_negative_presure_fan_speed = min(minimum_negative_presure_fan_speed.roundToDouble() + 2.0, 95);
                    });
                  },
                  holdTimeout: Duration(milliseconds: 1000),
                  enableHapticFeedback: true,
                  child: IconButton(
                    icon: Icon(Icons.keyboard_arrow_up),
                    iconSize: 50,
                    color: Colors.white,
                    onPressed: () async {
                      setState(() {
                        minimum_negative_presure_fan_speed = min(minimum_negative_presure_fan_speed.roundToDouble() + 1.0, 95);
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 40,
          ),
          Expanded(
            child: Material(
              clipBehavior: Clip.hardEdge,
              borderRadius: BorderRadius.circular(5.0),
              child: Ink(
                decoration: const ShapeDecoration(
                  color: Colors.blue,
                  shape: Border(),
                ),
                child: HoldDetector(
                  onHold: () async {
                    setState(() {
                      minimum_negative_presure_fan_speed = max(minimum_negative_presure_fan_speed.roundToDouble() - 2.0, 0);
                    });
                  },
                  holdTimeout: Duration(milliseconds: 1000),
                  enableHapticFeedback: true,
                  child: IconButton(
                    icon: Icon(Icons.keyboard_arrow_down),
                    iconSize: 50,
                    color: Colors.white,
                    onPressed: () async {
                      setState(() {
                        minimum_negative_presure_fan_speed = max(minimum_negative_presure_fan_speed.roundToDouble() - 1.0, 0);
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
          // RaisedButton.icon(onPressed: null, icon: null, label: null),
        ])
      ]),
    );
  }

  Widget build_air_speed_max_negative_pressure() {
    if (!is_minimum_set)
      return Align(
        alignment: Alignment.topCenter,
        child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.pink[600]!,
                border: Border.all(
                  color: Colors.pink[600]!,
                ),
                borderRadius: BorderRadius.all(Radius.circular(8))),
            child: Container(child: Text("Please set minimum fan speed before changing maximum fan speed.", style: Theme.of(context).textTheme.headline6))),
      );
    else
      return build_boxed_titlebox(
        title: "Maximum Negative Presure",
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(
            children: [
              Text("Outlet Fan Speed: ", style: Theme.of(context).textTheme.bodyText1),
              Text(maximum_negative_presure_fan_speed.toString() + " %", style: Theme.of(context).textTheme.bodyText1),
            ],
          ),
          CupertinoSlider(
            value: maximum_negative_presure_fan_speed,
            min: 0.0,
            max: 100.0,
            divisions: 100,
            onChanged: (double newValue) {},
            onChangeEnd: (double newValue) async {},
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Text("Outlet Fan Power: ", style: Theme.of(context).textTheme.bodyText1)),
              Expanded(child: Center(child: Text((real_output_fan_power).toString() + " W", style: Theme.of(context).textTheme.bodyText1)))
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Text("Pressure Change: ", style: Theme.of(context).textTheme.bodyText1)),
              Expanded(
                  child: Center(
                      child: Text((int.tryParse(ConnectionManager.Pressure_change) ?? 0).toString() + "hpa", style: Theme.of(context).textTheme.bodyText1)))
            ],
          ),
          SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Expanded(
              child: Material(
                clipBehavior: Clip.hardEdge,
                borderRadius: BorderRadius.circular(5.0),
                child: Ink(
                  decoration: const ShapeDecoration(
                    color: Colors.blue,
                    shape: Border(),
                  ),
                  child: HoldDetector(
                    onHold: () async {
                      setState(() {
                        maximum_negative_presure_fan_speed = min(maximum_negative_presure_fan_speed.roundToDouble() + 2.0, 100);
                      });
                    },
                    holdTimeout: Duration(milliseconds: 1000),
                    enableHapticFeedback: true,
                    child: IconButton(
                      icon: Icon(Icons.keyboard_arrow_up),
                      iconSize: 50,
                      color: Colors.white,
                      onPressed: () async {
                        setState(() {
                          maximum_negative_presure_fan_speed = min(maximum_negative_presure_fan_speed.roundToDouble() + 1.0, 100);
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 40,
            ),
            Expanded(
              child: Material(
                clipBehavior: Clip.hardEdge,
                borderRadius: BorderRadius.circular(5.0),
                child: Ink(
                  decoration: const ShapeDecoration(
                    color: Colors.blue,
                    shape: Border(),
                  ),
                  child: HoldDetector(
                    onHold: () async {
                      setState(() {
                        maximum_negative_presure_fan_speed = max(maximum_negative_presure_fan_speed.roundToDouble() - 2.0, 0);
                      });
                    },
                    holdTimeout: Duration(milliseconds: 1000),
                    enableHapticFeedback: true,
                    child: IconButton(
                      icon: Icon(Icons.keyboard_arrow_down),
                      iconSize: 50,
                      color: Colors.white,
                      onPressed: () async {
                        setState(() {
                          maximum_negative_presure_fan_speed = max(maximum_negative_presure_fan_speed.roundToDouble() - 1.0, 0);
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
            // RaisedButton.icon(onPressed: null, icon: null, label: null),
          ])
        ]),
      );
  }

  build_apply_button(click) => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 15),
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: OutlinedButton(
            onPressed: click,
            style: OutlinedButton.styleFrom(
                padding: EdgeInsets.only(top: 16, bottom: 16, left: 28, right: 28),
                side: BorderSide(width: 2, color: Theme.of(context).primaryColor),
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
            onPressed: () async {
              if (_tabController!.index == 0) {
                cmg.setRequest(37, "000", context);
              } else {
                cmg.setRequest(38, "000", context);
              }

              refresh();
            },
            style: OutlinedButton.styleFrom(
                padding: EdgeInsets.only(top: 16, bottom: 16, left: 28, right: 28),
                side: BorderSide(width: 2, color: Theme.of(context).primaryColor),
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(8.0))),
            child: Text("Restore Defaults", style: Theme.of(context).textTheme.bodyText1),
          ),
        ),
      );

  TabController? _tabController;

  @override
  void dispose() {
    _tabController!.dispose();
    soft_reftresh_timer.cancel();

    // refresher.cancel();
    super.dispose();
  }

  final List<Tab> tabs = <Tab>[
    new Tab(
      text: "Minimum",
    ),
    new Tab(
      text: "Maximum",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Container(
          color: Colors.black12,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: Align(
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
                      // Other flags
                      // indicatorRadius: 1,
                      // insets: EdgeInsets.all(1),
                      // padding: EdgeInsets.all(10)
                    ),
                    labelStyle: Theme.of(context).textTheme.bodyText1,
                    tabs: tabs,
                    controller: _tabController,
                  ),
                ),
              ),
              Expanded(child: Text("Outlet Fan Speed", style: Theme.of(context).textTheme.bodyText1)),
            ],
          ),
        ),
        build_elevation_presure(),
        Expanded(
          child: new TabBarView(controller: _tabController, physics: NeverScrollableScrollPhysics(), children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: build_air_speed_min_negative_pressure(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: build_air_speed_max_negative_pressure(),
            )
          ]),
        ),
        build_apply_button(() async {
          if (_tabController!.index == 0) {
            await set_air_speed_min_negative_pressure(minimum_negative_presure_fan_speed);
            Utils.showSnackBar(context, "Done.");
          } else {
            await set_air_speed_max_negative_pressure(maximum_negative_presure_fan_speed);
            Utils.showSnackBar(context, "Done.");
          }
          wait_for_fan_power().then((value) {
            refresh();
          });

          // Utils.setTimeOut(100, IntroductionScreenState.force_next);
        }),
        build_reset_button(),
        SizedBox(
          height: 64,
        )
      ],
    ));
  }
}
