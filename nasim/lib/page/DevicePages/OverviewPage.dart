import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/provider/LicenseChangeNotifier.dart';
import 'package:provider/provider.dart';

import '../../utils.dart';

class OverviePage extends StatefulWidget {
  @override
  _OverviePageState createState() => _OverviePageState();
}

class _OverviePageState extends State<OverviePage> {
  late ConnectionManager cmg;
  late LicenseChangeNotifier lcn;
  late Timer refresher;
  bool iaq_or_co = false;

  @override
  void initState() {
    super.initState();
    // runs every 1 second
    refresher = Timer.periodic(new Duration(milliseconds: 5000), (timer) {
      refresh();
    });
    cmg = Provider.of<ConnectionManager>(context, listen: false);
    lcn = Provider.of<LicenseChangeNotifier>(context, listen: false);
    refresh();
  }

  refresh() async {
    if (!mounted) return;

    ConnectionManager.Real_Room_Temp_0 = await cmg.getRequest("get79");
    ConnectionManager.Real_Room_Temp_1 = await cmg.getRequest("get80");
    ConnectionManager.Real_Room_Temp_2 = await cmg.getRequest("get81");
    ConnectionManager.Real_Room_Temp_3 = await cmg.getRequest("get82");
    ConnectionManager.Real_Room_Temp_4 = await cmg.getRequest("get83");
    ConnectionManager.Real_Room_Temp_5 = await cmg.getRequest("get84");
    ConnectionManager.Real_Room_Temp_6 = await cmg.getRequest("get85");
    ConnectionManager.Real_Room_Temp_7 = await cmg.getRequest("get86");
    ConnectionManager.Real_Room_Temp_8 = await cmg.getRequest("get87");
    ConnectionManager.Real_Outdoor_Temp = await cmg.getRequest("get89");

    ConnectionManager.Real_Negative_Pressure_ = await cmg.getRequest("get90");
    ConnectionManager.Real_Humidity = await cmg.getRequest("get91");
    ConnectionManager.IAQ_Flag = await cmg.getRequest("get64");
    ConnectionManager.CO2_Flag = await cmg.getRequest("get69");
    ConnectionManager.Real_IAQ = await cmg.getRequest("get92");
    ConnectionManager.Real_CO2 = await cmg.getRequest("get93");

    ConnectionManager.Real_Light_Level = await cmg.getRequest("get94");
    ConnectionManager.Real_Input_Fan_Speed = await cmg.getRequest("get95");
    ConnectionManager.Input_Fan_Power = await cmg.getRequest("get45");
    ConnectionManager.Real_Output_Fan_Speed = await cmg.getRequest("get96");
    ConnectionManager.Real_Output_Fan_Power = await cmg.getRequest("get39");
    ConnectionManager.Cooler_Status = await cmg.getRequest("get97");
    ConnectionManager.Heater_Status = await cmg.getRequest("get98");
    ConnectionManager.Air_Purifier_Status = await cmg.getRequest("get99");
    ConnectionManager.Humidity_Controller_Status = await cmg.getRequest("get100");

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
              Expanded(child: Text(title, style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 13))),
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
            if (lcn.room_temp_0) ...build_text_row(title: "Room Temperature 0", value: ConnectionManager.Real_Room_Temp_0),
            if (lcn.room_temp_1) ...build_text_row(title: "Room Temperature 1", value: ConnectionManager.Real_Room_Temp_1),
            if (lcn.room_temp_2) ...build_text_row(title: "Room Temperature 2", value: ConnectionManager.Real_Room_Temp_2),
            if (lcn.room_temp_3) ...build_text_row(title: "Room Temperature 3", value: ConnectionManager.Real_Room_Temp_3),
            if (lcn.room_temp_4) ...build_text_row(title: "Room Temperature 4", value: ConnectionManager.Real_Room_Temp_4),
            if (lcn.room_temp_5) ...build_text_row(title: "Room Temperature 5", value: ConnectionManager.Real_Room_Temp_5),
            if (lcn.room_temp_6) ...build_text_row(title: "Room Temperature 6", value: ConnectionManager.Real_Room_Temp_6),
            if (lcn.room_temp_7) ...build_text_row(title: "Room Temperature 7", value: ConnectionManager.Real_Room_Temp_7),
            if (lcn.room_temp_8) ...build_text_row(title: "Room Temperature 8", value: ConnectionManager.Real_Room_Temp_8),
            if (lcn.outdoor_temp) ...build_text_row(title: "Outdoor Temperature", value: ConnectionManager.Real_Outdoor_Temp),
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
            ...build_text_row(title: "Cooler", value: ConnectionManager.Cooler_Status == "1" ? "on" : "off", suffix: ''),
            ...build_text_row(title: "Heater", value: ConnectionManager.Heater_Status == "1" ? "on" : "off", suffix: ''),
            ...build_text_row(title: "Air Purifier", value: ConnectionManager.Air_Purifier_Status == "1" ? "on" : "off", suffix: ''),
            ...build_text_row(title: "Humidity Controller", value: ConnectionManager.Humidity_Controller_Status == "1" ? "on" : "off", suffix: ''),
          ]),
        )));
  }
}
