import 'dart:async';
import 'dart:math';

import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils.dart';

class wpage_temperature extends StatefulWidget {
  @override
  _wpage_temperatureState createState() => _wpage_temperatureState();
}

class _wpage_temperatureState extends State<wpage_temperature> {
  late ConnectionManager cmg;
  @override
  void initState() {
    super.initState();

    cmg = Provider.of<ConnectionManager>(context, listen: false);

    refresh();
  }

  @override
  void dispose() {
    super.dispose();
  }

  refresh() async {
    ConnectionManager.Favourite_Room_Temp_Day_ = Utils.int_str(await cmg.getRequest("get47"), ConnectionManager.Favourite_Room_Temp_Day_);
    ConnectionManager.Favourite_Room_Temp_Night = Utils.int_str(await cmg.getRequest("get53"), ConnectionManager.Favourite_Room_Temp_Night);
    ConnectionManager.Room_Temp_Sensitivity_Day = Utils.int_str(await cmg.getRequest("get48"), ConnectionManager.Room_Temp_Sensitivity_Day);
    ConnectionManager.Room_Temp_Sensitivity_Night = Utils.int_str(await cmg.getRequest("get54"), ConnectionManager.Room_Temp_Sensitivity_Night);
    ConnectionManager.Cooler_Start_Temp_Day = Utils.int_str(await cmg.getRequest("get49"), ConnectionManager.Cooler_Start_Temp_Day);
    ConnectionManager.Cooler_Start_Temp_Night = Utils.int_str(await cmg.getRequest("get55"), ConnectionManager.Cooler_Start_Temp_Night);
    ConnectionManager.Cooler_Stop_Temp_Day = Utils.int_str(await cmg.getRequest("get50"), ConnectionManager.Cooler_Stop_Temp_Day);
    ConnectionManager.Cooler_Stop_Temp_Night = Utils.int_str(await cmg.getRequest("get56"), ConnectionManager.Cooler_Stop_Temp_Night);
    ConnectionManager.Heater_Start_Temp_Day = Utils.int_str(await cmg.getRequest("get51"), ConnectionManager.Heater_Start_Temp_Day);
    ConnectionManager.Heater_Start_Temp_Night = Utils.int_str(await cmg.getRequest("get57"), ConnectionManager.Heater_Start_Temp_Night);
    ConnectionManager.Heater_Stop_Temp_Day = Utils.int_str(await cmg.getRequest("get52"), ConnectionManager.Heater_Stop_Temp_Day);
    ConnectionManager.Heater_Stop_Temp_Night = Utils.int_str(await cmg.getRequest("get58"), ConnectionManager.Heater_Stop_Temp_Night);

    setState(() {
      if (is_night) {
        room_temp = (int.tryParse(ConnectionManager.Favourite_Room_Temp_Night) ?? 0).toString();
        room_temp_sensivity = ((double.tryParse(ConnectionManager.Room_Temp_Sensitivity_Night) ?? 5.0) / 10.0).toString();
        cooler_start_temp = (int.tryParse(ConnectionManager.Cooler_Start_Temp_Night) ?? 0).toString();
        cooler_stop_temp = (int.tryParse(ConnectionManager.Cooler_Stop_Temp_Night) ?? 0).toString();
        heater_start_temp = (int.tryParse(ConnectionManager.Heater_Start_Temp_Night) ?? 0).toString();
        heater_stop_temp = (int.tryParse(ConnectionManager.Heater_Stop_Temp_Night) ?? 0).toString();
      } else {
        room_temp = (int.tryParse(ConnectionManager.Favourite_Room_Temp_Day_) ?? 0).toString();
        room_temp_sensivity = ((double.tryParse(ConnectionManager.Room_Temp_Sensitivity_Day) ?? 5.0) / 10.0).toString();
        cooler_start_temp = (int.tryParse(ConnectionManager.Cooler_Start_Temp_Day) ?? 0).toString();
        cooler_stop_temp = (int.tryParse(ConnectionManager.Cooler_Stop_Temp_Day) ?? 0).toString();
        heater_start_temp = (int.tryParse(ConnectionManager.Heater_Start_Temp_Day) ?? 0).toString();
        heater_stop_temp = (int.tryParse(ConnectionManager.Heater_Stop_Temp_Day) ?? 0).toString();
      }
    });
  }

