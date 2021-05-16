import 'dart:async';
import 'dart:math';

import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils.dart';

class wpage_air_quality extends StatefulWidget {
  @override
  _wpage_air_qualityState createState() => _wpage_air_qualityState();
}

class _wpage_air_qualityState extends State<wpage_air_quality> {
  late ConnectionManager cmg;
  refresh() async {
    ConnectionManager.Max_Day_IAQ = Utils.int_str(await cmg.getRequest("get65"), ConnectionManager.Max_Day_IAQ);
    ConnectionManager.Min_Day_IAQ = Utils.int_str(await cmg.getRequest("get66"), ConnectionManager.Min_Day_IAQ);
    ConnectionManager.Max_Night_IAQ = Utils.int_str(await cmg.getRequest("get67"), ConnectionManager.Max_Night_IAQ);
    ConnectionManager.Min_Night_IAQ = Utils.int_str(await cmg.getRequest("get68"), ConnectionManager.Min_Night_IAQ);
    ConnectionManager.Max_Day_CO2 = Utils.int_str(await cmg.getRequest("get70"), ConnectionManager.Max_Day_CO2);
    ConnectionManager.Min_Day_CO2 = Utils.int_str(await cmg.getRequest("get71"), ConnectionManager.Min_Day_CO2);
    ConnectionManager.Max_Night_CO2 = Utils.int_str(await cmg.getRequest("get72"), ConnectionManager.Max_Night_CO2);
    ConnectionManager.Min_Night_CO2 = Utils.int_str(await cmg.getRequest("get73"), ConnectionManager.Min_Night_CO2);

    ConnectionManager.IAQ_Flag = Utils.int_str(await cmg.getRequest("get64"), ConnectionManager.IAQ_Flag);
    ConnectionManager.CO2_Flag = Utils.int_str(await cmg.getRequest("get69"), ConnectionManager.CO2_Flag);

    radio_gid = ConnectionManager.IAQ_Flag == "1" ? 0 : 1;
    radio_gid = ConnectionManager.CO2_Flag == "1" ? 1 : 0;
    setState(() {});
  }

  apply() async {
    try {
      if (is_night) {
        if (radio_gid == 0) {
          if (int.parse(ConnectionManager.Min_Night_IAQ) + 20 > int.parse(ConnectionManager.Max_Night_IAQ)) {
            Utils.alert(context, "Error", "IAQ max and min must have more than 20 differntiate");
            return;
          }
        } else {
          if (int.parse(ConnectionManager.Min_Night_CO2) + 100 > int.parse(ConnectionManager.Max_Night_CO2)) {
            Utils.alert(context, "Error", "CO2 max and min must have more than 100 differntiate");
            return;
          }
        }
      } else {
        if (radio_gid == 0) {
          if (int.parse(ConnectionManager.Min_Day_IAQ) + 20 > int.parse(ConnectionManager.Max_Day_IAQ)) {
            Utils.alert(context, "Error", "IAQ max and min must have more than 20 differntiate");
            return;
          }
        } else {
          if (int.parse(ConnectionManager.Min_Day_CO2) + 100 > int.parse(ConnectionManager.Max_Day_CO2)) {
            Utils.alert(context, "Error", "CO2 max and min must have more than 100 differntiate");
            return;
          }
        }
      }

      if (!await cmg.set_request(65, Utils.lim_0_9999(ConnectionManager.Max_Day_IAQ))) {
        Utils.handleError(context);
        return;
      }

      await cmg.set_request(66, Utils.lim_0_9999(ConnectionManager.Min_Day_IAQ));
      await cmg.set_request(67, Utils.lim_0_9999(ConnectionManager.Max_Night_IAQ));
      await cmg.set_request(68, Utils.lim_0_9999(ConnectionManager.Min_Night_IAQ));
      await cmg.set_request(70, Utils.lim_0_9999(ConnectionManager.Max_Day_CO2));
      await cmg.set_request(71, Utils.lim_0_9999(ConnectionManager.Min_Day_CO2));
      await cmg.set_request(72, Utils.lim_0_9999(ConnectionManager.Max_Night_CO2));
      await cmg.set_request(73, Utils.lim_0_9999(ConnectionManager.Min_Night_CO2));

      await cmg.set_request(64, radio_gid == 0 ? "1" : "0");
      await cmg.set_request(69, radio_gid == 0 ? "0" : "1");
    } catch (e) {
      Utils.alert(context, "Error", "please check your input and try again.");
    }
    refresh();
  }

