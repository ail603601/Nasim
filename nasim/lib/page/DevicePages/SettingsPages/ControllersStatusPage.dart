import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/material.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/utils.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

class ControllersStatusPage extends StatefulWidget {
  @override
  _ControllersStatusPageState createState() => _ControllersStatusPageState();
}

class _ControllersStatusPageState extends State<ControllersStatusPage> {
  bool sml = false;
  @override
  void initState() {
    super.initState();

    cmg = Provider.of<ConnectionManager>(context, listen: false);

    refresh();
  }

  late ConnectionManager cmg;
  refresh() async {
    ConnectionManager.Cooler_Controller_Day_Mode = Utils.int_str(await cmg.getRequest(112), ConnectionManager.Cooler_Controller_Day_Mode);
    ConnectionManager.Cooler_Controller_Night_Mod = Utils.int_str(await cmg.getRequest(113), ConnectionManager.Cooler_Controller_Night_Mod);
    ConnectionManager.Heater_Controller_Day_Mode = Utils.int_str(await cmg.getRequest(114), ConnectionManager.Heater_Controller_Day_Mode);
    ConnectionManager.Heater_Controller_Night_Mode = Utils.int_str(await cmg.getRequest(115), ConnectionManager.Heater_Controller_Night_Mode);
    ConnectionManager.Humidity_Controller_Day_Mode = Utils.int_str(await cmg.getRequest(116), ConnectionManager.Humidity_Controller_Day_Mode);
    ConnectionManager.Humidity_Controller_Night_Mode = Utils.int_str(await cmg.getRequest(117), ConnectionManager.Humidity_Controller_Night_Mode);
    ConnectionManager.Air_Purifier_Controller_Day_Mode = Utils.int_str(await cmg.getRequest(118), ConnectionManager.Air_Purifier_Controller_Day_Mode);
    ConnectionManager.Air_Purifier_Controller_Night_Mode = Utils.int_str(await cmg.getRequest(119), ConnectionManager.Air_Purifier_Controller_Night_Mode);
    if (is_night) {
      cooler_mod_val = ConnectionManager.Cooler_Controller_Night_Mod == "1" ? true : false;
      heater_mod_val = ConnectionManager.Heater_Controller_Night_Mode == "1" ? true : false;
      humidity_mod_val = ConnectionManager.Humidity_Controller_Night_Mode == "1" ? true : false;
      ap_mod_val = ConnectionManager.Air_Purifier_Controller_Night_Mode == "1" ? true : false;
    } else {
      cooler_mod_val = ConnectionManager.Cooler_Controller_Day_Mode == "1" ? true : false;
      heater_mod_val = ConnectionManager.Heater_Controller_Day_Mode == "1" ? true : false;
      humidity_mod_val = ConnectionManager.Humidity_Controller_Day_Mode == "1" ? true : false;
      ap_mod_val = ConnectionManager.Air_Purifier_Controller_Day_Mode == "1" ? true : false;
    }

    setState(() {});
  }

  apply() async {
    await cmg.setRequest(112, Utils.lim_0_100(ConnectionManager.Cooler_Controller_Day_Mode), context);
    await cmg.setRequest(113, (ConnectionManager.Cooler_Controller_Night_Mod), context);
    await cmg.setRequest(114, (ConnectionManager.Heater_Controller_Day_Mode), context);
    await cmg.setRequest(115, (ConnectionManager.Heater_Controller_Night_Mode), context);
    await cmg.setRequest(116, (ConnectionManager.Humidity_Controller_Day_Mode), context);
    await cmg.setRequest(117, (ConnectionManager.Humidity_Controller_Night_Mode), context);
    await cmg.setRequest(118, (ConnectionManager.Air_Purifier_Controller_Day_Mode), context);
    await cmg.setRequest(119, (ConnectionManager.Air_Purifier_Controller_Night_Mode), context);
  }

