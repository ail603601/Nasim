import 'dart:async';
import 'dart:math';

import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/material.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:provider/provider.dart';

import '../../../utils.dart';

class TemperaturePage extends StatefulWidget {
  @override
  _TemperaturePageState createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> with SingleTickerProviderStateMixin {
  late ConnectionManager cmg;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: tabs.length);

    _tabController!.addListener(() {
      is_night = _tabController!.index == 1;
      // refresh();
    });

    cmg = Provider.of<ConnectionManager>(context, listen: false);

    Utils.setTimeOut(0, refresh);
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  refresh() async {
    await Utils.show_loading_timed(
        context: context,
        done: () async {
          ConnectionManager.Favourite_Room_Temp_Day_ = await cmg.getRequest("get47");
          ConnectionManager.Favourite_Room_Temp_Night = await cmg.getRequest("get53");
          ConnectionManager.Room_Temp_Sensitivity_Day = await cmg.getRequest("get48");
          ConnectionManager.Room_Temp_Sensitivity_Night = await cmg.getRequest("get54");
          ConnectionManager.Cooler_Start_Temp_Day = await cmg.getRequest("get49");
          ConnectionManager.Cooler_Start_Temp_Night = await cmg.getRequest("get55");
          ConnectionManager.Cooler_Stop_Temp_Day = await cmg.getRequest("get50");
          ConnectionManager.Cooler_Stop_Temp_Night = await cmg.getRequest("get56");
          ConnectionManager.Heater_Start_Temp_Day = await cmg.getRequest("get51");
          ConnectionManager.Heater_Start_Temp_Night = await cmg.getRequest("get57");
          ConnectionManager.Heater_Stop_Temp_Day = await cmg.getRequest("get52");
          ConnectionManager.Heater_Stop_Temp_Night = await cmg.getRequest("get58");

          if (mounted)
            setState(() {
              if (is_night) {
                room_temp = (int.tryParse(ConnectionManager.Favourite_Room_Temp_Night) ?? 0).toString();
                room_temp_sensivity = ((double.tryParse(ConnectionManager.Room_Temp_Sensitivity_Night) ?? 0.0)).toString();
                cooler_start_temp = (int.tryParse(ConnectionManager.Cooler_Start_Temp_Night) ?? 0).toString();
                cooler_stop_temp = (int.tryParse(ConnectionManager.Cooler_Stop_Temp_Night) ?? 0).toString();
                heater_start_temp = (int.tryParse(ConnectionManager.Heater_Start_Temp_Night) ?? 0).toString();
                heater_stop_temp = (int.tryParse(ConnectionManager.Heater_Stop_Temp_Night) ?? 0).toString();
              } else {
                room_temp = (int.tryParse(ConnectionManager.Favourite_Room_Temp_Day_) ?? 0).toString();
                room_temp_sensivity = ((double.tryParse(ConnectionManager.Room_Temp_Sensitivity_Day) ?? 0.0)).toString();
                cooler_start_temp = (int.tryParse(ConnectionManager.Cooler_Start_Temp_Day) ?? 0).toString();
                cooler_stop_temp = (int.tryParse(ConnectionManager.Cooler_Stop_Temp_Day) ?? 0).toString();
                heater_start_temp = (int.tryParse(ConnectionManager.Heater_Start_Temp_Day) ?? 0).toString();
                heater_stop_temp = (int.tryParse(ConnectionManager.Heater_Stop_Temp_Day) ?? 0).toString();
              }
            });
        });
  }

