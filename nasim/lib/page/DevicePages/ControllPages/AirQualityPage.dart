import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/material.dart';

class AirQualityPage extends StatefulWidget {
  @override
  _AirQualityPageState createState() => _AirQualityPageState();
}

class _AirQualityPageState extends State<AirQualityPage> {
  Widget build_settings_row({title, ValueChanged<String>? onChanged, String suffix = " °C"}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: Text(title)),
            Expanded(
              child: TextField(
                style: Theme.of(context).textTheme.bodyText1,
                controller: TextEditingController()..text = '20',
                onChanged: onChanged,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(suffix: Text(suffix)),
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
                });
              },
            )
          ]),
        ),
      );
  Widget iaq_settings() => Column(children: [
        build_settings_row(title: "Max. IAQ", suffix: "ppm"),
        build_settings_row(title: "Min. IAQ", suffix: "ppm"),
      ]);
  Widget co2_settings() => Column(children: [
        build_settings_row(title: "Max. Co2", suffix: "ppm"),
        build_settings_row(title: "Min. Co2 ", suffix: "ppm"),
      ]);
  build_apply_button() => Align(
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
