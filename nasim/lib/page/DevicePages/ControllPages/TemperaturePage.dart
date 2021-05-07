import 'dart:async';

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
    ConnectionManager.Favourite_Room_Temp_Day_ = await cmg.getRequest("get23");
    ConnectionManager.Favourite_Room_Temp_Night = await cmg.getRequest("get29");
    ConnectionManager.Cooler_Start_Temp_Day = await cmg.getRequest("get25");
    ConnectionManager.Cooler_Start_Temp_Night = await cmg.getRequest("get31");
    ConnectionManager.Cooler_Stop_Temp_Day = await cmg.getRequest("get26");
    ConnectionManager.Cooler_Stop_Temp_Night = await cmg.getRequest("get32");
    ConnectionManager.Heater_Start_Temp_Day = await cmg.getRequest("get27");
    ConnectionManager.Heater_Start_Temp_Night = await cmg.getRequest("get33");
    ConnectionManager.Heater_Stop_Temp_Day = await cmg.getRequest("get28");
    ConnectionManager.Heater_Stop_Temp_Night = await cmg.getRequest("get34");
    ConnectionManager.Humidity_Controller_Day_Mode = await cmg.getRequest("get78");
    ConnectionManager.Humidity_Controller_Night_Mode = await cmg.getRequest("get79");
    ConnectionManager.Min_Day_Humidity = await cmg.getRequest("get37");
    ConnectionManager.Min_Night_Humidity = await cmg.getRequest("get39");
    ConnectionManager.Max_Day_Humidity = await cmg.getRequest("get36");
    ConnectionManager.Max_Night_Humidity = await cmg.getRequest("get38");

    setState(() {
      if (is_night) {
        room_temp = (int.tryParse(ConnectionManager.Favourite_Room_Temp_Night) ?? 0).toString();
        cooler_start_temp = (int.tryParse(ConnectionManager.Cooler_Start_Temp_Night) ?? 0).toString();
        cooler_stop_temp = (int.tryParse(ConnectionManager.Cooler_Stop_Temp_Night) ?? 0).toString();
        heater_start_temp = (int.tryParse(ConnectionManager.Heater_Start_Temp_Night) ?? 0).toString();
        heater_stop_temp = (int.tryParse(ConnectionManager.Heater_Stop_Temp_Night) ?? 0).toString();
        humidity_controller_radio_gvalue = (int.tryParse(ConnectionManager.Humidity_Controller_Night_Mode) ?? 0);
        humidity_min = (int.tryParse(ConnectionManager.Min_Night_Humidity) ?? 0).toString();
        humidity_max = (int.tryParse(ConnectionManager.Max_Night_Humidity) ?? 0).toString();
      } else {
        room_temp = (int.tryParse(ConnectionManager.Favourite_Room_Temp_Day_) ?? 0).toString();
        cooler_start_temp = (int.tryParse(ConnectionManager.Cooler_Start_Temp_Day) ?? 0).toString();
        cooler_stop_temp = (int.tryParse(ConnectionManager.Cooler_Stop_Temp_Day) ?? 0).toString();
        heater_start_temp = (int.tryParse(ConnectionManager.Heater_Start_Temp_Day) ?? 0).toString();
        heater_stop_temp = (int.tryParse(ConnectionManager.Heater_Stop_Temp_Day) ?? 0).toString();
        humidity_controller_radio_gvalue = (int.tryParse(ConnectionManager.Humidity_Controller_Day_Mode) ?? 0);
        humidity_min = (int.tryParse(ConnectionManager.Min_Day_Humidity) ?? 0).toString();
        humidity_max = (int.tryParse(ConnectionManager.Max_Day_Humidity) ?? 0).toString();
      }
    });
  }

  apply_temp() async {
    if (!await cmg.set_request(23, ConnectionManager.Favourite_Room_Temp_Day_)) {
      Utils.handleError(context);
      return;
    }
    await cmg.set_request(29, ConnectionManager.Favourite_Room_Temp_Night);
    await cmg.set_request(25, ConnectionManager.Cooler_Start_Temp_Day);
    await cmg.set_request(31, ConnectionManager.Cooler_Start_Temp_Night);
    await cmg.set_request(26, ConnectionManager.Cooler_Stop_Temp_Day);
    await cmg.set_request(32, ConnectionManager.Cooler_Stop_Temp_Night);
    await cmg.set_request(27, ConnectionManager.Heater_Start_Temp_Day);
    await cmg.set_request(33, ConnectionManager.Heater_Start_Temp_Night);
  }

  apply_humidity() async {
    if (!await cmg.set_request(78, ConnectionManager.Humidity_Controller_Day_Mode)) {
      Utils.handleError(context);
      return;
    }

    await cmg.set_request(79, ConnectionManager.Humidity_Controller_Night_Mode);
    await cmg.set_request(37, ConnectionManager.Min_Day_Humidity);
    await cmg.set_request(39, ConnectionManager.Min_Night_Humidity);
    await cmg.set_request(36, ConnectionManager.Max_Day_Humidity);
    await cmg.set_request(38, ConnectionManager.Max_Night_Humidity);
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

  bool is_night = true;
  build_day_night_switch() => Container(
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
                  cooler_stop_temp = value;
                  if (is_night) {
                    ConnectionManager.Cooler_Stop_Temp_Night = int.parse(value).toString().padLeft(3, '0');
                  } else {
                    ConnectionManager.Cooler_Stop_Temp_Day = int.parse(value).toString().padLeft(3, '0');
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
                  heater_start_temp = value;
                  if (is_night) {
                    ConnectionManager.Heater_Start_Temp_Night = int.parse(value).toString().padLeft(3, '0');
                  } else {
                    ConnectionManager.Heater_Start_Temp_Day = int.parse(value).toString().padLeft(3, '0');
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
                  heater_stop_temp = value;
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(suffix: Text(' °C')),
              ),
            )
          ],
        ),
      );
  Widget temperature_fragment() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            build_day_night_switch(),
            row_room_temp,
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
        ),
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
                  humidity_min = value;
                  if (is_night) {
                    ConnectionManager.Min_Night_Humidity = int.parse(value).toString().padLeft(3, '0');
                  } else {
                    ConnectionManager.Min_Day_Humidity = int.parse(value).toString().padLeft(3, '0');
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
                  humidity_max = value;
                  humidity_min = value;
                  if (is_night) {
                    ConnectionManager.Max_Night_Humidity = int.parse(value).toString().padLeft(3, '0');
                  } else {
                    ConnectionManager.Max_Day_Humidity = int.parse(value).toString().padLeft(3, '0');
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(suffix: Text(' %')),
              ),
            )
          ],
        ),
      );

  Widget humidity_fragment() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            build_day_night_switch(),
            build_boxed_titlebox(
                title: "Controller is",
                child: Column(
                  children: [
                    ListTile(
                      title: Text('Humiditfire', style: Theme.of(context).textTheme.headline6),
                      onTap: () {
                        setState(() {
                          if (humidity_controller_radio_gvalue != 0) humidity_controller_radio_gvalue = 0;
                          if (is_night) {
                            ConnectionManager.Humidity_Controller_Night_Mode = humidity_controller_radio_gvalue.toString();
                          } else {
                            ConnectionManager.Humidity_Controller_Day_Mode = humidity_controller_radio_gvalue.toString();
                          }
                        });
                      },
                      leading: Radio(
                        value: 0,
                        groupValue: humidity_controller_radio_gvalue,
                        onChanged: (int? value) {
                          setState(() {
                            if (humidity_controller_radio_gvalue != value) humidity_controller_radio_gvalue = value!;

                            if (is_night) {
                              ConnectionManager.Humidity_Controller_Night_Mode = humidity_controller_radio_gvalue.toString();
                            } else {
                              ConnectionManager.Humidity_Controller_Day_Mode = humidity_controller_radio_gvalue.toString();
                            }
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Text('Dehumidifier', style: Theme.of(context).textTheme.headline6),
                      onTap: () {
                        setState(() {
                          if (humidity_controller_radio_gvalue != 1) humidity_controller_radio_gvalue = 1;
                          if (is_night) {
                            ConnectionManager.Humidity_Controller_Night_Mode = humidity_controller_radio_gvalue.toString();
                          } else {
                            ConnectionManager.Humidity_Controller_Day_Mode = humidity_controller_radio_gvalue.toString();
                          }
                        });
                      },
                      leading: Radio(
                        value: 1,
                        groupValue: humidity_controller_radio_gvalue,
                        onChanged: (int? value) {
                          setState(() {
                            if (humidity_controller_radio_gvalue != value) humidity_controller_radio_gvalue = value!;
                            if (is_night) {
                              ConnectionManager.Humidity_Controller_Night_Mode = humidity_controller_radio_gvalue.toString();
                            } else {
                              ConnectionManager.Humidity_Controller_Day_Mode = humidity_controller_radio_gvalue.toString();
                            }
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
        ),
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
            child: Text("Apply", style: Theme.of(context).textTheme.headline6),
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
            child: Text("Restore Defaults", style: Theme.of(context).textTheme.headline6),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: TabBar(
          labelStyle: Theme.of(context).textTheme.headline6,
          labelColor: Theme.of(context).textTheme.headline6!.color,
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