  apply_temp() async {
    try {
      int _room_temp = int.parse(room_temp);
      double _room_temp_sensivity = double.parse(room_temp_sensivity);
      int _cooler_start_temp = int.parse(cooler_start_temp);
      int _cooler_stop_temp = int.parse(cooler_stop_temp);
      int _heater_start_temp = int.parse(heater_start_temp);
      int _heater_stop_temp = int.parse(heater_stop_temp);

      if (!(_cooler_start_temp > _cooler_stop_temp && _cooler_start_temp > (_room_temp + _room_temp_sensivity))) {
        Utils.alert(context, "Error", "cooler start temperature must be higher than favorite room temperature and cooler stop temperature.");
        return;
      }
      if (!(_cooler_stop_temp > (_room_temp + _room_temp_sensivity))) {
        Utils.alert(context, "Error", "cooler stop temperature must be higher than favorite room temperature.");
        return;
      }
      if (!(_room_temp_sensivity > 0)) {
        Utils.alert(context, "Error", "sensivity must be positive.");
        return;
      }
      if (!(_room_temp_sensivity <= 2)) {
        Utils.alert(context, "Error", "sensivity maximum is 2.");
        return;
      }
      if (!(_heater_start_temp < _heater_stop_temp && _heater_start_temp < (_room_temp - _room_temp_sensivity))) {
        Utils.alert(context, "Error", "heater start temperature must be lower than favorite room temperature and heater stop temperature.");
        return;
      }
      if (!(_heater_stop_temp < (_room_temp - _room_temp_sensivity))) {
        Utils.alert(context, "Error", "heater stop temperature must be lower than favorite room temperature.");
        return;
      }

      if (!await cmg.set_request(47, Utils.sign_int_100(ConnectionManager.Favourite_Room_Temp_Day_))) {
        Utils.handleError(context);
        return;
      }
      await cmg.set_request(53, Utils.sign_int_100(ConnectionManager.Favourite_Room_Temp_Night));

      await cmg.set_request(48, (ConnectionManager.Room_Temp_Sensitivity_Day));
      await cmg.set_request(54, (ConnectionManager.Room_Temp_Sensitivity_Night));

      await cmg.set_request(49, Utils.sign_int_100(ConnectionManager.Cooler_Start_Temp_Day));
      await cmg.set_request(55, Utils.sign_int_100(ConnectionManager.Cooler_Start_Temp_Night));
      await cmg.set_request(50, Utils.sign_int_100(ConnectionManager.Cooler_Stop_Temp_Day));
      await cmg.set_request(56, Utils.sign_int_100(ConnectionManager.Cooler_Stop_Temp_Night));
      await cmg.set_request(51, Utils.sign_int_100(ConnectionManager.Heater_Start_Temp_Day));
      await cmg.set_request(57, Utils.sign_int_100(ConnectionManager.Heater_Start_Temp_Night));
      await cmg.set_request(52, Utils.sign_int_100(ConnectionManager.Heater_Stop_Temp_Day));
      await cmg.set_request(58, Utils.sign_int_100(ConnectionManager.Heater_Stop_Temp_Night));

      Utils.showSnackBar(context, "Done.");
      if (_tabController!.index == 0) {
        await refresh();

        return;
      } else if (_tabController!.index == 1) {
        await refresh();

        return;
      }
    } catch (e) {
      Utils.alert(context, "Error", "please check your input and try again.");
    }
    await refresh();
  }

  bool is_night = false;
  // build_day_night_switch() => Container(
  //       color: Color(0xff181818),
  //       child: Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //         child: Row(children: [
  //           Expanded(child: Text("Settings for ${is_night ? "Night" : "Day"} Time ", style: Theme.of(context).textTheme.headline6)),
  //           DayNightSwitcher(
  //             isDarkModeEnabled: is_night,
  //             onStateChanged: (is_night) {
  //               setState(() {
  //                 this.is_night = is_night;
  //                 refresh();
  //               });
  //             },
  //           )
  //         ]),
  //       ),
  //     );

