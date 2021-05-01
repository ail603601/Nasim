import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/material.dart';

class TemperaturePage extends StatefulWidget {
  @override
  _TemperaturePageState createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {
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
                });
              },
            )
          ]),
        ),
      );

  Widget build_temp_row({title, ValueChanged<String>? onChanged, String suffix = " °C"}) => Padding(
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

  Widget temperature_fragment() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            build_day_night_switch(),
            build_temp_row(title: "RoomTemp: "),
            build_temp_row(title: "Cooler Start Temp: "),
            build_temp_row(title: "Cooler Stop Temp: "),
            build_temp_row(title: "Heater Start Temp: "),
            build_temp_row(title: "Heater Stop Temp: "),
            Expanded(
                child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [build_apply_button(), build_reset_button()],
              ),
            ))
          ],
        ),
      );

  int humidity_controller_radio_gvalue = 0;

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
                        });
                      },
                      leading: Radio(
                        value: 0,
                        groupValue: humidity_controller_radio_gvalue,
                        onChanged: (int? value) {
                          setState(() {
                            if (humidity_controller_radio_gvalue != value) humidity_controller_radio_gvalue = value!;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Text('Dehumidifier', style: Theme.of(context).textTheme.headline6),
                      onTap: () {
                        setState(() {
                          if (humidity_controller_radio_gvalue != 1) humidity_controller_radio_gvalue = 1;
                        });
                      },
                      leading: Radio(
                        value: 1,
                        groupValue: humidity_controller_radio_gvalue,
                        onChanged: (int? value) {
                          setState(() {
                            if (humidity_controller_radio_gvalue != value) humidity_controller_radio_gvalue = value!;
                          });
                        },
                      ),
                    ),
                  ],
                )),
            build_temp_row(title: "Min: ", suffix: "%"),
            build_temp_row(title: "Max: ", suffix: "%"),
            Expanded(
                child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [build_apply_button(), build_reset_button()],
              ),
            ))
          ],
        ),
      );
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: TabBar(
          labelStyle: Theme.of(context).textTheme.headline6,
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
