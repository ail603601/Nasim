import 'dart:developer';

import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nasim/Model/Device.dart';
import 'package:nasim/Model/menu_info.dart';
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

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 2))..repeat();

    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();

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

  double minimum_inlet_fan_speed = 0.0;
  Widget build_minimum_inlet_fan_speed() => build_boxed_titlebox(
        title: "Mimimum",
        child: Column(children: [
          Row(
            children: [
              Text("Outlet Fan Speed: ", style: Theme.of(context).textTheme.bodyText2),
              Text(minimum_inlet_fan_speed.toString()),
              Expanded(
                child: CupertinoSlider(
                  value: minimum_inlet_fan_speed,
                  min: 0.0,
                  max: 20.0,
                  // divisions: 10,
                  onChanged: (double newValue) {
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
            children: [Text("Inlet Fan Power: "), Expanded(child: Center(child: Text("50 W")))],
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
                    setState(() {});
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
                    setState(() {});
                  },
                ),
              ),
            ),
            // RaisedButton.icon(onPressed: null, icon: null, label: null),
          ])
        ]),
      );

  double maximum_inlet_fan_speed = 0.0;
  Widget build_maximum_inlet_fan_speed() => build_boxed_titlebox(
        title: "Maximum",
        child: Column(children: [
          Row(
            children: [
              Text("Outlet Fan Speed: ", style: Theme.of(context).textTheme.bodyText2),
              Text(maximum_inlet_fan_speed.toString()),
              Expanded(
                child: CupertinoSlider(
                  value: maximum_inlet_fan_speed,
                  min: 0.0,
                  max: 20.0,
                  // divisions: 10,
                  onChanged: (double newValue) {
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
            children: [Text("Inlet Fan Power: "), Expanded(child: Center(child: Text("50 W")))],
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
                    setState(() {});
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
                    setState(() {});
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

  build_reset_button() => Expanded(
        child: Align(
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
              build_day_night_switch(),
              build_minimum_inlet_fan_speed(),
              SizedBox(
                height: 18,
              ),
              build_maximum_inlet_fan_speed(),
              SizedBox(
                height: 18,
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
