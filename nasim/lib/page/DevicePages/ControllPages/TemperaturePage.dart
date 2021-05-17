import 'dart:async';
import 'dart:math';

import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/material.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:provider/provider.dart';

import '../../../utils.dart';

class TemperaturePage extends StatefulWidget {
  @override
  _TemperaturePageState createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {
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

    ConnectionManager.Humidity_Controller = Utils.int_str(await cmg.getRequest("get59"), ConnectionManager.Humidity_Controller);
    ConnectionManager.Min_Day_Humidity = Utils.int_str(await cmg.getRequest("get61"), ConnectionManager.Min_Day_Humidity);
    ConnectionManager.Min_Night_Humidity = Utils.int_str(await cmg.getRequest("get63"), ConnectionManager.Min_Night_Humidity);
    ConnectionManager.Max_Day_Humidity = Utils.int_str(await cmg.getRequest("get60"), ConnectionManager.Max_Day_Humidity);
    ConnectionManager.Max_Night_Humidity = Utils.int_str(await cmg.getRequest("get62"), ConnectionManager.Max_Night_Humidity);

    setState(() {
      humidity_controller_radio_gvalue = (int.tryParse(ConnectionManager.Humidity_Controller) ?? 0);

      if (is_night) {
        humidity_min = (int.tryParse(ConnectionManager.Min_Night_Humidity) ?? 0).toString();
        humidity_max = (int.tryParse(ConnectionManager.Max_Night_Humidity) ?? 0).toString();
      } else {
        humidity_min = (int.tryParse(ConnectionManager.Min_Day_Humidity) ?? 0).toString();
        humidity_max = (int.tryParse(ConnectionManager.Max_Day_Humidity) ?? 0).toString();
      }

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

      if (!await cmg.set_request(47, Utils.sign_int_100(ConnectionManager.Favourite_Room_Temp_Day_))) {
        Utils.handleError(context);
        return;
      }
      await cmg.set_request(53, Utils.sign_int_100(ConnectionManager.Favourite_Room_Temp_Night));

      await cmg.set_request(48, Utils.lim_0_20(ConnectionManager.Room_Temp_Sensitivity_Day));
      await cmg.set_request(54, Utils.lim_0_20(ConnectionManager.Room_Temp_Sensitivity_Night));

      await cmg.set_request(49, Utils.sign_int_100(ConnectionManager.Cooler_Start_Temp_Day));
      await cmg.set_request(55, Utils.sign_int_100(ConnectionManager.Cooler_Start_Temp_Night));
      await cmg.set_request(50, Utils.sign_int_100(ConnectionManager.Cooler_Stop_Temp_Day));
      await cmg.set_request(56, Utils.sign_int_100(ConnectionManager.Cooler_Stop_Temp_Night));
      await cmg.set_request(51, Utils.sign_int_100(ConnectionManager.Heater_Start_Temp_Day));
      await cmg.set_request(57, Utils.sign_int_100(ConnectionManager.Heater_Start_Temp_Night));
      await cmg.set_request(52, Utils.sign_int_100(ConnectionManager.Heater_Stop_Temp_Day));
      await cmg.set_request(58, Utils.sign_int_100(ConnectionManager.Heater_Stop_Temp_Night));
    } catch (e) {
      Utils.alert(context, "Error", "please check your input and try again.");
    }
    refresh();
  }

  apply_humidity() async {
    try {
      if (int.parse(humidity_min) + 5 >= int.parse(humidity_max)) {
        Utils.alert(context, "Error", "Humidity min and max must have more than 5 diffrentiate.");
        return;
      }
      if (!await cmg.set_request(59, Utils.sign_int_100(ConnectionManager.Humidity_Controller))) {
        Utils.handleError(context);
        return;
      }

      await cmg.set_request(61, Utils.sign_int_100(ConnectionManager.Min_Day_Humidity));
      await cmg.set_request(63, Utils.sign_int_100(ConnectionManager.Min_Night_Humidity));
      await cmg.set_request(60, Utils.sign_int_100(ConnectionManager.Max_Day_Humidity));
      await cmg.set_request(62, Utils.sign_int_100(ConnectionManager.Max_Night_Humidity));
    } catch (e) {
      Utils.alert(context, "Error", "please check your input and try again.");
    }
    refresh();
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

  Widget temperature_fragment() =>
      // padding: const EdgeInsets.symmetric(horizontal: 8.0),
      Column(
        children: [
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
  int humidity_controller_radio_gvalue = 0;

  String humidity_min = "";
  Widget get row_humidity_min => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: Text("Min: ")),
            Expanded(
              child: TextField(
                style: Theme.of(context).textTheme.bodyText1,
                controller: TextEditingController()..text = humidity_min,
                onChanged: (value) {
                  humidity_min = Utils.lim_0_100(value);
                  if (is_night) {
                    ConnectionManager.Min_Night_Humidity = int.parse(humidity_min).toString().padLeft(3, '0');
                  } else {
                    ConnectionManager.Min_Day_Humidity = int.parse(humidity_min).toString().padLeft(3, '0');
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(suffix: Text(' %')),
              ),
            )
          ],
        ),
      );
  String humidity_max = "";
  Widget get row_humidity_max => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: Text("Max: ")),
            Expanded(
              child: TextField(
                style: Theme.of(context).textTheme.bodyText1,
                controller: TextEditingController()..text = humidity_max,
                onChanged: (value) {
                  humidity_max = Utils.lim_0_100(value);
                  if (is_night) {
                    ConnectionManager.Max_Night_Humidity = int.parse(humidity_max).toString().padLeft(3, '0');
                  } else {
                    ConnectionManager.Max_Day_Humidity = int.parse(humidity_max).toString().padLeft(3, '0');
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(suffix: Text(' %')),
              ),
            )
          ],
        ),
      );

