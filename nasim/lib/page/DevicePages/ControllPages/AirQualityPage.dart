import 'dart:async';

import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/material.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/utils.dart';
import 'package:provider/provider.dart';

class AirQualityPage extends StatefulWidget {
  @override
  _AirQualityPageState createState() => _AirQualityPageState();
}

class _AirQualityPageState extends State<AirQualityPage> {
  late ConnectionManager cmg;
  refresh() async {
    ConnectionManager.Max_Day_IAQ = Utils.int_str(await cmg.getRequest("get41"), ConnectionManager.Max_Day_IAQ);
    ConnectionManager.Min_Day_IAQ = Utils.int_str(await cmg.getRequest("get42"), ConnectionManager.Min_Day_IAQ);
    ConnectionManager.Max_Night_IAQ = Utils.int_str(await cmg.getRequest("get43"), ConnectionManager.Max_Night_IAQ);
    ConnectionManager.Min_Night_IAQ = Utils.int_str(await cmg.getRequest("get44"), ConnectionManager.Min_Night_IAQ);
    ConnectionManager.Max_Day_CO2 = Utils.int_str(await cmg.getRequest("get46"), ConnectionManager.Max_Day_CO2);
    ConnectionManager.Min_Day_CO2 = Utils.int_str(await cmg.getRequest("get47"), ConnectionManager.Min_Day_CO2);
    ConnectionManager.Max_Night_CO2 = Utils.int_str(await cmg.getRequest("get48"), ConnectionManager.Max_Night_CO2);
    ConnectionManager.Min_Night_CO2 = Utils.int_str(await cmg.getRequest("get49"), ConnectionManager.Min_Night_CO2);

    ConnectionManager.IAQ_Flag = Utils.int_str(await cmg.getRequest("get40"), ConnectionManager.IAQ_Flag);
    ConnectionManager.CO2_Flag = Utils.int_str(await cmg.getRequest("get45"), ConnectionManager.CO2_Flag);
    if (is_night) {
      radio_gid = ConnectionManager.IAQ_Flag == "1" ? 0 : 1;
    } else {
      radio_gid = ConnectionManager.CO2_Flag == "1" ? 1 : 0;
    }
    setState(() {});
  }

  apply() async {
    if (!await cmg.set_request(41, Utils.lim_0_100(ConnectionManager.Max_Day_IAQ))) {
      Utils.handleError(context);
      return;
    }

    await cmg.set_request(42, Utils.lim_0_100(ConnectionManager.Min_Day_IAQ));
    await cmg.set_request(43, Utils.lim_0_100(ConnectionManager.Max_Night_IAQ));
    await cmg.set_request(44, Utils.lim_0_100(ConnectionManager.Min_Night_IAQ));
    await cmg.set_request(46, Utils.lim_0_100(ConnectionManager.Max_Day_CO2));
    await cmg.set_request(47, Utils.lim_0_100(ConnectionManager.Min_Day_CO2));
    await cmg.set_request(48, Utils.lim_0_100(ConnectionManager.Max_Night_CO2));
    await cmg.set_request(49, Utils.lim_0_100(ConnectionManager.Min_Night_CO2));

    if (is_night) {
      await cmg.set_request(40, radio_gid == 0 ? "1" : "0");
    } else {
      await cmg.set_request(45, radio_gid == 0 ? "0" : "1");
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
            Expanded(child: Text("Max IAQ")),
            Expanded(
              child: TextField(
                style: Theme.of(context).textTheme.bodyText1,
                controller: TextEditingController()..text = is_night ? ConnectionManager.Max_Day_IAQ : ConnectionManager.Max_Night_IAQ,
                onChanged: (newvalue) {
                  if (is_night) {
                    ConnectionManager.Max_Day_IAQ = newvalue;
                  } else {
                    ConnectionManager.Max_Night_IAQ = newvalue;
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(suffix: Text("ppm")),
              ),
            )
          ],
        ),
      );

  Widget min_iaq_row() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: Text("Min IAQ")),
            Expanded(
              child: TextField(
                style: Theme.of(context).textTheme.bodyText1,
                controller: TextEditingController()..text = is_night ? ConnectionManager.Min_Day_IAQ : ConnectionManager.Min_Night_IAQ,
                onChanged: (newvalue) {
                  if (is_night) {
                    ConnectionManager.Min_Day_IAQ = newvalue;
                  } else {
                    ConnectionManager.Min_Night_IAQ = newvalue;
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(suffix: Text("ppm")),
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
            Expanded(child: Text("Max co2")),
            Expanded(
              child: TextField(
                style: Theme.of(context).textTheme.bodyText1,
                controller: TextEditingController()..text = is_night ? ConnectionManager.Max_Day_CO2 : ConnectionManager.Max_Night_CO2,
                onChanged: (newvalue) {
                  if (is_night) {
                    ConnectionManager.Max_Day_CO2 = newvalue;
                  } else {
                    ConnectionManager.Max_Night_CO2 = newvalue;
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(suffix: Text("ppm")),
              ),
            )
          ],
        ),
      );

  Widget min_co2_row() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: Text("Min co2")),
            Expanded(
              child: TextField(
                style: Theme.of(context).textTheme.bodyText1,
                controller: TextEditingController()..text = is_night ? ConnectionManager.Min_Day_CO2 : ConnectionManager.Min_Night_CO2,
                onChanged: (newvalue) {
                  if (is_night) {
                    ConnectionManager.Min_Day_CO2 = newvalue;
                  } else {
                    ConnectionManager.Min_Night_CO2 = newvalue;
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(suffix: Text("ppm")),
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
                labelStyle: Theme.of(context).textTheme.headline6,
                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow))),
            child: value_id == radio_gid ? child : Center(child: Text("disbaled"))));
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
    return Container(
        color: Theme.of(context).canvasColor,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          build_day_night_switch(),
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
