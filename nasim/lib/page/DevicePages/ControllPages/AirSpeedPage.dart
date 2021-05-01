import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nasim/Model/Device.dart';
import 'package:nasim/Model/menu_info.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:math';

class AirSpeedPage extends StatefulWidget {
  @override
  _AirSpeedPageState createState() => _AirSpeedPageState();
}

class _AirSpeedPageState extends State<AirSpeedPage> with SingleTickerProviderStateMixin {
  AnimationController? _controller;

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

  Widget build_air_speed_animated_card(context) =>
      Container(width: 150, child: FittedBox(child: make_animated_icon("air_speed", "assets/fan_vector.png", Colors.blue[400])));

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
  List<Widget> make_title(titile) {
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

  Widget build_boxed_titlebox({required title, required child}) {
    // debugger();
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new InputDecorator(
            decoration: InputDecoration(
                labelText: title, labelStyle: Theme.of(context).textTheme.headline6, border: OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow))),
            child: child));
  }

  double minimum_negative_presure_fan_speed = 0.0;
  Widget build_air_speed_min_negative_pressure() => build_boxed_titlebox(
        title: "Mimimum Negative Presure",
        child: Column(children: [
          Row(
            children: [
              Text("Outlet Fan Speed: ", style: Theme.of(context).textTheme.bodyText2),
              Text(minimum_negative_presure_fan_speed.toString()),
              Expanded(
                child: CupertinoSlider(
                  value: minimum_negative_presure_fan_speed,
                  min: 0.0,
                  max: 20.0,
                  // divisions: 10,
                  onChanged: (double newValue) {
                    setState(() {
                      minimum_negative_presure_fan_speed = newValue.round().toDouble();
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [Text("Outlet Fan Power: "), Expanded(child: Center(child: Text("50 W")))],
          ),
          SizedBox(height: 16),
          Row(
            children: [Text("Pressure Change: "), Expanded(child: Center(child: Text("-100 hpa")))],
          ),
          SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Material(
              clipBehavior: Clip.hardEdge,
              borderRadius: BorderRadius.circular(45.0),
              child: Ink(
                decoration: const ShapeDecoration(
                  color: Colors.blue,
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
                decoration: const ShapeDecoration(
                  color: Colors.blue,
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
  double maximum_negative_presure_fan_speed = 0.0;

  Widget build_air_speed_max_negative_pressure() => build_boxed_titlebox(
        title: "Maximum Negative Presure",
        child: Column(children: [
          Row(
            children: [
              Text("Outlet Fan Speed: ", style: Theme.of(context).textTheme.bodyText2),
              Text(maximum_negative_presure_fan_speed.toString()),
              Expanded(
                child: CupertinoSlider(
                  value: maximum_negative_presure_fan_speed,
                  min: 0.0,
                  max: 20.0,
                  // divisions: 10,
                  onChanged: (double newValue) {
                    setState(() {
                      maximum_negative_presure_fan_speed = newValue.round().toDouble();
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [Text("Outlet Fan Power: "), Expanded(child: Center(child: Text("50 W")))],
          ),
          SizedBox(height: 16),
          Row(
            children: [Text("Pressure Change: "), Expanded(child: Center(child: Text("-100 hpa")))],
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
    return Container(
        color: Theme.of(context).canvasColor,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          build_air_speed_animated_card(context),
          ...make_title("Air Speed"),
          build_air_speed_min_negative_pressure(),
          SizedBox(
            height: 16,
          ),
          build_air_speed_max_negative_pressure(),
          build_reset_button()
        ]));
  }
}