  Widget humidity_fragment() => Column(
        children: [
          build_day_night_switch(),
          SizedBox(
            height: 16,
          ),
          build_boxed_titlebox(
              title: "Controller is",
              child: Column(
                children: [
                  ListTile(
                    title: Text('Humiditfire', style: Theme.of(context).textTheme.bodyText1),
                    onTap: () {
                      setState(() {
                        ConnectionManager.Humidity_Controller = "0"; //means humidifer
                        if (humidity_controller_radio_gvalue != 0) humidity_controller_radio_gvalue = 0;
                      });
                    },
                    leading: Radio(
                      value: 0,
                      groupValue: humidity_controller_radio_gvalue,
                      onChanged: (int? value) {
                        setState(() {
                          if (humidity_controller_radio_gvalue != value) humidity_controller_radio_gvalue = value!;
                          ConnectionManager.Humidity_Controller = "0"; //means humidifer
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('Dehumidifier', style: Theme.of(context).textTheme.bodyText1),
                    onTap: () {
                      setState(() {
                        if (humidity_controller_radio_gvalue != 1) humidity_controller_radio_gvalue = 1;
                        ConnectionManager.Humidity_Controller = "1"; //means Dehumidifer
                      });
                    },
                    leading: Radio(
                      value: 1,
                      groupValue: humidity_controller_radio_gvalue,
                      onChanged: (int? value) {
                        setState(() {
                          if (humidity_controller_radio_gvalue != value) humidity_controller_radio_gvalue = value!;
                          ConnectionManager.Humidity_Controller = "1"; //means Dehumidifer
                        });
                      },
                    ),
                  ),
                ],
              )),
          row_humidity_min,
          row_humidity_max,
          Expanded(
              child: Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                build_apply_button(() {
                  apply_humidity();
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: TabBar(
          labelStyle: Theme.of(context).textTheme.bodyText1,
          labelColor: Theme.of(context).textTheme.bodyText1!.color,
          tabs: [
            Tab(
              text: "Temperature",
            ),
            Tab(
              text: "Humidity",
            ),
          ],
        ),
        body: TabBarView(
          children: [
            temperature_fragment(),
            humidity_fragment(),
          ],
        ),
      ),
    );
  }
}