  bool cooler_mod_val = false;
  List<Widget> cooler_mod() {
    return [
      Row(
        children: [
          Expanded(child: Text("Cooler Controller", style: Theme.of(context).textTheme.bodyText1)),
          ToggleSwitch(
            minWidth: 60.0,
            initialLabelIndex: cooler_mod_val ? 1 : 0,
            cornerRadius: 0.0,
            activeFgColor: Colors.white,
            inactiveBgColor: Colors.grey,
            inactiveFgColor: Colors.white,
            activeBgColors: [Colors.blue, Colors.blue],
            labels: ['Off', 'Auto'],
            onToggle: (index) {
              if (is_night)
                ConnectionManager.Cooler_Controller_Night_Mod = index.toString();
              else
                ConnectionManager.Cooler_Controller_Day_Mode = index.toString();
              setState(() {
                cooler_mod_val = index == 1;
              });
              apply();
            },
          ),
        ],
      ),
      Divider(
        height: 2,
        thickness: 2,
      )
    ];
  }

  bool heater_mod_val = false;
  List<Widget> heater_mod() {
    return [
      Row(
        children: [
          Expanded(child: Text("Heater Controller", style: Theme.of(context).textTheme.bodyText1)),
          ToggleSwitch(
            minWidth: 60.0,
            initialLabelIndex: heater_mod_val ? 1 : 0,
            cornerRadius: 0.0,
            activeFgColor: Colors.white,
            inactiveBgColor: Colors.grey,
            inactiveFgColor: Colors.white,
            activeBgColors: [Colors.blue, Colors.blue],
            labels: ['Off', 'Auto'],
            onToggle: (index) {
              if (is_night)
                ConnectionManager.Heater_Controller_Night_Mode = index.toString();
              else
                ConnectionManager.Heater_Controller_Day_Mode = index.toString();
              setState(() {
                heater_mod_val = index == 1;
              });
              apply();
            },
          ),
        ],
      ),
      Divider(
        height: 2,
        thickness: 2,
      )
    ];
  }

  bool humidity_mod_val = false;
  List<Widget> humidity_mod() {
    return [
      Row(
        children: [
          Expanded(child: Text("Humidity Controller", style: Theme.of(context).textTheme.bodyText1)),
          ToggleSwitch(
            minWidth: 60.0,
            initialLabelIndex: humidity_mod_val ? 1 : 0,
            cornerRadius: 0.0,
            activeFgColor: Colors.white,
            inactiveBgColor: Colors.grey,
            inactiveFgColor: Colors.white,
            activeBgColors: [Colors.blue, Colors.blue],
            labels: ['Off', 'Auto'],
            onToggle: (index) {
              if (is_night)
                ConnectionManager.Humidity_Controller_Night_Mode = index.toString();
              else
                ConnectionManager.Humidity_Controller_Day_Mode = index.toString();
              setState(() {
                humidity_mod_val = index == 1;
              });
              apply();
            },
          ),
        ],
      ),
      Divider(
        height: 2,
        thickness: 2,
      )
    ];
  }

  bool ap_mod_val = false;
  List<Widget> ap_mod() {
    return [
      Row(
        children: [
          Expanded(child: Text("Air Purifier Controller", style: Theme.of(context).textTheme.bodyText1)),
          ToggleSwitch(
            minWidth: 60.0,
            initialLabelIndex: ap_mod_val ? 1 : 0,
            cornerRadius: 0.0,
            activeFgColor: Colors.white,
            inactiveBgColor: Colors.grey,
            inactiveFgColor: Colors.white,
            activeBgColors: [Colors.blue, Colors.blue],
            labels: ['Off', 'Auto'],
            onToggle: (index) {
              if (is_night)
                ConnectionManager.Air_Purifier_Controller_Night_Mode = index.toString();
              else
                ConnectionManager.Air_Purifier_Controller_Day_Mode = index.toString();
              setState(() {
                ap_mod_val = index == 1;
              });
              apply();
            },
          ),
        ],
      ),
      Divider(
        height: 2,
        thickness: 2,
      )
    ];
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

  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).canvasColor,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          build_day_night_switch(),
          ...cooler_mod(),
          ...heater_mod(),
          ...humidity_mod(),
          ...ap_mod(),
        ]));
  }
}
