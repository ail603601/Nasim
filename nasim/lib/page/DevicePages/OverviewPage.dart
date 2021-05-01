import 'package:flutter/material.dart';

class OverviePage extends StatefulWidget {
  @override
  _OverviePageState createState() => _OverviePageState();
}

class _OverviePageState extends State<OverviePage> {
  List<Widget> build_text_row({title, value, String suffix = "°C"}) => [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
          child: Row(
            children: [
              Expanded(child: Text(title, style: Theme.of(context).textTheme.headline6)),
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
            ...build_text_row(title: "Room Temperature", value: "25"),
            ...build_text_row(title: "Outdoor Temperature", value: "33"),
            ...build_text_row(title: "Negative Pressure", value: "-50", suffix: 'hpa'),
            ...build_text_row(title: "HUmiditoy", value: "15", suffix: '%'),
            ...build_text_row(title: "IAQ", value: "50", suffix: 'ppm'),
            ...build_text_row(title: "Co2", value: "50", suffix: 'ppm'),
            ...build_text_row(title: "Light level", value: "30", suffix: 'Lux'),
            ...build_text_row(title: "Inlet Fan Speed", value: "15", suffix: '%'),
            ...build_text_row(title: "Inlet Fan Power", value: "45", suffix: 'W'),
            ...build_text_row(title: "Outlet Fan Speed", value: "65", suffix: '%'),
            ...build_text_row(title: "Outlet Fan Power", value: "80", suffix: 'W'),
            ...build_text_row(title: "Cooler", value: "On", suffix: ''),
            ...build_text_row(title: "Heater", value: "Off", suffix: ''),
            ...build_text_row(title: "Air Purifier", value: "Off", suffix: ''),
            ...build_text_row(title: "Humidity Controller", value: "Off", suffix: ''),
          ]),
        )));
  }
}
