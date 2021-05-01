import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/material.dart';

class ControllersStatusPage extends StatefulWidget {
  @override
  _ControllersStatusPageState createState() => _ControllersStatusPageState();
}

class _ControllersStatusPageState extends State<ControllersStatusPage> {
  bool sml = false;
  List<Widget> buildonoffrow(
    title,
  ) =>
      [
        SwitchListTile(
          title: Text(title),
          onChanged: (value) {
            setState(() {});
          },
          value: sml,
        ),
        Divider(
          height: 2,
          thickness: 2,
        )
      ];

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

  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).canvasColor,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          build_day_night_switch(),
          ...buildonoffrow("Cooler Controller"),
          ...buildonoffrow("Heater Controller"),
          ...buildonoffrow("Humidity Controller"),
          ...buildonoffrow("Air Purifier Controller"),
        ]));
  }
}