  String room_temp = "";
  Widget row_room_temp(value) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: Text("Room Temp:")),
            Expanded(
              child: TextField(
                maxLength: 4,
                style: Theme.of(context).textTheme.bodyText1,
                controller: TextEditingController()..text = value,
                onChanged: (value) {
                  room_temp = value;
                  if (is_night) {
                    ConnectionManager.Favourite_Room_Temp_Night = int.parse(value).toString().padLeft(3, '0');
                  } else {
                    ConnectionManager.Favourite_Room_Temp_Day_ = int.parse(value).toString().padLeft(3, '0');
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(suffix: Text(' °C'), counterText: ""),
              ),
            )
          ],
        ),
      );

  String room_temp_sensivity = "";
  Widget row_room_temp_sensivity(value) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: Text("Room Temp Sensivity:")),
            Expanded(
              child: TextField(
                maxLength: 4,
                style: Theme.of(context).textTheme.bodyText1,
                controller: TextEditingController()..text = value,
                onChanged: (value) {
                  room_temp_sensivity = value;
                  double val_f = double.parse(value);
                  if (is_night) {
                    ConnectionManager.Room_Temp_Sensitivity_Night = max(0, min((val_f), 2)).toString().padLeft(3, '0');
                  } else {
                    ConnectionManager.Room_Temp_Sensitivity_Day = max(0, min((val_f), 2)).toString().padLeft(3, '0');
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(suffix: Text(' °C'), counterText: ""),
              ),
            )
          ],
        ),
      );

  String cooler_start_temp = "";
  Widget row_cooler_start_temp(value) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: Text("Cooler Start Temp: ")),
            Expanded(
              child: TextField(
                maxLength: 4,
                style: Theme.of(context).textTheme.bodyText1,
                controller: TextEditingController()..text = value,
                onChanged: (value) {
                  cooler_start_temp = value;
                  if (is_night) {
                    ConnectionManager.Cooler_Start_Temp_Night = int.parse(value).toString().padLeft(3, '0');
                  } else {
                    ConnectionManager.Cooler_Start_Temp_Day = int.parse(value).toString().padLeft(3, '0');
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(suffix: Text(' °C'), counterText: ""),
              ),
            )
          ],
        ),
      );
  String cooler_stop_temp = "";
  Widget row_cooler_stop_temp(value) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: Text("Cooler Stop Temp: ")),
            Expanded(
              child: TextField(
                maxLength: 4,
                style: Theme.of(context).textTheme.bodyText1,
                controller: TextEditingController()..text = value,
                onChanged: (value) {
                  cooler_stop_temp = Utils.lim_0_100(value);
                  if (is_night) {
                    ConnectionManager.Cooler_Stop_Temp_Night = int.parse(cooler_stop_temp).toString().padLeft(3, '0');
                  } else {
                    ConnectionManager.Cooler_Stop_Temp_Day = int.parse(cooler_stop_temp).toString().padLeft(3, '0');
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(suffix: Text(' °C'), counterText: ""),
              ),
            )
          ],
        ),
      );
  String heater_start_temp = "";
  Widget row_heater_start_temp(value) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: Text("Heater Start Temp: ")),
            Expanded(
              child: TextField(
                maxLength: 4,
                style: Theme.of(context).textTheme.bodyText1,
                controller: TextEditingController()..text = value,
                onChanged: (value) {
                  heater_start_temp = Utils.lim_0_100(value);

                  if (is_night) {
                    ConnectionManager.Heater_Start_Temp_Night = int.parse(heater_start_temp).toString().padLeft(3, '0');
                  } else {
                    ConnectionManager.Heater_Start_Temp_Day = int.parse(heater_start_temp).toString().padLeft(3, '0');
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(suffix: Text(' °C'), counterText: ""),
              ),
            )
          ],
        ),
      );
  String heater_stop_temp = "";
  Widget row_heater_stop_temp(value) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: Text("Heater Stop Temp: ")),
            Expanded(
              child: TextField(
                maxLength: 4,
                style: Theme.of(context).textTheme.bodyText1,
                controller: TextEditingController()..text = value,
                onChanged: (value) {
                  heater_stop_temp = Utils.lim_0_100(value);
                  if (is_night) {
                    ConnectionManager.Heater_Stop_Temp_Night = int.parse(heater_stop_temp).toString().padLeft(3, '0');
                  } else {
                    ConnectionManager.Heater_Stop_Temp_Day = int.parse(heater_stop_temp).toString().padLeft(3, '0');
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(suffix: Text(' °C'), counterText: ""),
              ),
            )
          ],
        ),
      );
  Widget temperature_fragment_day() => Column(
        children: [
          row_room_temp(ConnectionManager.Favourite_Room_Temp_Day_),
          row_room_temp_sensivity((double.tryParse(ConnectionManager.Room_Temp_Sensitivity_Day) ?? 0.0).toString()),
          row_cooler_start_temp(ConnectionManager.Cooler_Start_Temp_Day),
          row_cooler_stop_temp(ConnectionManager.Cooler_Stop_Temp_Day),
          row_heater_start_temp(ConnectionManager.Heater_Start_Temp_Day),
          row_heater_stop_temp(ConnectionManager.Heater_Stop_Temp_Day),
        ],
      );
  Widget temperature_fragment_night() => Column(
        children: [
          row_room_temp(ConnectionManager.Favourite_Room_Temp_Night),
          row_room_temp_sensivity((double.tryParse(ConnectionManager.Room_Temp_Sensitivity_Night) ?? 0.0).toString()),
          row_cooler_start_temp(ConnectionManager.Cooler_Start_Temp_Night),
          row_cooler_stop_temp(ConnectionManager.Cooler_Stop_Temp_Night),
          row_heater_start_temp(ConnectionManager.Heater_Start_Temp_Night),
          row_heater_stop_temp(ConnectionManager.Heater_Stop_Temp_Night),
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

  final List<Tab> tabs = <Tab>[
    new Tab(
      text: "Day Time",
    ),
    new Tab(
      text: "Night Time",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(children: [
          Container(
            color: Colors.black12,
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TabBar(
                      isScrollable: false,
                      unselectedLabelColor: Colors.grey,
                      labelColor: Colors.white,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: new BubbleTabIndicator(
                        indicatorHeight: 25.0,
                        indicatorColor: Colors.blueAccent,
                        tabBarIndicatorSize: TabBarIndicatorSize.tab,
                        // Other flags
                        // indicatorRadius: 1,
                        // insets: EdgeInsets.all(1),
                        // padding: EdgeInsets.all(10)
                      ),
                      labelStyle: Theme.of(context).textTheme.bodyText1,
                      tabs: tabs,
                      controller: _tabController,
                    ),
                  ),
                ),
                Expanded(child: Text("Temperature", style: Theme.of(context).textTheme.bodyText1)),
              ],
            ),
          ),
          Expanded(
              child: new TabBarView(
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              temperature_fragment_day(),
              temperature_fragment_night(),
            ],
          )),
          build_apply_button(() {
            apply_temp();
          }),
          build_reset_button(),
        ]));
  }
}
