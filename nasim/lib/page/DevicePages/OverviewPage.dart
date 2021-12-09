import 'dart:async';
import 'dart:ui';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nasim/enums.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/provider/LicenseChangeNotifier.dart';
import 'package:nasim/provider/SavedevicesChangeNofiter.dart';
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
      refresh();
    });
  }

  refresh() async {
    if (!mounted) return;
    bg_dark = true;
    await cmg.getRequest(121, context);
    ConnectionManager.Real_Room_Temp_0 = await cmg.getRequest(79, context);
    ConnectionManager.Real_Room_Temp_1 = await cmg.getRequest(80, context);
    ConnectionManager.Real_Room_Temp_2 = await cmg.getRequest(81, context);
    ConnectionManager.Real_Room_Temp_3 = await cmg.getRequest(82, context);
    ConnectionManager.Real_Room_Temp_4 = await cmg.getRequest(83, context);
    ConnectionManager.Real_Room_Temp_5 = await cmg.getRequest(84, context);
    ConnectionManager.Real_Room_Temp_6 = await cmg.getRequest(85, context);
    ConnectionManager.Real_Room_Temp_7 = await cmg.getRequest(86, context);
    ConnectionManager.Real_Room_Temp_8 = await cmg.getRequest(87, context);
    ConnectionManager.Real_Outdoor_Temp = await cmg.getRequest(89, context);
    ConnectionManager.Real_Negative_Pressure_ = await cmg.getRequest(90, context);
    ConnectionManager.Real_Humidity = await cmg.getRequest(91, context);
    ConnectionManager.IAQ_Flag = await cmg.getRequest(64, context);

    ConnectionManager.CO2_Flag = await cmg.getRequest(69, context);
    if (iaq_or_co) {
      ConnectionManager.Real_IAQ = await cmg.getRequest(92, context);
    } else {
      ConnectionManager.Real_CO2 = await cmg.getRequest(93, context);
    }
    ConnectionManager.Real_Light_Level = await cmg.getRequest(94, context);
    ConnectionManager.Real_Input_Fan_Speed = await cmg.getRequest(95, context);
    ConnectionManager.Real_Output_Fan_Speed = await cmg.getRequest(96, context);
    ConnectionManager.Real_Output_Fan_Power = await cmg.getRequest(39, context);

    ConnectionManager.Real_Room_Temp_0 = (int.tryParse(ConnectionManager.Real_Room_Temp_0) ?? 0).toString();
    ConnectionManager.Real_Room_Temp_1 = (int.tryParse(ConnectionManager.Real_Room_Temp_1) ?? 0).toString();
    ConnectionManager.Real_Room_Temp_2 = (int.tryParse(ConnectionManager.Real_Room_Temp_2) ?? 0).toString();
    ConnectionManager.Real_Room_Temp_3 = (int.tryParse(ConnectionManager.Real_Room_Temp_3) ?? 0).toString();
    ConnectionManager.Real_Room_Temp_4 = (int.tryParse(ConnectionManager.Real_Room_Temp_4) ?? 0).toString();
    ConnectionManager.Real_Room_Temp_5 = (int.tryParse(ConnectionManager.Real_Room_Temp_5) ?? 0).toString();
    ConnectionManager.Real_Room_Temp_6 = (int.tryParse(ConnectionManager.Real_Room_Temp_6) ?? 0).toString();
    ConnectionManager.Real_Room_Temp_7 = (int.tryParse(ConnectionManager.Real_Room_Temp_7) ?? 0).toString();
    ConnectionManager.Real_Room_Temp_8 = (int.tryParse(ConnectionManager.Real_Room_Temp_8) ?? 0).toString();
    ConnectionManager.Real_Outdoor_Temp = (int.tryParse(ConnectionManager.Real_Outdoor_Temp) ?? 0).toString();
    ConnectionManager.Real_Negative_Pressure_ = (int.tryParse(ConnectionManager.Real_Negative_Pressure_) ?? 0).toString();
    ConnectionManager.Real_Humidity = (int.tryParse(ConnectionManager.Real_Humidity) ?? 0).toString();
    ConnectionManager.IAQ_Flag = (int.tryParse(ConnectionManager.IAQ_Flag) ?? 0).toString();
    ConnectionManager.CO2_Flag = (int.tryParse(ConnectionManager.CO2_Flag) ?? 0).toString();
    ConnectionManager.Real_Light_Level = (int.tryParse(ConnectionManager.Real_Light_Level) ?? 0).toString();
    ConnectionManager.Real_Input_Fan_Speed = (int.tryParse(ConnectionManager.Real_Input_Fan_Speed) ?? 0).toString();
    ConnectionManager.Real_Output_Fan_Speed = (int.tryParse(ConnectionManager.Real_Output_Fan_Speed) ?? 0).toString();
    ConnectionManager.Real_Output_Fan_Power = (int.tryParse(ConnectionManager.Real_Output_Fan_Power) ?? 0).toString();
    if (iaq_or_co) {
      ConnectionManager.Real_IAQ = (int.tryParse(ConnectionManager.Real_IAQ) ?? 0).toString();
    } else {
      ConnectionManager.Real_CO2 = (int.tryParse(ConnectionManager.Real_CO2) ?? 0).toString();
    }

    iaq_or_co = (ConnectionManager.IAQ_Flag == "1");

    ConnectionManager.Cooler_Status = await cmg.getRequest(97);
    ConnectionManager.Heater_Status = await cmg.getRequest(98);
    ConnectionManager.Air_Purifier_Status = await cmg.getRequest(99);
    ConnectionManager.Humidity_Controller_Status = await cmg.getRequest(100);

    ConnectionManager.Cooler_Status = (int.tryParse(ConnectionManager.Cooler_Status) ?? 0).toString();
    ConnectionManager.Heater_Status = (int.tryParse(ConnectionManager.Heater_Status) ?? 0).toString();
    ConnectionManager.Air_Purifier_Status = (int.tryParse(ConnectionManager.Air_Purifier_Status) ?? 0).toString();
    ConnectionManager.Humidity_Controller_Status = (int.tryParse(ConnectionManager.Humidity_Controller_Status) ?? 0).toString();

    if (SavedDevicesChangeNotifier.getSelectedDevice()!.accessibility == DeviceAccessibility.AccessibleInternet) {
      last_updated_time = await cmg.getRequest(127, context);
    } else {
      final DateTime now = DateTime.now();
      final DateFormat formatter = DateFormat('yyyy-MM-dd hh-mm');
      final String formatted = formatter.format(now);
      last_updated_time = formatted;
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    refresher.cancel();

    super.dispose();
  }

  bool bg_dark = true;

  List<Widget> build_text_row({title, value, String suffix = "°C"}) {
    bg_dark = !bg_dark;
    return [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
        color: bg_dark ? Color(0x33ffffff) : Colors.black12,
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
        height: 1,
        color: Theme.of(context).accentColor,
      ),
    ];
  }

  static String last_updated_time = "";

  @override
  Widget build(BuildContext context) {
    bg_dark = true;
    return Container(
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
          ...build_text_row(title: "Humidity", value: ConnectionManager.Real_Humidity, suffix: '%'),
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
          ...build_text_row(title: "Last Update:", value: last_updated_time, suffix: ''),
        ]),
      ),
    ));
  }
}
