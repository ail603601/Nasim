import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:provider/provider.dart';

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
    refresher = Timer.periodic(new Duration(milliseconds: 100), (timer) {
      refresh();
    });
    cmg = Provider.of<ConnectionManager>(context, listen: false);
  }

  refresh() async {
    ConnectionManager.Real_Room_Temp_9 = await cmg.getRequest("%P0??\n");
    ConnectionManager.Real_Outdoor_Temp = await cmg.getRequest("%Q??\n");
    ConnectionManager.Real_Negative_Pressure_ = await cmg.getRequest("%R??\n");
    ConnectionManager.Real_Humidity = await cmg.getRequest("%S??\n");
    ConnectionManager.Real_IAQ = await cmg.getRequest("%T??\n");
    ConnectionManager.Real_CO2 = await cmg.getRequest("*A??\n");
    ConnectionManager.Real_Light_Level = await cmg.getRequest("*B??\n");
    ConnectionManager.Real_Input_Fan_Speed = await cmg.getRequest("*C??\n");
    ConnectionManager.Input_Fan_Power = await cmg.getRequest("#B??\n");
    ConnectionManager.Real_Output_Fan_Speed = await cmg.getRequest("*D??\n");
    ConnectionManager.Real_Output_Fan_Power = await cmg.getRequest("!P??\n");
    ConnectionManager.Cooler_Status = await cmg.getRequest("*E??\n");
    ConnectionManager.Heater_Status = await cmg.getRequest("*F??\n");
    ConnectionManager.Air_Purifier_Status = await cmg.getRequest("*G??\n");
    ConnectionManager.Humidity_Controller_Status = await cmg.getRequest("*H??\n");

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
