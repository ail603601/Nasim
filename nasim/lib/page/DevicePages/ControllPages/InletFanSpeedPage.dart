import 'dart:async';
import 'dart:developer';

import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nasim/Model/Device.dart';
import 'package:nasim/Model/menu_info.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class InletFanSpeedPage extends StatefulWidget {
  @override
  _InletFanSpeedPageState createState() => _InletFanSpeedPageState();
}

class _InletFanSpeedPageState extends State<InletFanSpeedPage> with SingleTickerProviderStateMixin {
  bool is_inlet_fan_available = false;
  bool dialog_show = false;

  AnimationController? _controller;
  late Timer refresher;
  late ConnectionManager cmg;
  bool refresh_disable = false;

  refresh() async {
    if (refresh_disable) {
      return;
    }
    ConnectionManager.Min_Valid_Input_Fan_Speed_Night = await cmg.getRequest("get18");
    ConnectionManager.Max_Valid_Input_Fan_Speed_Night = await cmg.getRequest("get20");
    ConnectionManager.Min_Valid_Input_Fan_Speed_Day = await cmg.getRequest("get17");
    ConnectionManager.Max_Valid_Input_Fan_Speed_Day = await cmg.getRequest("get19");
    ConnectionManager.Input_Fan_Power = await cmg.getRequest("get21");

    setState(() {
      if (is_night) {
        minimum_inlet_fan_speed = double.tryParse(ConnectionManager.Min_Valid_Input_Fan_Speed_Night) ?? minimum_inlet_fan_speed;
        maximum_inlet_fan_speed = double.tryParse(ConnectionManager.Max_Valid_Input_Fan_Speed_Night) ?? maximum_inlet_fan_speed;
      } else {
        minimum_inlet_fan_speed = double.tryParse(ConnectionManager.Min_Valid_Input_Fan_Speed_Day) ?? minimum_inlet_fan_speed;
        maximum_inlet_fan_speed = double.tryParse(ConnectionManager.Max_Valid_Input_Fan_Speed_Day) ?? maximum_inlet_fan_speed;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: Duration(seconds: 2))..repeat();

    cmg = Provider.of<ConnectionManager>(context, listen: false);
    refresher = Timer.periodic(new Duration(milliseconds: 500), (timer) {
      refresh();
    });

    if (is_night) {
      minimum_inlet_fan_speed = double.tryParse(ConnectionManager.Min_Valid_Input_Fan_Speed_Night) ?? 0.0;
      maximum_inlet_fan_speed = double.tryParse(ConnectionManager.Max_Valid_Input_Fan_Speed_Night) ?? 0.0;
    } else {
      minimum_inlet_fan_speed = double.tryParse(ConnectionManager.Min_Valid_Input_Fan_Speed_Day) ?? 0.0;
      maximum_inlet_fan_speed = double.tryParse(ConnectionManager.Max_Valid_Input_Fan_Speed_Day) ?? 0.0;
    }
  }

  @override
  void dispose() {
    _controller!.dispose();
    refresher.cancel();

    super.dispose();
  }

  showAlertDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // set value
    is_inlet_fan_available = prefs.getBool('is_inlet_fan_available') ?? false;
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Yes", style: Theme.of(context).textTheme.bodyText2),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop(false);
        setState(() async {
          is_inlet_fan_available = true;
          final prefs = await SharedPreferences.getInstance();

          // set value
          is_inlet_fan_available = await prefs.setBool('is_inlet_fan_available', true);
          setState(() {});
        });
      },
    );
    Widget continueButton = FlatButton(
      child: Text("No", style: Theme.of(context).textTheme.bodyText2),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop(false);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Alert", style: Theme.of(context).textTheme.headline6),
      content: Text("is inlet fan available for your device ?", style: Theme.of(context).textTheme.bodyText2),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
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
                labelText: title, labelStyle: Theme.of(context).textTheme.headline6, border: OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow))),
            child: child));
  }

  Widget build_inlet_fan_speed_animated_card(context) =>
      Container(width: 150, child: FittedBox(child: make_animated_icon("inlet_fan", "assets/fan_vector.png", Colors.blue[400])));

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
  List<Widget> build_title(titile) {
    return [
      Container(
        padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
        alignment: Alignment.centerLeft,
        child: Text(titile),
      ),
      Divider(
        color: Theme.of(context).accentColor,
      )
    ];
  }

  late double minimum_inlet_fan_speed;
  Widget build_minimum_inlet_fan_speed() => build_boxed_titlebox(
        title: "Mimimum",
        child: Column(children: [
          Row(
            children: [
              Text("Inlet Fan Speed: ", style: Theme.of(context).textTheme.bodyText2),
              Text(minimum_inlet_fan_speed.toString()),
              Expanded(
                child: CupertinoSlider(
                  value: minimum_inlet_fan_speed,
                  min: 0.0,
                  max: 100.0,
                  divisions: 100,
                  onChangeEnd: (double newValue) async {
                    if (is_night) {
                      ConnectionManager.Min_Valid_Input_Fan_Speed_Night = newValue.toInt().toString().padLeft(3, '0');
                      if (!await cmg.set_request(18, ConnectionManager.Min_Valid_Input_Fan_Speed_Night)) {
                        Utils.handleError(context);
                      }
                    } else {
                      ConnectionManager.Min_Valid_Input_Fan_Speed_Day = newValue.toInt().toString().padLeft(3, '0');
                      if (!await cmg.set_request(17, ConnectionManager.Min_Valid_Input_Fan_Speed_Day)) {
                        Utils.handleError(context);
                      }
                    }
                    minimum_inlet_fan_speed = newValue.roundToDouble();
                    refresh_disable = false;
                  },
                  onChanged: (double newValue) {
                    refresh_disable = true;

                    setState(() {
                      minimum_inlet_fan_speed = newValue.round().toDouble();
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Text("Outlet Fan Power: "),
              Expanded(child: Center(child: Text((int.tryParse(ConnectionManager.Input_Fan_Power) ?? 0).toString() + " W")))
            ],
          ),
          SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Material(
              clipBehavior: Clip.hardEdge,
              borderRadius: BorderRadius.circular(45.0),
              child: Ink(
                decoration: ShapeDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: CircleBorder(),
                ),
                child: IconButton(
                  icon: Icon(Icons.keyboard_arrow_up),
                  iconSize: 35,
                  color: Colors.white,
                  onPressed: () {
                    setState(() async {
                      minimum_inlet_fan_speed = min(minimum_inlet_fan_speed.roundToDouble() + 1.0, 100);
                      if (is_night) {
                        ConnectionManager.Min_Valid_Input_Fan_Speed_Night = minimum_inlet_fan_speed.toInt().toString().padLeft(3, '0');
                        if (!await cmg.set_request(18, ConnectionManager.Min_Valid_Input_Fan_Speed_Night)) {
                          Utils.handleError(context);
                        }
                      } else {
                        ConnectionManager.Min_Valid_Input_Fan_Speed_Day = minimum_inlet_fan_speed.toInt().toString().padLeft(3, '0');
                        if (!await cmg.set_request(17, ConnectionManager.Min_Valid_Input_Fan_Speed_Day)) {
                          Utils.handleError(context);
                        }
                      }
                    });
                  },
                ),
              ),
            ),
            Material(
              clipBehavior: Clip.hardEdge,
              borderRadius: BorderRadius.circular(45.0),
              child: Ink(
                decoration: ShapeDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: CircleBorder(),
                ),
                child: IconButton(
                  icon: Icon(Icons.keyboard_arrow_down),
                  iconSize: 35,
                  color: Colors.white,
                  onPressed: () {
                    setState(() async {
                      minimum_inlet_fan_speed = max(minimum_inlet_fan_speed.roundToDouble() - 1.0, 0);

                      if (is_night) {
                        ConnectionManager.Min_Valid_Input_Fan_Speed_Night = minimum_inlet_fan_speed.toInt().toString().padLeft(3, '0');
                        if (!await cmg.set_request(18, ConnectionManager.Min_Valid_Input_Fan_Speed_Night)) {
                          Utils.handleError(context);
                        }
                      } else {
                        ConnectionManager.Min_Valid_Input_Fan_Speed_Day = minimum_inlet_fan_speed.toInt().toString().padLeft(3, '0');
                        if (!await cmg.set_request(17, ConnectionManager.Min_Valid_Input_Fan_Speed_Day)) {
                          Utils.handleError(context);
                        }
                      }
                    });
                  },
                ),
              ),
            ),
            // RaisedButton.icon(onPressed: null, icon: null, label: null),
          ])
        ]),
      );

  late double maximum_inlet_fan_speed;
  Widget build_maximum_inlet_fan_speed() => build_boxed_titlebox(
        title: "Maximum",
        child: Column(children: [
          Row(
            children: [
              Text("Inlet Fan Speed: ", style: Theme.of(context).textTheme.bodyText2),
              Text(maximum_inlet_fan_speed.toString()),
              Expanded(
                child: CupertinoSlider(
                  value: maximum_inlet_fan_speed,
                  min: 0.0,
                  max: 100.0,
                  divisions: 100,
                  onChangeEnd: (double newValue) async {
                    if (is_night) {
                      ConnectionManager.Max_Valid_Input_Fan_Speed_Night = newValue.toInt().toString().padLeft(3, '0');
                      if (!await cmg.set_request(20, ConnectionManager.Max_Valid_Input_Fan_Speed_Night)) {
                        Utils.handleError(context);
                      }
                    } else {
                      ConnectionManager.Max_Valid_Input_Fan_Speed_Day = newValue.toInt().toString().padLeft(3, '0');
                      if (!await cmg.set_request(19, ConnectionManager.Max_Valid_Input_Fan_Speed_Day)) {
                        Utils.handleError(context);
                      }
                    }
                    maximum_inlet_fan_speed = newValue.roundToDouble();
                    refresh_disable = false;
                  },
                  onChanged: (double newValue) {
                    refresh_disable = true;

                    setState(() {
                      maximum_inlet_fan_speed = newValue.round().toDouble();
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Text("Outlet Fan Power: "),
              Expanded(child: Center(child: Text((int.tryParse(ConnectionManager.Input_Fan_Power) ?? 0).toString() + " W")))
            ],
          ),
          SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Material(
              clipBehavior: Clip.hardEdge,
              borderRadius: BorderRadius.circular(45.0),
              child: Ink(
                decoration: ShapeDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: CircleBorder(),
                ),
                child: IconButton(
                  icon: Icon(Icons.keyboard_arrow_up),
                  iconSize: 35,
                  color: Colors.white,
                  onPressed: () {
                    setState(() async {
                      maximum_inlet_fan_speed = min(maximum_inlet_fan_speed.roundToDouble() + 1.0, 100);

                      if (is_night) {
                        ConnectionManager.Max_Valid_Input_Fan_Speed_Night = maximum_inlet_fan_speed.toInt().toString().padLeft(3, '0');
                        if (!await cmg.set_request(20, ConnectionManager.Max_Valid_Input_Fan_Speed_Night)) {
                          Utils.handleError(context);
                        }
                      } else {
                        ConnectionManager.Max_Valid_Input_Fan_Speed_Day = maximum_inlet_fan_speed.toInt().toString().padLeft(3, '0');
                        if (!await cmg.set_request(19, ConnectionManager.Max_Valid_Input_Fan_Speed_Day)) {
                          Utils.handleError(context);
                        }
                      }
                    });
                  },
                ),
              ),
            ),
            Material(
              clipBehavior: Clip.hardEdge,
              borderRadius: BorderRadius.circular(45.0),
              child: Ink(
                decoration: ShapeDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: CircleBorder(),
                ),
                child: IconButton(
                  icon: Icon(Icons.keyboard_arrow_down),
                  iconSize: 35,
                  color: Colors.white,
                  onPressed: () {
                    setState(() async {
                      maximum_inlet_fan_speed = min(maximum_inlet_fan_speed.roundToDouble() + 1.0, 100);

                      if (is_night) {
                        ConnectionManager.Max_Valid_Input_Fan_Speed_Night = maximum_inlet_fan_speed.toInt().toString().padLeft(3, '0');
                        if (!await cmg.set_request(19, ConnectionManager.Max_Valid_Input_Fan_Speed_Night)) {
                          Utils.handleError(context);
                        }
                      } else {
                        ConnectionManager.Max_Valid_Input_Fan_Speed_Day = maximum_inlet_fan_speed.toInt().toString().padLeft(3, '0');
                        if (!await cmg.set_request(20, ConnectionManager.Max_Valid_Input_Fan_Speed_Day)) {
                          Utils.handleError(context);
                        }
                      }
                    });
                  },
                ),
              ),
            ),
            // RaisedButton.icon(onPressed: null, icon: null, label: null),
          ])
        ]),
      );

  void start() async {
    final prefs = await SharedPreferences.getInstance();

    // set value
    is_inlet_fan_available = prefs.getBool('is_inlet_fan_available') ?? false;
    if (!is_inlet_fan_available) {
      Future.delayed(Duration.zero, () => showAlertDialog(context));
    }
    setState(() {});
    // !is_inlet_fan_available && showAlertDialog(context);
  }

  bool is_night = true;
  build_day_night_switch() => Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(children: [
            Expanded(child: Text("Settings for ${is_night ? "Night" : "Day"} Time ", style: Theme.of(context).textTheme.headline6)),
            DayNightSwitcher(
              isDarkModeEnabled: is_night,
              onStateChanged: (is_night) {
                setState(() {
                  this.is_night = is_night;
                });
              },
            )
          ]),
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
            onPressed: () {},
            style: OutlinedButton.styleFrom(
                padding: EdgeInsets.only(top: 16, bottom: 16, left: 28, right: 28),
                side: BorderSide(width: 2, color: Theme.of(context).primaryColor),
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(8.0))),
            child: Text("Restore Defaults", style: Theme.of(context).textTheme.headline6),
          ),
        ),
      );
  @override
  Widget build(BuildContext context) {
    if (!dialog_show) {
      dialog_show = true;
      start();
    }
    return is_inlet_fan_available
        ? Container(
            color: Theme.of(context).canvasColor,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              build_inlet_fan_speed_animated_card(context),
              ...build_title("Inlet Fan Speed"),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      build_day_night_switch(),
                      build_minimum_inlet_fan_speed(),
                      SizedBox(
                        height: 18,
                      ),
                      build_maximum_inlet_fan_speed(),
                      SizedBox(
                        height: 18,
                      ),
                    ],
                  ),
                ),
              ),

              build_reset_button(),
              // Divider(
              //   color: Theme.of(context).accentColor,
              // ),
            ]))
        : Container(
            color: Theme.of(context).canvasColor,
            alignment: Alignment.center,
            child: Text("Inlet Fan is not available for this device."),
          );
  }
}
