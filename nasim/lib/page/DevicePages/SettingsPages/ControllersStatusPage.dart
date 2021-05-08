import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/material.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/utils.dart';
import 'package:provider/provider.dart';

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
    ConnectionManager.Cooler_Controller_Day_Mode = Utils.int_str(await cmg.getRequest("get74"), ConnectionManager.Cooler_Controller_Day_Mode);
    ConnectionManager.Cooler_Controller_Night_Mod = Utils.int_str(await cmg.getRequest("get75"), ConnectionManager.Cooler_Controller_Night_Mod);
    ConnectionManager.Heater_Controller_Day_Mode = Utils.int_str(await cmg.getRequest("get76"), ConnectionManager.Heater_Controller_Day_Mode);
    ConnectionManager.Heater_Controller_Night_Mode = Utils.int_str(await cmg.getRequest("get77"), ConnectionManager.Heater_Controller_Night_Mode);
    ConnectionManager.Humidity_Controller_Day_Mode = Utils.int_str(await cmg.getRequest("get78"), ConnectionManager.Humidity_Controller_Day_Mode);
    ConnectionManager.Humidity_Controller_Night_Mode = Utils.int_str(await cmg.getRequest("get79"), ConnectionManager.Humidity_Controller_Night_Mode);
    ConnectionManager.Air_Purifier_Controller_Day_Mode = Utils.int_str(await cmg.getRequest("get80"), ConnectionManager.Air_Purifier_Controller_Day_Mode);
    ConnectionManager.Air_Purifier_Controller_Night_Mode = Utils.int_str(await cmg.getRequest("get81"), ConnectionManager.Air_Purifier_Controller_Night_Mode);
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
    if (!await cmg.set_request(74, Utils.lim_0_100(ConnectionManager.Cooler_Controller_Day_Mode))) {
      Utils.handleError(context);
      return;
    }

    await cmg.set_request(75, Utils.lim_0_100(ConnectionManager.Cooler_Controller_Night_Mod));
    await cmg.set_request(76, Utils.lim_0_100(ConnectionManager.Heater_Controller_Day_Mode));
    await cmg.set_request(77, Utils.lim_0_100(ConnectionManager.Heater_Controller_Night_Mode));
    await cmg.set_request(78, Utils.lim_0_100(ConnectionManager.Humidity_Controller_Day_Mode));
    await cmg.set_request(79, Utils.lim_0_100(ConnectionManager.Humidity_Controller_Night_Mode));
    await cmg.set_request(80, Utils.lim_0_100(ConnectionManager.Air_Purifier_Controller_Day_Mode));
    await cmg.set_request(81, Utils.lim_0_100(ConnectionManager.Air_Purifier_Controller_Night_Mode));
  }

  bool cooler_mod_val = false;
  List<Widget> cooler_mod() => [
        SwitchListTile(
          title: Text("Cooler Controller"),
          onChanged: (value) {
            if (is_night)
              ConnectionManager.Cooler_Controller_Night_Mod = value ? "1" : "0";
            else
              ConnectionManager.Cooler_Controller_Day_Mode = value ? "1" : "0";

            setState(() {
              cooler_mod_val = value;
            });
            apply();
          },
          value: cooler_mod_val,
        ),
        Divider(
          height: 2,
          thickness: 2,
        )
      ];

  bool heater_mod_val = false;
  List<Widget> heater_mod() => [
        SwitchListTile(
          title: Text("Heater Controller"),
          onChanged: (value) {
            if (is_night)
              ConnectionManager.Heater_Controller_Night_Mode = value ? "1" : "0";
            else
              ConnectionManager.Heater_Controller_Day_Mode = value ? "1" : "0";

            setState(() {
              heater_mod_val = value;
            });
            apply();
          },
          value: heater_mod_val,
        ),
        Divider(
          height: 2,
          thickness: 2,
        )
      ];

  bool humidity_mod_val = false;
  List<Widget> humidity_mod() => [
        SwitchListTile(
          title: Text("Humidity Controller"),
          onChanged: (value) {
            if (is_night)
              ConnectionManager.Humidity_Controller_Night_Mode = value ? "1" : "0";
            else
              ConnectionManager.Humidity_Controller_Day_Mode = value ? "1" : "0";

            setState(() {
              humidity_mod_val = value;
            });
            apply();
          },
          value: humidity_mod_val,
        ),
        Divider(
          height: 2,
          thickness: 2,
        )
      ];

  bool ap_mod_val = false;
  List<Widget> ap_mod() => [
        SwitchListTile(
          title: Text("Air Purifier Controller"),
          onChanged: (value) {
            if (is_night)
              ConnectionManager.Air_Purifier_Controller_Night_Mode = value ? "1" : "0";
            else
              ConnectionManager.Air_Purifier_Controller_Day_Mode = value ? "1" : "0";

            setState(() {
              ap_mod_val = value;
            });
            apply();
          },
          value: ap_mod_val,
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
