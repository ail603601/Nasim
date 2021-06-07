import 'dart:async';

import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:holding_gesture/holding_gesture.dart';
import 'package:nasim/Model/Device.dart';
import 'package:nasim/Model/menu_info.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/utils.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class InletFanSpeedPage extends StatefulWidget {
  @override
  _InletFanSpeedPageState createState() => _InletFanSpeedPageState();
}

class _InletFanSpeedPageState extends State<InletFanSpeedPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  bool dialog_show = false;
  // late Timer refresher;
  late ConnectionManager cmg;
  bool refresh_disable = false;
  static bool is_minimum_day_set = false;
  static bool is_minimum_night_set = false;
  static bool is_maximum_day_set = false;
  static bool is_maximum_night_set = false;

  double minimum_inlet_fan_speed_day = 0;
  double maximum_inlet_fan_speed_day = 0;
  double minimum_inlet_fan_speed_night = 0;
  double maximum_inlet_fan_speed_night = 0;

  UniqueKey? key_min_day = new UniqueKey();
  static bool expanded_min_day = true;

  UniqueKey? key_min_night = new UniqueKey();
  static bool expanded_min_night = false;

  UniqueKey? key_max_day = new UniqueKey();
  static bool expanded_max_day = true;

  UniqueKey? key_max_night = new UniqueKey();
  static bool expanded_max_night = false;

  static bool is_inlet_fan_available = false;

  toggle_min_day() {
    setState(() {
      key_min_day = new UniqueKey();
      expanded_min_day = !expanded_min_day;
    });
  }

  toggle_min_night() {
    setState(() {
      key_min_night = new UniqueKey();
      expanded_min_night = !expanded_min_night;
    });
  }

  toggle_max_day() {
    setState(() {
      key_max_day = new UniqueKey();
      expanded_max_day = !expanded_max_day;
    });
  }

  toggle_max_night() {
    setState(() {
      key_max_night = new UniqueKey();
      expanded_max_night = !expanded_max_night;
    });
  }

  refresh() async {
    await Utils.show_loading_timed(
        context: context,
        done: () async {
          ConnectionManager.Min_Valid_Input_Fan_Speed_Night = await cmg.getRequest("get42");
          ConnectionManager.Max_Valid_Input_Fan_Speed_Night = await cmg.getRequest("get44");
          ConnectionManager.Min_Valid_Input_Fan_Speed_Day = await cmg.getRequest("get41");
          ConnectionManager.Max_Valid_Input_Fan_Speed_Day = await cmg.getRequest("get43");
          ConnectionManager.Input_Fan_Power = await cmg.getRequest("get45");

          ConnectionManager.Elevation = (int.tryParse(await cmg.getRequest("get34")) ?? ConnectionManager.Elevation).toString();
          ConnectionManager.Pressure = (int.tryParse(await cmg.getRequest("get35")) ?? ConnectionManager.Pressure).toString();

          if (mounted) {
            setState(() {
              minimum_inlet_fan_speed_night = double.tryParse(ConnectionManager.Min_Valid_Input_Fan_Speed_Night) ?? minimum_inlet_fan_speed_night;
              maximum_inlet_fan_speed_night = double.tryParse(ConnectionManager.Max_Valid_Input_Fan_Speed_Night) ?? maximum_inlet_fan_speed_night;
              minimum_inlet_fan_speed_day = double.tryParse(ConnectionManager.Min_Valid_Input_Fan_Speed_Day) ?? minimum_inlet_fan_speed_day;
              maximum_inlet_fan_speed_day = double.tryParse(ConnectionManager.Max_Valid_Input_Fan_Speed_Day) ?? maximum_inlet_fan_speed_day;
            });
          }
        });
  }

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: tabs.length);

    cmg = Provider.of<ConnectionManager>(context, listen: false);

    if (is_inlet_fan_available) {
      Utils.setTimeOut(0, refresh);
    }
  }

  @override
  void dispose() {
    _tabController!.dispose();

    // refresher.cancel();

    super.dispose();
  }

  showAlertDialog(BuildContext context) async {
    // final prefs = await SharedPreferences.getInstance();

    // set value
    // is_inlet_fan_available = false;
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Yes", style: Theme.of(context).textTheme.bodyText1),
      onPressed: () {
        Navigator.of(context).pop(false);
        setState(() async {
          is_inlet_fan_available = true;

          Utils.setTimeOut(0, refresh);
        });
      },
    );
    Widget continueButton = FlatButton(
      child: Text("No", style: Theme.of(context).textTheme.bodyText1),
      onPressed: () {
        Navigator.of(context).pop(false);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Alert", style: Theme.of(context).textTheme.headline6),
      content: Text("is inlet fan available for your device ?", style: Theme.of(context).textTheme.bodyText1),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  // var scanArea = (MediaQuery.of(context).size.width < 400 || MediaQuery.of(context).size.height < 400) ? 150.0 : 300.0;

  Widget build_boxed_titlebox({required title, required child}) {
    // debugger();
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new InputDecorator(
            decoration: InputDecoration(
                labelText: title, labelStyle: Theme.of(context).textTheme.bodyText1, border: OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow))),
            child: child));
  }

  Future<bool> set_all_to_board_min() async {
    if (!expanded_min_day) {
      toggle_min_day();
      return false;
    } else {
      is_minimum_day_set = true;
      if (!await cmg.set_request(41, ConnectionManager.Min_Valid_Input_Fan_Speed_Day)) {
        return false;
      }
      if (!(int.parse(ConnectionManager.Max_Valid_Input_Fan_Speed_Day) >= int.parse(ConnectionManager.Min_Valid_Input_Fan_Speed_Day) + 5)) {
        ConnectionManager.Max_Valid_Input_Fan_Speed_Day = (int.parse(ConnectionManager.Min_Valid_Input_Fan_Speed_Day) + 5).toString().padLeft(3, '0');
        if (!await cmg.set_request(43, ConnectionManager.Max_Valid_Input_Fan_Speed_Day)) {
          return false;
        }
      }
    }
    if (!expanded_min_night) {
      toggle_min_night();
      return false;
    } else {
      is_minimum_night_set = true;
      if (!await cmg.set_request(42, ConnectionManager.Min_Valid_Input_Fan_Speed_Night)) {
        return false;
      }
      if (!(int.parse(ConnectionManager.Max_Valid_Input_Fan_Speed_Night) >= int.parse(ConnectionManager.Min_Valid_Input_Fan_Speed_Night) + 5)) {
        ConnectionManager.Max_Valid_Input_Fan_Speed_Night = (int.parse(ConnectionManager.Min_Valid_Input_Fan_Speed_Night) + 5).toString().padLeft(3, '0');

        if (!await cmg.set_request(44, ConnectionManager.Max_Valid_Input_Fan_Speed_Night)) {
          return false;
        }
      }
    }

    return true;
  }

  Future<bool> set_all_to_board_max() async {
    if (!expanded_max_day) {
      toggle_max_day();
      return false;
    } else {
      is_maximum_day_set = true;
      if (!(int.parse(ConnectionManager.Max_Valid_Input_Fan_Speed_Day) >= int.parse(ConnectionManager.Min_Valid_Input_Fan_Speed_Day) + 5)) {
        await Utils.alert(context, "", "Day time maximum fan speed must at least be 5 more than minimum.");
        return false;
      }

      if (!await cmg.set_request(43, ConnectionManager.Max_Valid_Input_Fan_Speed_Day)) {
        return false;
      }
    }
    if (!expanded_max_night) {
      toggle_max_night();
      return false;
    } else {
      if (!(int.parse(ConnectionManager.Max_Valid_Input_Fan_Speed_Night) >= int.parse(ConnectionManager.Min_Valid_Input_Fan_Speed_Night) + 5)) {
        await Utils.alert(context, "", "Night time maximum fan speed must at least be 5 more than minimum.");
        return false;
      }
      is_maximum_night_set = true;
      if (!await cmg.set_request(44, ConnectionManager.Max_Valid_Input_Fan_Speed_Night)) {
        return false;
      }
    }
    return true;
  }

  Future<bool> inc_min_inlet_fan(bool is_night) async {
    if (is_night) {
      double value = double.parse(ConnectionManager.Min_Valid_Input_Fan_Speed_Night) + 1;
      value = min(value, 95);
      ConnectionManager.Min_Valid_Input_Fan_Speed_Night = value.toInt().toString().padLeft(3, '0');
      setState(() {
        minimum_inlet_fan_speed_night = value;
      });
    } else {
      double value = double.parse(ConnectionManager.Min_Valid_Input_Fan_Speed_Day) + 1;
      value = min(value, 95);
      ConnectionManager.Min_Valid_Input_Fan_Speed_Day = value.toInt().toString().padLeft(3, '0');

      setState(() {
        minimum_inlet_fan_speed_day = value;
      });
    }
    return true;
  }

  Future<bool> inc_max_inlet_fan(bool is_night) async {
    if (is_night) {
      double value = double.parse(ConnectionManager.Max_Valid_Input_Fan_Speed_Night) + 1;
      value = min(value, 100);
      ConnectionManager.Max_Valid_Input_Fan_Speed_Night = value.toInt().toString().padLeft(3, '0');
      setState(() {
        maximum_inlet_fan_speed_night = value;
      });
    } else {
      double value = double.parse(ConnectionManager.Max_Valid_Input_Fan_Speed_Day) + 1;
      value = min(value, 100);
      ConnectionManager.Max_Valid_Input_Fan_Speed_Day = value.toInt().toString().padLeft(3, '0');
      setState(() {
        maximum_inlet_fan_speed_day = value;
      });
    }
    return true;
  }

  Future<bool> dec_min_inlet_fan(bool is_night) async {
    if (is_night) {
      double value = double.parse(ConnectionManager.Min_Valid_Input_Fan_Speed_Night) - 1;
      value = max(value, 0);
      ConnectionManager.Min_Valid_Input_Fan_Speed_Night = value.toInt().toString().padLeft(3, '0');
      setState(() {
        minimum_inlet_fan_speed_night = value;
      });
    } else {
      double value = double.parse(ConnectionManager.Min_Valid_Input_Fan_Speed_Day) - 1;
      value = max(value, 0);
      ConnectionManager.Min_Valid_Input_Fan_Speed_Day = value.toInt().toString().padLeft(3, '0');
      setState(() {
        minimum_inlet_fan_speed_day = value;
      });
    }
    return true;
  }

  Future<bool> dec_max_inlet_fan(bool is_night) async {
    if (is_night) {
      double value = double.parse(ConnectionManager.Max_Valid_Input_Fan_Speed_Night) - 1;
      value = max(value, 0);
      ConnectionManager.Max_Valid_Input_Fan_Speed_Night = value.toInt().toString().padLeft(3, '0');
      setState(() {
        maximum_inlet_fan_speed_night = value;
      });
    } else {
      double value = double.parse(ConnectionManager.Max_Valid_Input_Fan_Speed_Day) - 1;
      value = max(value, 0);
      ConnectionManager.Max_Valid_Input_Fan_Speed_Day = value.toInt().toString().padLeft(3, '0');
      setState(() {
        maximum_inlet_fan_speed_day = value;
      });
    }
    return true;
  }

  Widget build_fan_speed_row(String title, double value, Function() up_fun, Function() down_fun, {bool is_max95 = false}) => build_boxed_titlebox(
        title: title,
        child: Column(children: [
          Row(
            children: [
              Text("Inlet Fan Speed: ", style: Theme.of(context).textTheme.bodyText1),
              Text(value.toString() + " %", style: Theme.of(context).textTheme.bodyText1),
              Expanded(
                child: CupertinoSlider(
                  value: value,
                  min: 0.0,
                  max: is_max95 ? 95.0 : 100.0,
                  divisions: 100,
                  onChangeEnd: (double newValue) async {},
                  onChanged: (double newValue) {},
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Text("Inlet Fan Power: ", style: Theme.of(context).textTheme.bodyText1)),
              Expanded(
                  child: Center(
                      child: Text((int.tryParse(ConnectionManager.Input_Fan_Power) ?? 0).toString() + " W", style: Theme.of(context).textTheme.bodyText1)))
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
                    onHold: () {
                      up_fun();
                      up_fun();
                    },
                    holdTimeout: Duration(milliseconds: 1000),
                    // enableHapticFeedback: true,
                    child: IconButton(icon: Icon(Icons.keyboard_arrow_up), iconSize: 50, color: Colors.white, onPressed: up_fun),
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
                    onHold: () {
                      down_fun();
                      down_fun();
                    },
                    holdTimeout: Duration(milliseconds: 1000),
                    // enableHapticFeedback: true,
                    child: IconButton(icon: Icon(Icons.keyboard_arrow_down), iconSize: 50, color: Colors.white, onPressed: down_fun),
                  ),
                ),
              ),
            ),
            // RaisedButton.icon(onPressed: null, icon: null, label: null),
          ])
        ]),
      );

  void start() async {
    // final prefs = await SharedPreferences.getInstance();

    // set value
    // is_inlet_fan_available = prefs.getBool('is_inlet_fan_available') ?? false;
    is_inlet_fan_available = await Provider.of<ConnectionManager>(context, listen: false).getRequest("get122") == "1";

    if (!is_inlet_fan_available) {
      Future.delayed(Duration.zero, () => showAlertDialog(context));
    }
    setState(() {});
    // !is_inlet_fan_available && showAlertDialog(context);
  }

  bool is_night = true;
  // build_day_night_switch() => Container(
  //       color: Color(0xff181818),
  //       child: Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //         child: Row(children: [
  //           Expanded(child: Text("Settings for ${is_night ? "Night" : "Day"} Time ", style: Theme.of(context).textTheme.headline6)),
  //           DayNightSwitcher(
  //             isDarkModeEnabled: is_night,
  //             onStateChanged: (is_night) {
  //               setState(() {
  //                 this.is_night = is_night;
  //                 refresh();
  //               });
  //             },
  //           )
  //         ]),
  //       ),
  //     );
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
              cmg.set_request(42, "000");
              cmg.set_request(44, "000");
              cmg.set_request(41, "000");
              cmg.set_request(43, "000");

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
    if (!dialog_show) {
      dialog_show = true;
      start();
    }
    return is_inlet_fan_available
        ? Scaffold(
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
                    Expanded(child: Text("Inlet Fan Speed", style: Theme.of(context).textTheme.bodyText1)),
                  ],
                ),
              ),
              build_elevation_presure(),
              Expanded(
                child: new TabBarView(controller: _tabController, physics: NeverScrollableScrollPhysics(), children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        ExpansionTile(
                            key: key_min_day,
                            initiallyExpanded: expanded_min_day,
                            tilePadding: EdgeInsets.only(right: 16),
                            title: ListTile(
                              onTap: toggle_min_day,
                              title: Text("Day Time", style: Theme.of(context).textTheme.bodyText1!),
                              leading: DayNightSwitcherIcon(
                                isDarkModeEnabled: false,
                                onStateChanged: (isDarkModeEnabled) {
                                  setState(() {});
                                },
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: build_fan_speed_row("Minimum", minimum_inlet_fan_speed_day, () {
                                  inc_min_inlet_fan(false);
                                }, () {
                                  dec_min_inlet_fan(false);
                                }, is_max95: true),
                              ),
                            ]),
                        Divider(
                          height: 0,
                        ),
                        ExpansionTile(
                            key: key_min_night,
                            initiallyExpanded: expanded_min_night,
                            tilePadding: EdgeInsets.only(right: 16),
                            title: ListTile(
                              onTap: toggle_min_night,
                              title: Text("Night Time", style: Theme.of(context).textTheme.bodyText1!),
                              leading: DayNightSwitcherIcon(
                                isDarkModeEnabled: true,
                                onStateChanged: (isDarkModeEnabled) {
                                  setState(() {});
                                },
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: build_fan_speed_row("Minimum", minimum_inlet_fan_speed_night, () {
                                  inc_min_inlet_fan(true);
                                }, () {
                                  dec_min_inlet_fan(true);
                                }, is_max95: true),
                              ),
                            ]),
                      ],
                    ),
                  ),
                  if (!is_minimum_day_set || !is_minimum_night_set)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Align(
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
                            child: Container(
                                child: Text("Please set minimum fan speed before changing maximum fan speed.", style: Theme.of(context).textTheme.headline6))),
                      ),
                    )
                  else
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          ExpansionTile(
                              key: key_max_day,
                              initiallyExpanded: expanded_max_day,
                              tilePadding: EdgeInsets.only(right: 16),
                              title: ListTile(
                                onTap: toggle_max_day,
                                title: Text("Day Time", style: Theme.of(context).textTheme.bodyText1!),
                                leading: DayNightSwitcherIcon(
                                  isDarkModeEnabled: false,
                                  onStateChanged: (isDarkModeEnabled) {
                                    setState(() {});
                                  },
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: build_fan_speed_row("Maximum", maximum_inlet_fan_speed_day, () {
                                    inc_max_inlet_fan(false);
                                  }, () {
                                    dec_max_inlet_fan(false);
                                  }),
                                ),
                              ]),
                          Divider(
                            height: 0,
                          ),
                          ExpansionTile(
                              key: key_max_night,
                              initiallyExpanded: expanded_max_night,
                              tilePadding: EdgeInsets.only(right: 16),
                              title: ListTile(
                                onTap: toggle_max_night,
                                title: Text("Night Time", style: Theme.of(context).textTheme.bodyText1!),
                                leading: DayNightSwitcherIcon(
                                  isDarkModeEnabled: true,
                                  onStateChanged: (isDarkModeEnabled) {
                                    setState(() {});
                                  },
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: build_fan_speed_row("Maximum", maximum_inlet_fan_speed_night, () {
                                    inc_max_inlet_fan(true);
                                  }, () {
                                    dec_max_inlet_fan(true);
                                  }),
                                ),
                              ]),
                        ],
                      ),
                    )
                ]),
              ),
              build_apply_button(() async {
                await Provider.of<ConnectionManager>(context, listen: false).set_request(122, "1");
                if (_tabController!.index == 0) {
                  await set_all_to_board_min();
                  await refresh();
                  return;
                } else {
                  await set_all_to_board_max();
                  await refresh();
                  return;
                }

                // await refresh();

                // IntroductionScreenState.force_next();
              }),
              build_reset_button(),
              SizedBox(
                height: 64,
              )
            ],
          ))
        : Container(
            color: Theme.of(context).canvasColor,
            alignment: Alignment.center,
            child: Text("Inlet Fan is not available for this device."),
          );
  }
}
