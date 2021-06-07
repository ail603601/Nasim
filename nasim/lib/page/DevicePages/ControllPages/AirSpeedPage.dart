import 'dart:async';

import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:holding_gesture/holding_gesture.dart';
import 'package:nasim/Model/Device.dart';
import 'package:nasim/Model/menu_info.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:math';

class AirSpeedPage extends StatefulWidget {
  @override
  _AirSpeedPageState createState() => _AirSpeedPageState();
}

class _AirSpeedPageState extends State<AirSpeedPage> with SingleTickerProviderStateMixin {
  // late Timer refresher;
  late ConnectionManager cmg;
  double minimum_negative_presure_fan_speed = 0;
  double maximum_negative_presure_fan_speed = 0;
  int real_output_fan_power = 0;

  refresh() async {
    await Utils.show_loading_timed(
        context: context,
        done: () async {
          ConnectionManager.Min_Valid_Output_Fan_Speed = await cmg.getRequest("get37");
          ConnectionManager.Real_Output_Fan_Power = await cmg.getRequest("get39");
          ConnectionManager.Pressure_change = await cmg.getRequest("get36");
          ConnectionManager.Max_Valid_Output_Fan_Speed = await cmg.getRequest("get38");

          ConnectionManager.Elevation = (int.tryParse(await cmg.getRequest("get34")) ?? ConnectionManager.Elevation).toString();
          ConnectionManager.Pressure = (int.tryParse(await cmg.getRequest("get35")) ?? ConnectionManager.Pressure).toString();

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

  Future<bool> set_air_speed_min_negative_pressure(double value) async {
    ConnectionManager.Min_Valid_Output_Fan_Speed = value.toInt().toString().padLeft(3, '0');
    if (!await cmg.set_request(37, ConnectionManager.Min_Valid_Output_Fan_Speed)) {
      return false;
    }
    if (maximum_negative_presure_fan_speed < value + 5) {
      if (!await set_air_speed_max_negative_pressure(value + 5)) {
        return false;
      }
    }

    return true;
  }

  Future<bool> set_air_speed_max_negative_pressure(double value) async {
    if (minimum_negative_presure_fan_speed + 5 > value) {
      await Utils.alert(context, "Error", "maximum negative fan presue must at least be 5 more than minimum.");
      return false;
    }
    ConnectionManager.Max_Valid_Output_Fan_Speed = value.toInt().toString().padLeft(3, '0');
    if (!await cmg.set_request(38, ConnectionManager.Max_Valid_Output_Fan_Speed)) {
      return false;
    }
    if (value >= minimum_negative_presure_fan_speed + 5) {}
    return true;
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
                cmg.set_request(37, "000");
              } else {
                cmg.set_request(38, "000");
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
  void initState() {
    super.initState();

    cmg = Provider.of<ConnectionManager>(context, listen: false);
    // refresher = Timer.periodic(new Duration(milliseconds: 500), (timer) {
    //   refresh();
    // });
    minimum_negative_presure_fan_speed = (int.tryParse(ConnectionManager.Min_Valid_Output_Fan_Speed) ?? 0.0).toDouble();
    maximum_negative_presure_fan_speed = (int.tryParse(ConnectionManager.Max_Valid_Output_Fan_Speed) ?? 0.0).toDouble();

    _tabController = new TabController(vsync: this, length: tabs.length);

    Utils.setTimeOut(0, refresh);
  }

  @override
  void dispose() {
    _tabController!.dispose();

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
              padding: const EdgeInsets.all(16.0),
              child: build_air_speed_min_negative_pressure(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: build_air_speed_max_negative_pressure(),
            )
          ]),
        ),
        build_apply_button(() async {
          if (_tabController!.index == 0) {
            if (!await set_air_speed_min_negative_pressure(minimum_negative_presure_fan_speed)) {
              await refresh();
              return;
            }
          } else {
            if (!await set_air_speed_max_negative_pressure(maximum_negative_presure_fan_speed)) {
              await refresh();
              return;
            }
          }
          await refresh();
          // Utils.setTimeOut(100, IntroductionScreenState.force_next);
        }),
        build_reset_button(),
      ],
    ));
  }
}