  apply_temp() async {
    try {
      if (int.parse(cooler_stop_temp) < int.parse(room_temp)) {
        Utils.alert(context, "Error", "cooler stop temp cannot be lower that favorite room temberature.");
        return;
      }
      if ((int.parse(cooler_start_temp) - int.parse(cooler_stop_temp)).abs() < 1) {
        Utils.alert(context, "Error", "cooler start and stop temperature differtiate must be more than 1");
        return;
      }
      if (int.parse(heater_stop_temp) < int.parse(room_temp)) {
        Utils.alert(context, "Error", "heater stop temperature cannot be lower than favorite room temp.");
        return;
      }
      if ((int.parse(heater_start_temp) - int.parse(heater_stop_temp)).abs() < 1) {
        Utils.alert(context, "Error", "heater start and stop temperature differtiate must be more than 1");
        return;
      }

      if (!await cmg.set_request(47, Utils.lim_0_100(ConnectionManager.Favourite_Room_Temp_Day_))) {
        Utils.handleError(context);
        return;
      }
      await cmg.set_request(53, Utils.lim_0_100(ConnectionManager.Favourite_Room_Temp_Night));

      await cmg.set_request(48, Utils.lim_0_100(ConnectionManager.Room_Temp_Sensitivity_Day));
      await cmg.set_request(54, Utils.lim_0_100(ConnectionManager.Room_Temp_Sensitivity_Night));

      await cmg.set_request(49, Utils.lim_0_100(ConnectionManager.Cooler_Start_Temp_Day));
      await cmg.set_request(55, Utils.lim_0_100(ConnectionManager.Cooler_Start_Temp_Night));
      await cmg.set_request(50, Utils.lim_0_100(ConnectionManager.Cooler_Stop_Temp_Day));
      await cmg.set_request(56, Utils.lim_0_100(ConnectionManager.Cooler_Stop_Temp_Night));
      await cmg.set_request(51, Utils.lim_0_100(ConnectionManager.Heater_Start_Temp_Day));
      await cmg.set_request(57, Utils.lim_0_100(ConnectionManager.Heater_Start_Temp_Night));
      await cmg.set_request(52, Utils.lim_0_100(ConnectionManager.Heater_Stop_Temp_Day));
      await cmg.set_request(58, Utils.lim_0_100(ConnectionManager.Heater_Stop_Temp_Night));
    } catch (e) {
      Utils.alert(context, "Error", "please check your input and try again.");
    }
    refresh();
  }