  @override
  void initState() {
    super.initState();

    cmg = Provider.of<ConnectionManager>(context, listen: false);

    refresh();
  }

  Widget max_iaq_row() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: Text("Max IAQ", style: Theme.of(context).textTheme.bodyText1)),
            Expanded(
              child: TextField(
                style: Theme.of(context).textTheme.bodyText1,
                controller: TextEditingController()..text = !is_night ? ConnectionManager.Max_Day_IAQ : ConnectionManager.Max_Night_IAQ,
                onChanged: (newvalue) {
                  if (is_night) {
                    ConnectionManager.Max_Night_IAQ = newvalue;
                  } else {
                    ConnectionManager.Max_Day_IAQ = newvalue;
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(suffix: Text("ppm", style: Theme.of(context).textTheme.bodyText1)),
              ),
            )
          ],
        ),
      );

  Widget min_iaq_row() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: Text("Min IAQ", style: Theme.of(context).textTheme.bodyText1)),
            Expanded(
              child: TextField(
                style: Theme.of(context).textTheme.bodyText1,
                controller: TextEditingController()..text = !is_night ? ConnectionManager.Min_Day_IAQ : ConnectionManager.Min_Night_IAQ,
                onChanged: (newvalue) {
                  if (is_night) {
                    ConnectionManager.Min_Night_IAQ = newvalue;
                  } else {
                    ConnectionManager.Min_Day_IAQ = newvalue;
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(suffix: Text("ppm", style: Theme.of(context).textTheme.bodyText1)),
              ),
            )
          ],
        ),
      );

  //co2
  Widget max_co2_row() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: Text("Max co2", style: Theme.of(context).textTheme.bodyText1)),
            Expanded(
              child: TextField(
                style: Theme.of(context).textTheme.bodyText1,
                controller: TextEditingController()..text = !is_night ? ConnectionManager.Max_Day_CO2 : ConnectionManager.Max_Night_CO2,
                onChanged: (newvalue) {
                  ConnectionManager.Max_Night_CO2 = newvalue;

                  if (is_night) {
                  } else {
                    ConnectionManager.Max_Day_CO2 = newvalue;
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(suffix: Text("ppm", style: Theme.of(context).textTheme.bodyText1)),
              ),
            )
          ],
        ),
      );

  Widget min_co2_row() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: Text("Min co2", style: Theme.of(context).textTheme.bodyText1)),
            Expanded(
              child: TextField(
                style: Theme.of(context).textTheme.bodyText1,
                controller: TextEditingController()..text = !is_night ? ConnectionManager.Min_Day_CO2 : ConnectionManager.Min_Night_CO2,
                onChanged: (newvalue) {
                  if (is_night) {
                    ConnectionManager.Min_Night_CO2 = newvalue;
                  } else {
                    ConnectionManager.Min_Day_CO2 = newvalue;
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(suffix: Text("ppm", style: Theme.of(context).textTheme.bodyText1)),
              ),
            )
          ],
        ),
      );

  int radio_gid = 0;
  Widget build_boxed_titlebox({required int value_id, required title, required child}) {
    // debugger();
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new InputDecorator(
            decoration: InputDecoration(
                icon: Radio(
                  value: value_id,
                  groupValue: radio_gid,
                  onChanged: (int? value) {
                    setState(() {
                      if (radio_gid != value) radio_gid = value!;
                    });
                  },
                ),
                labelText: title,
                labelStyle: Theme.of(context).textTheme.bodyText1,
                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow))),
            child: value_id == radio_gid ? child : Center(child: Text("disbaled", style: Theme.of(context).textTheme.bodyText1))));
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
  Widget iaq_settings() => Column(children: [
        max_iaq_row(),
        min_iaq_row(),
      ]);
  Widget co2_settings() => Column(children: [max_co2_row(), min_co2_row()]);

  build_apply_button() => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 15),
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: OutlinedButton(
            onPressed: () {
              apply();
            },
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
    return Container(
        padding: const EdgeInsets.only(bottom: 64),
        color: Theme.of(context).canvasColor,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ...make_title("Air Quality"),
          SizedBox(
            height: 16,
          ),
          build_day_night_switch(),
          SizedBox(
            height: 16,
          ),
          build_boxed_titlebox(value_id: 0, title: "IAQ Settings", child: iaq_settings()),
          SizedBox(height: 16),
          build_boxed_titlebox(value_id: 1, title: "Co2 Settings", child: co2_settings()),
          Expanded(
              child: Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [build_apply_button(), build_reset_button()],
            ),
          ))
        ]));
  }
}
