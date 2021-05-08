import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  AnimationController? _controller;
  int interval = 200;

  bool refresh_disable = false;
  refresh() async {
    if (refresh_disable) {
      return;
    }
    ConnectionManager.Min_Valid_Output_Fan_Speed = await cmg.getRequest("get13");
    ConnectionManager.Real_Output_Fan_Speed = await cmg.getRequest("get63");
    ConnectionManager.Pressure_change = await cmg.getRequest("get12");
    ConnectionManager.Max_Valid_Output_Fan_Speed = await cmg.getRequest("get14");

    setState(() {
      minimum_negative_presure_fan_speed = (int.tryParse(ConnectionManager.Min_Valid_Output_Fan_Speed) ?? minimum_negative_presure_fan_speed).toDouble();
      maximum_negative_presure_fan_speed = (int.tryParse(ConnectionManager.Max_Valid_Output_Fan_Speed) ?? maximum_negative_presure_fan_speed).toDouble();
    });
    // if (mounted) Utils.setTimeOut(interval, refresh);
  }

  late ConnectionManager cmg;
  @override
  void initState() {
    super.initState();
    // Utils.setTimeOut(interval, refresh);

    _controller = AnimationController(vsync: this, duration: Duration(seconds: 2))..repeat();
    cmg = Provider.of<ConnectionManager>(context, listen: false);

    minimum_negative_presure_fan_speed = (int.tryParse(ConnectionManager.Min_Valid_Output_Fan_Speed) ?? 0.0).toDouble();
    maximum_negative_presure_fan_speed = (int.tryParse(ConnectionManager.Max_Valid_Output_Fan_Speed) ?? 0.0).toDouble();
    refresh();
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

  late double minimum_negative_presure_fan_speed;
  Widget build_air_speed_min_negative_pressure() {
    return build_boxed_titlebox(
      title: "Minimum Negative Presure",
      child: Column(children: [
        Row(
          children: [
            Text("Outlet Fan Speed: ", style: Theme.of(context).textTheme.bodyText2),
            Text(minimum_negative_presure_fan_speed.toString()),
          ],
        ),
        CupertinoSlider(
          value: minimum_negative_presure_fan_speed,
          min: 0.0,
          max: 100.0,
          divisions: 100,
          onChanged: (double newValue) {
            refresh_disable = true;

            setState(() {
              minimum_negative_presure_fan_speed = newValue.round().toDouble();
            });
          },
          onChangeEnd: (double newValue) async {
            // if((newValue.round().toDouble()))

            minimum_negative_presure_fan_speed = newValue.round().toDouble();
            ConnectionManager.Min_Valid_Output_Fan_Speed = newValue.toInt().toString().padLeft(3, '0');
            if (!await cmg.set_request(13, ConnectionManager.Min_Valid_Output_Fan_Speed)) {
              Utils.handleError(context);
            }
            refresh_disable = false;
          },
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Text("Outlet Fan Power: "),
            Expanded(child: Center(child: Text((int.tryParse(ConnectionManager.Real_Output_Fan_Speed) ?? 0).toString() + " W")))
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Text("Pressure Change: "),
            Expanded(child: Center(child: Text((int.tryParse(ConnectionManager.Pressure_change) ?? 0).toString() + "hpa")))
          ],
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
                onPressed: () async {
                  minimum_negative_presure_fan_speed = min(minimum_negative_presure_fan_speed.roundToDouble() + 1.0, 100);
                  ConnectionManager.Min_Valid_Output_Fan_Speed = minimum_negative_presure_fan_speed.toInt().toString().padLeft(3, '0');
                  setState(() {});

                  if (!await cmg.set_request(13, ConnectionManager.Min_Valid_Output_Fan_Speed)) {
                    Utils.handleError(context);
                    refresh();
                  }
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
                onPressed: () async {
                  minimum_negative_presure_fan_speed = max(minimum_negative_presure_fan_speed.roundToDouble() - 1.0, 0);
                  ConnectionManager.Min_Valid_Output_Fan_Speed = minimum_negative_presure_fan_speed.toInt().toString().padLeft(3, '0');
                  setState(() {});

                  if (!await cmg.set_request(13, ConnectionManager.Min_Valid_Output_Fan_Speed)) {
                    Utils.handleError(context);
                    refresh();
                  }
                },
              ),
            ),
          ),
          // RaisedButton.icon(onPressed: null, icon: null, label: null),
        ])
      ]),
    );
  }

  late double maximum_negative_presure_fan_speed;

  Widget build_air_speed_max_negative_pressure() {
    return build_boxed_titlebox(
      title: "Maximum Negative Presure",
      child: Column(children: [
        Row(
          children: [
            Text("Outlet Fan Speed: ", style: Theme.of(context).textTheme.bodyText2),
            Text(maximum_negative_presure_fan_speed.toString()),
          ],
        ),
        CupertinoSlider(
          value: maximum_negative_presure_fan_speed,
          min: 0.0,
          max: 100.0,
          divisions: 100,
          onChanged: (double newValue) {
            refresh_disable = true;

            setState(() {
              maximum_negative_presure_fan_speed = newValue.round().toDouble();
            });
          },
          onChangeEnd: (double newValue) async {
            maximum_negative_presure_fan_speed = newValue.round().toDouble();
            ConnectionManager.Max_Valid_Output_Fan_Speed = newValue.toInt().toString().padLeft(3, '0');
            if (!await cmg.set_request(14, ConnectionManager.Max_Valid_Output_Fan_Speed)) {
              Utils.handleError(context);
            }
            refresh_disable = false;
          },
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Text("Outlet Fan Power: "),
            Expanded(child: Center(child: Text((int.tryParse(ConnectionManager.Real_Output_Fan_Speed) ?? 0).toString() + " W")))
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Text("Pressure Change: "),
            Expanded(child: Center(child: Text((int.tryParse(ConnectionManager.Pressure_change) ?? 0).toString() + "hpa")))
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
                onPressed: () async {
                  maximum_negative_presure_fan_speed = min(maximum_negative_presure_fan_speed.roundToDouble() + 1.0, 100);
                  ConnectionManager.Max_Valid_Output_Fan_Speed = maximum_negative_presure_fan_speed.toInt().toString().padLeft(3, '0');
                  setState(() {});

                  if (!await cmg.set_request(14, ConnectionManager.Max_Valid_Output_Fan_Speed)) {
                    Utils.handleError(context);
                    refresh();
                  }
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
                onPressed: () async {
                  maximum_negative_presure_fan_speed = max(maximum_negative_presure_fan_speed.roundToDouble() - 1.0, 0);
                  ConnectionManager.Max_Valid_Output_Fan_Speed = maximum_negative_presure_fan_speed.toInt().toString().padLeft(3, '0');
                  setState(() {});

                  if (!await cmg.set_request(14, ConnectionManager.Max_Valid_Output_Fan_Speed)) {
                    Utils.handleError(context);
                    refresh();
                  }
                },
              ),
            ),
          ),
          // RaisedButton.icon(onPressed: null, icon: null, label: null),
        ])
      ]),
    );
  }

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
    return Container(
        color: Theme.of(context).canvasColor,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          build_air_speed_animated_card(context),
          ...make_title("Air Speed"),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  build_air_speed_min_negative_pressure(),
                  SizedBox(
                    height: 16,
                  ),
                  build_air_speed_max_negative_pressure(),
                ],
              ),
            ),
          ),
          build_reset_button()
        ]));
  }
}
