import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:provider/provider.dart';

import '../../utils.dart';

class OverviePage extends StatefulWidget {
  @override
  _OverviePageState createState() => _OverviePageState();
}

class _OverviePageState extends State<OverviePage> {
  late ConnectionManager cmg;
  late Timer refresher;
  bool iaq_or_co = false;

  @override
  void initState() {
    super.initState();
    // runs every 1 second
    refresher = Timer.periodic(new Duration(milliseconds: 500), (timer) {
      refresh();
    });
    cmg = Provider.of<ConnectionManager>(context, listen: false);
    refresh();
  }

  refresh() async {
    ConnectionManager.Real_Room_Temp_0 = Utils.int_str(await cmg.getRequest("get79"), ConnectionManager.Real_Room_Temp_0);
    ConnectionManager.Real_Outdoor_Temp = Utils.int_str(await cmg.getRequest("get89"), ConnectionManager.Real_Outdoor_Temp);
    ConnectionManager.Real_Negative_Pressure_ = Utils.int_str(await cmg.getRequest("get90"), ConnectionManager.Real_Negative_Pressure_);
    ConnectionManager.Real_Humidity = Utils.int_str(await cmg.getRequest("get91"), ConnectionManager.Real_Humidity);
    ConnectionManager.Real_IAQ = Utils.int_str(await cmg.getRequest("get92"), ConnectionManager.Real_IAQ);
    ConnectionManager.Real_CO2 = Utils.int_str(await cmg.getRequest("get93"), ConnectionManager.Real_CO2);
    ConnectionManager.Real_Light_Level = Utils.int_str(await cmg.getRequest("get94"), ConnectionManager.Real_Light_Level);
    ConnectionManager.Real_Input_Fan_Speed = Utils.int_str(await cmg.getRequest("get95"), ConnectionManager.Real_Input_Fan_Speed);
    ConnectionManager.Input_Fan_Power = Utils.int_str(await cmg.getRequest("get45"), ConnectionManager.Input_Fan_Power);
    ConnectionManager.Real_Output_Fan_Speed = Utils.int_str(await cmg.getRequest("get96"), ConnectionManager.Real_Output_Fan_Speed);
    ConnectionManager.Real_Output_Fan_Power = Utils.int_str(await cmg.getRequest("get39"), ConnectionManager.Real_Output_Fan_Power);
    ConnectionManager.Cooler_Status = Utils.int_str(await cmg.getRequest("get97"), ConnectionManager.Cooler_Status) == "1" ? "on" : "off";
    ConnectionManager.Heater_Status = Utils.int_str(await cmg.getRequest("get98"), ConnectionManager.Heater_Status) == "1" ? "on" : "off";
    ConnectionManager.Air_Purifier_Status = Utils.int_str(await cmg.getRequest("get99"), ConnectionManager.Air_Purifier_Status) == "1" ? "on" : "off";
    ConnectionManager.Humidity_Controller_Status =
        Utils.int_str(await cmg.getRequest("get100"), ConnectionManager.Humidity_Controller_Status) == "1" ? "on" : "off";

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    refresher.cancel();

    super.dispose();
  }

  List<Widget> build_text_row({title, value, String suffix = "°C"}) => [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
          child: Row(
            children: [
              Expanded(child: Text(title, style: Theme.of(context).textTheme.bodyText1)),
              Expanded(
                child: Text(
                  value + " " + suffix,
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.right,
                ),
              )
            ],
          ),
        ),
        Divider(
          color: Theme.of(context).accentColor,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).canvasColor,
        child: SafeArea(
            child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.max, children: [
            ...build_text_row(title: "Room Temperature", value: ConnectionManager.Real_Room_Temp_0),
            ...build_text_row(title: "Outdoor Temperature", value: ConnectionManager.Real_Outdoor_Temp),
            ...build_text_row(title: "Negative Pressure", value: ConnectionManager.Real_Negative_Pressure_, suffix: 'hpa'),
            ...build_text_row(title: "HUmiditoy", value: ConnectionManager.Real_Humidity, suffix: '%'),
            ...iaq_or_co
                ? (build_text_row(title: "IAQ", value: ConnectionManager.Real_IAQ, suffix: 'ppm'))
                : (build_text_row(title: "Co2", value: ConnectionManager.Real_CO2, suffix: 'ppm')),
            ...build_text_row(title: "Light level", value: ConnectionManager.Real_Light_Level, suffix: 'Lux'),
            ...build_text_row(title: "Inlet Fan Speed", value: ConnectionManager.Real_Input_Fan_Speed, suffix: '%'),
            ...build_text_row(title: "Inlet Fan Power", value: ConnectionManager.Input_Fan_Power, suffix: 'W'),
            ...build_text_row(title: "Outlet Fan Speed", value: ConnectionManager.Real_Output_Fan_Speed, suffix: '%'),
            ...build_text_row(title: "Outlet Fan Power", value: ConnectionManager.Real_Output_Fan_Power, suffix: 'W'),
            ...build_text_row(title: "Cooler", value: ConnectionManager.Cooler_Status, suffix: ''),
            ...build_text_row(title: "Heater", value: ConnectionManager.Heater_Status, suffix: ''),
            ...build_text_row(title: "Air Purifier", value: ConnectionManager.Air_Purifier_Status, suffix: ''),
            ...build_text_row(title: "Humidity Controller", value: ConnectionManager.Humidity_Controller_Status, suffix: ''),
          ]),
        )));
  }
}
