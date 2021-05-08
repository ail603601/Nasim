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

  @override
  void initState() {
    super.initState();
    // runs every 1 second
    refresher = Timer.periodic(new Duration(milliseconds: 500), (timer) {
      refresh();
    });
    cmg = Provider.of<ConnectionManager>(context, listen: false);
  }

  refresh() async {
    ConnectionManager.Real_Room_Temp_9 = Utils.int_str(await cmg.getRequest("get55"), ConnectionManager.Real_Room_Temp_9);
    ConnectionManager.Real_Outdoor_Temp = Utils.int_str(await cmg.getRequest("get56"), ConnectionManager.Real_Outdoor_Temp);
    ConnectionManager.Real_Negative_Pressure_ = Utils.int_str(await cmg.getRequest("get57"), ConnectionManager.Real_Negative_Pressure_);
    ConnectionManager.Real_Humidity = Utils.int_str(await cmg.getRequest("get58"), ConnectionManager.Real_Humidity);
    ConnectionManager.Real_IAQ = Utils.int_str(await cmg.getRequest("get59"), ConnectionManager.Real_IAQ);
    ConnectionManager.Real_CO2 = Utils.int_str(await cmg.getRequest("get60"), ConnectionManager.Real_CO2);
    ConnectionManager.Real_Light_Level = Utils.int_str(await cmg.getRequest("get61"), ConnectionManager.Real_Light_Level);
    ConnectionManager.Real_Input_Fan_Speed = Utils.int_str(await cmg.getRequest("get62"), ConnectionManager.Real_Input_Fan_Speed);
    ConnectionManager.Input_Fan_Power = Utils.int_str(await cmg.getRequest("get21"), ConnectionManager.Input_Fan_Power);
    ConnectionManager.Real_Output_Fan_Speed = Utils.int_str(await cmg.getRequest("get63"), ConnectionManager.Real_Output_Fan_Speed);
    ConnectionManager.Real_Output_Fan_Power = Utils.int_str(await cmg.getRequest("get15"), ConnectionManager.Real_Output_Fan_Power);
    ConnectionManager.Cooler_Status = Utils.int_str(await cmg.getRequest("get64"), ConnectionManager.Cooler_Status) == "1" ? "on" : "off";
    ConnectionManager.Heater_Status = Utils.int_str(await cmg.getRequest("get65"), ConnectionManager.Heater_Status) == "1" ? "on" : "off";
    ConnectionManager.Air_Purifier_Status = Utils.int_str(await cmg.getRequest("get66"), ConnectionManager.Air_Purifier_Status) == "1" ? "on" : "off";
    ConnectionManager.Humidity_Controller_Status =
        Utils.int_str(await cmg.getRequest("get67"), ConnectionManager.Humidity_Controller_Status) == "1" ? "on" : "off";

    setState(() {});
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
              Expanded(child: Text(title, style: Theme.of(context).textTheme.headline6)),
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
            ...build_text_row(title: "Room Temperature", value: ConnectionManager.Real_Room_Temp_9),
            ...build_text_row(title: "Outdoor Temperature", value: ConnectionManager.Real_Outdoor_Temp),
            ...build_text_row(title: "Negative Pressure", value: ConnectionManager.Real_Negative_Pressure_, suffix: 'hpa'),
            ...build_text_row(title: "HUmiditoy", value: ConnectionManager.Real_Humidity, suffix: '%'),
            ...build_text_row(title: "IAQ", value: ConnectionManager.Real_IAQ, suffix: 'ppm'),
            ...build_text_row(title: "Co2", value: ConnectionManager.Real_CO2, suffix: 'ppm'),
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
