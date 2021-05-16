import 'dart:async';
import 'dart:math';

import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils.dart';

class wpage_humidity extends StatefulWidget {
  @override
  _wpage_humidityState createState() => _wpage_humidityState();
}

class _wpage_humidityState extends State<wpage_humidity> {
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
    });
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

  Widget humidity_fragment() => Column(
        children: [
          ...make_title("Humidity"),
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

  apply_humidity() async {
    try {
      if (int.parse(humidity_min) + 5 >= int.parse(humidity_max)) {
        Utils.alert(context, "Error", "Humidity min and max must have more than 5 diffrentiate.");
        return;
      }

      if (!await cmg.set_request(59, Utils.lim_0_100(ConnectionManager.Humidity_Controller))) {
        Utils.handleError(context);
        return;
      }

      await cmg.set_request(61, Utils.lim_0_100(ConnectionManager.Min_Day_Humidity));
      await cmg.set_request(63, Utils.lim_0_100(ConnectionManager.Min_Night_Humidity));
      await cmg.set_request(60, Utils.lim_0_100(ConnectionManager.Max_Day_Humidity));
      await cmg.set_request(62, Utils.lim_0_100(ConnectionManager.Max_Night_Humidity));
    } catch (e) {
      Utils.alert(context, "Error", "please check your input and try again.");
    }
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 64),
      child: humidity_fragment(),
    );
  }
}
