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
    Utils.setTimeOut(0, () {
      Utils.show_loading_timed(
          context: context,
          done: () async {
            await refresh();
          });
    });
  }

  refresh() async {
    if (!mounted) return;

    ConnectionManager.Real_Room_Temp_0 = (int.tryParse(await cmg.getRequest_non0("get79")) ?? 0).toString();
    ConnectionManager.Real_Room_Temp_1 = (int.tryParse(await cmg.getRequest_non0("get80")) ?? 0).toString();
    ConnectionManager.Real_Room_Temp_2 = (int.tryParse(await cmg.getRequest_non0("get81")) ?? 0).toString();
    ConnectionManager.Real_Room_Temp_3 = (int.tryParse(await cmg.getRequest_non0("get82")) ?? 0).toString();
    ConnectionManager.Real_Room_Temp_4 = (int.tryParse(await cmg.getRequest_non0("get83")) ?? 0).toString();
    ConnectionManager.Real_Room_Temp_5 = (int.tryParse(await cmg.getRequest_non0("get84")) ?? 0).toString();
    ConnectionManager.Real_Room_Temp_6 = (int.tryParse(await cmg.getRequest_non0("get85")) ?? 0).toString();
    ConnectionManager.Real_Room_Temp_7 = (int.tryParse(await cmg.getRequest_non0("get86")) ?? 0).toString();
    ConnectionManager.Real_Room_Temp_8 = (int.tryParse(await cmg.getRequest_non0("get87")) ?? 0).toString();
    ConnectionManager.Real_Outdoor_Temp = (int.tryParse(await cmg.getRequest_non0("get89")) ?? 0).toString();
    ConnectionManager.Real_Negative_Pressure_ = (int.tryParse(await cmg.getRequest_non0("get90")) ?? 0).toString();
    ConnectionManager.Real_Humidity = (int.tryParse(await cmg.getRequest_non0("get91")) ?? 0).toString();
    ConnectionManager.IAQ_Flag = (int.tryParse(await cmg.getRequest_non0("get64")) ?? 0).toString();
    iaq_or_co = (ConnectionManager.IAQ_Flag == "1");

    ConnectionManager.CO2_Flag = (int.tryParse(await cmg.getRequest_non0("get69")) ?? 0).toString();
    if (iaq_or_co) {
      ConnectionManager.Real_IAQ = (int.tryParse(await cmg.getRequest_non0("get92")) ?? 0).toString();
    } else {
      ConnectionManager.Real_CO2 = (int.tryParse(await cmg.getRequest_non0("get93")) ?? 0).toString();
    }
    ConnectionManager.Real_Light_Level = (int.tryParse(await cmg.getRequest_non0("get94")) ?? 0).toString();
    ConnectionManager.Real_Input_Fan_Speed = (int.tryParse(await cmg.getRequest_non0("get95")) ?? 0).toString();
    ConnectionManager.Real_Output_Fan_Speed = (int.tryParse(await cmg.getRequest_non0("get96")) ?? 0).toString();
    ConnectionManager.Real_Output_Fan_Power = (int.tryParse(await cmg.getRequest_non0("get39")) ?? 0).toString();
    ConnectionManager.Cooler_Status = await cmg.getRequest_non0("get97");
    ConnectionManager.Heater_Status = await cmg.getRequest_non0("get98");
    ConnectionManager.Air_Purifier_Status = await cmg.getRequest_non0("get99");
    ConnectionManager.Humidity_Controller_Status = await cmg.getRequest_non0("get100");

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
            ...build_text_row(title: "Humiditoy", value: ConnectionManager.Real_Humidity, suffix: '%'),
            ...iaq_or_co
                ? (build_text_row(title: "IAQ", value: ConnectionManager.Real_IAQ, suffix: 'ppm'))
                : (build_text_row(title: "Co2", value: ConnectionManager.Real_CO2, suffix: 'ppm')),
            ...build_text_row(title: "Light level", value: ConnectionManager.Real_Light_Level, suffix: 'Lux'),
            ...build_text_row(title: "Inlet Fan Speed", value: ConnectionManager.Real_Input_Fan_Speed, suffix: '%'),
            // ...build_text_row(title: "Inlet Fan Power", value: ConnectionManager.Input_Fan_Power, suffix: 'W'),
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