  bool is_night = true;
  build_day_night_switch() => Container(
        color: Color(0xff181818),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(children: [
            Expanded(child: Text("Settings for ${is_night ? "Night" : "Day"} Time ", style: Theme.of(context).textTheme.headline6)),
            DayNightSwitcher(
              isDarkModeEnabled: is_night,
              onStateChanged: (is_night) {
                setState(() {
                  this.is_night = is_night;
                  refresh();
                });
              },
            )
          ]),
        ),
      );

  String room_temp = "";
  Widget get row_room_temp => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: Text("Room Temp:")),
            Expanded(
              child: TextField(
                style: Theme.of(context).textTheme.bodyText1,
                controller: TextEditingController()..text = room_temp,
                onChanged: (value) {
                  room_temp = value;
                  if (is_night) {
                    ConnectionManager.Favourite_Room_Temp_Night = int.parse(value).toString().padLeft(3, '0');
                  } else {
                    ConnectionManager.Favourite_Room_Temp_Day_ = int.parse(value).toString().padLeft(3, '0');
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(suffix: Text(' °C')),
              ),
            )
          ],
        ),
      );

  String room_temp_sensivity = "0.5";
  Widget get row_room_temp_sensivity => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: Text("Room Temp Sensivity:")),
            Expanded(
              child: TextField(
                style: Theme.of(context).textTheme.bodyText1,
                controller: TextEditingController()..text = room_temp_sensivity,
                onChanged: (value) {
                  room_temp_sensivity = value;
                  double val_f = double.parse(value);
                  if (is_night) {
                    ConnectionManager.Room_Temp_Sensitivity_Night = max(0, min((val_f * 10).round(), 10)).toString().padLeft(3, '0');
                  } else {
                    ConnectionManager.Room_Temp_Sensitivity_Day = max(0, min((val_f * 10).round(), 10)).toString().padLeft(3, '0');
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(suffix: Text(' °C')),
              ),
            )
          ],
        ),
      );

  String cooler_start_temp = "";
  Widget get row_cooler_start_temp => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: Text("Cooler Start Temp: ")),
            Expanded(
              child: TextField(
                style: Theme.of(context).textTheme.bodyText1,
                controller: TextEditingController()..text = cooler_start_temp,
                onChanged: (value) {
                  cooler_start_temp = value;
                  if (is_night) {
                    ConnectionManager.Cooler_Start_Temp_Night = int.parse(value).toString().padLeft(3, '0');
                  } else {
                    ConnectionManager.Cooler_Start_Temp_Day = int.parse(value).toString().padLeft(3, '0');
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(suffix: Text(' °C')),
              ),
            )
          ],
        ),
      );
  String cooler_stop_temp = "";
  Widget get row_cooler_stop_temp => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: Text("Cooler Stop Temp: ")),
            Expanded(
              child: TextField(
                style: Theme.of(context).textTheme.bodyText1,
                controller: TextEditingController()..text = cooler_stop_temp,
                onChanged: (value) {
                  cooler_stop_temp = Utils.lim_0_100(value);
                  if (is_night) {
                    ConnectionManager.Cooler_Stop_Temp_Night = int.parse(cooler_stop_temp).toString().padLeft(3, '0');
                  } else {
                    ConnectionManager.Cooler_Stop_Temp_Day = int.parse(cooler_stop_temp).toString().padLeft(3, '0');
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(suffix: Text(' °C')),
              ),
            )
          ],
        ),
      );
  String heater_start_temp = "";
  Widget get row_heater_start_temp => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: Text("Heater Start Temp: ")),
            Expanded(
              child: TextField(
                style: Theme.of(context).textTheme.bodyText1,
                controller: TextEditingController()..text = heater_start_temp,
                onChanged: (value) {
                  heater_start_temp = Utils.lim_0_100(value);

                  if (is_night) {
                    ConnectionManager.Heater_Start_Temp_Night = int.parse(heater_start_temp).toString().padLeft(3, '0');
                  } else {
                    ConnectionManager.Heater_Start_Temp_Day = int.parse(heater_start_temp).toString().padLeft(3, '0');
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(suffix: Text(' °C')),
              ),
            )
          ],
        ),
      );
  String heater_stop_temp = "";
  Widget get row_heater_stop_temp => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: Text("Heater Stop Temp: ")),
            Expanded(
              child: TextField(
                style: Theme.of(context).textTheme.bodyText1,
                controller: TextEditingController()..text = heater_stop_temp,
                onChanged: (value) {
                  heater_stop_temp = Utils.lim_0_100(value);
                  if (is_night) {
                    ConnectionManager.Heater_Stop_Temp_Night = int.parse(heater_stop_temp).toString().padLeft(3, '0');
                  } else {
                    ConnectionManager.Heater_Stop_Temp_Day = int.parse(heater_stop_temp).toString().padLeft(3, '0');
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(suffix: Text(' °C')),
              ),
            )
          ],
        ),
      );
  Widget temperature_fragment() =>
      // padding: const EdgeInsets.symmetric(horizontal: 8.0),
      Column(
        children: [
          ...make_title("Temperature"),
          build_day_night_switch(),
          row_room_temp,
          row_room_temp_sensivity,
          row_cooler_start_temp,
          row_cooler_stop_temp,
          row_heater_start_temp,
          row_heater_stop_temp,
          Expanded(
              child: Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                build_apply_button(() {
                  apply_temp();
                }),
                build_reset_button()
              ],
            ),
          ))
        ],
      );

  build_apply_button(click) => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 15),
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: OutlinedButton(
            onPressed: click,
            style: OutlinedButton.styleFrom(
                padding: EdgeInsets.only(top: 16, bottom: 16, left: 28, right: 28),
                side: BorderSide(width: 2, color: Theme.of(context).primaryColor),
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(8.0))),
            child: Text("Apply", style: Theme.of(context).textTheme.bodyText1),
          ),
        ),
      );
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
            child: Text("Restore Defaults", style: Theme.of(context).textTheme.bodyText1),
          ),
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 64),
      child: temperature_fragment(),
    );
  }
}
