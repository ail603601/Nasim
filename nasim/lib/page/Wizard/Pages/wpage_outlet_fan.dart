import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/provider/LicenseChangeNotifier.dart';
import 'package:nasim/utils.dart';
import 'package:provider/provider.dart';

import '../Wizardpage.dart';

class wpage_outlet_fan extends StatefulWidget {
  @override
  _wpage_outlet_fanState createState() => _wpage_outlet_fanState();
}

class _wpage_outlet_fanState extends State<wpage_outlet_fan> {
  late Timer refresher;
  bool refresh_disable = false;
  late ConnectionManager cmg;
  late double minimum_negative_presure_fan_speed;
  late double maximum_negative_presure_fan_speed;

  refresh() async {
    if (refresh_disable) {
      return;
    }
    ConnectionManager.Min_Valid_Output_Fan_Speed = await cmg.getRequest("get37");
    ConnectionManager.Real_Output_Fan_Speed = await cmg.getRequest("get96");
    ConnectionManager.Pressure_change = await cmg.getRequest("get36");
    ConnectionManager.Max_Valid_Output_Fan_Speed = await cmg.getRequest("get38");

    ConnectionManager.Elevation = await cmg.getRequest("get34");
    ConnectionManager.Pressure = await cmg.getRequest("get35");
    if (mounted)
      setState(() {
        minimum_negative_presure_fan_speed = (int.tryParse(ConnectionManager.Min_Valid_Output_Fan_Speed) ?? minimum_negative_presure_fan_speed).toDouble();
        maximum_negative_presure_fan_speed = (int.tryParse(ConnectionManager.Max_Valid_Output_Fan_Speed) ?? maximum_negative_presure_fan_speed).toDouble();
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
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
    if ((maximum_negative_presure_fan_speed - value) < 5) {
      await Utils.alert(context, "Error", "maximum negative fan presue must at least be 5 more than minimum.");
      await refresh();
      return false;
    }

    ConnectionManager.Min_Valid_Output_Fan_Speed = value.toInt().toString().padLeft(3, '0');
    if (!await cmg.set_request(37, ConnectionManager.Min_Valid_Output_Fan_Speed)) {
      await refresh();
      Utils.handleError(context);

      return false;
    }
    return true;
  }

  Future<bool> set_air_speed_max_negative_pressure(double value) async {
    if ((value - minimum_negative_presure_fan_speed) < 5) {
      await Utils.alert(context, "Error", "maximum negative fan presue must at least be 5 more than minimum.");
      await refresh();
      return false;
    }

    ConnectionManager.Max_Valid_Output_Fan_Speed = value.toInt().toString().padLeft(3, '0');
    if (!await cmg.set_request(38, ConnectionManager.Max_Valid_Output_Fan_Speed)) {
      await refresh();
      Utils.handleError(context);

      return false;
    }
    return true;
  }

  Widget build_air_speed_min_negative_pressure() {
    return build_boxed_titlebox(
      title: "Minimum Negative Presure",
      child: Column(children: [
        Row(
          children: [
            Text("Outlet Fan Speed: ", style: Theme.of(context).textTheme.bodyText1),
            Text(minimum_negative_presure_fan_speed.toString() + " %", style: Theme.of(context).textTheme.bodyText1),
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
            refresh_disable = false;

            if (await set_air_speed_min_negative_pressure(newValue.round().toDouble())) {
              minimum_negative_presure_fan_speed = newValue.round().toDouble();
            }
          },
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Text("Outlet Fan Power: ", style: Theme.of(context).textTheme.bodyText1)),
            Expanded(
                child: Center(
                    child: Text((int.tryParse(ConnectionManager.Real_Output_Fan_Speed) ?? 0).toString() + " W", style: Theme.of(context).textTheme.bodyText1)))
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
                  if (await set_air_speed_min_negative_pressure(min(minimum_negative_presure_fan_speed.roundToDouble() + 1.0, 100))) {
                    setState(() {
                      minimum_negative_presure_fan_speed = min(minimum_negative_presure_fan_speed.roundToDouble() + 1.0, 100);
                    });
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
                  if (await set_air_speed_min_negative_pressure(max(minimum_negative_presure_fan_speed.roundToDouble() - 1.0, 0))) {
                    setState(() {
                      minimum_negative_presure_fan_speed = max(minimum_negative_presure_fan_speed.roundToDouble() - 1.0, 0);
                    });
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

  Widget build_air_speed_max_negative_pressure() {
    return build_boxed_titlebox(
      title: "Maximum Negative Presure",
      child: Column(children: [
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
          onChanged: (double newValue) {
            refresh_disable = true;

            setState(() {
              maximum_negative_presure_fan_speed = newValue.round().toDouble();
            });
          },
          onChangeEnd: (double newValue) async {
            refresh_disable = false;
            if (await set_air_speed_max_negative_pressure(newValue.round().toDouble())) {
              maximum_negative_presure_fan_speed = newValue.round().toDouble();
            }
          },
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Text("Outlet Fan Power: ", style: Theme.of(context).textTheme.bodyText1)),
            Expanded(
                child: Center(
                    child: Text((int.tryParse(ConnectionManager.Real_Output_Fan_Speed) ?? 0).toString() + " W", style: Theme.of(context).textTheme.bodyText1)))
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
                  if (await set_air_speed_max_negative_pressure(min(maximum_negative_presure_fan_speed.roundToDouble() + 1.0, 100))) {
                    setState(() {
                      maximum_negative_presure_fan_speed = min(maximum_negative_presure_fan_speed.roundToDouble() + 1.0, 100);
                    });
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
                  if (await set_air_speed_max_negative_pressure(max(maximum_negative_presure_fan_speed.roundToDouble() - 1.0, 0))) {
                    setState(() {
                      maximum_negative_presure_fan_speed = max(maximum_negative_presure_fan_speed.roundToDouble() - 1.0, 0);
                    });
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
            onPressed: () async {
              cmg.set_request(37, "000");
              cmg.set_request(38, "000");

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
  @override
  void initState() {
    super.initState();

    cmg = Provider.of<ConnectionManager>(context, listen: false);
    refresher = Timer.periodic(new Duration(milliseconds: 500), (timer) {
      refresh();
    });
    minimum_negative_presure_fan_speed = (int.tryParse(ConnectionManager.Min_Valid_Output_Fan_Speed) ?? 0.0).toDouble();
    maximum_negative_presure_fan_speed = (int.tryParse(ConnectionManager.Max_Valid_Output_Fan_Speed) ?? 0.0).toDouble();
    refresh();
  }

  @override
  void dispose() {
    refresher.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(bottom: 64),
        color: Theme.of(context).canvasColor,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ...make_title("Air Speed"),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  build_elevation_presure(),
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
