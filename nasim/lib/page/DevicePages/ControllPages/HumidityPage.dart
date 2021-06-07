import 'dart:async';

import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:holding_gesture/holding_gesture.dart';
import 'package:nasim/Model/Device.dart';
import 'package:nasim/Model/menu_info.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/utils.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class HumidityPage extends StatefulWidget {
  @override
  _HumidityPageState createState() => _HumidityPageState();
}

class _HumidityPageState extends State<HumidityPage> with SingleTickerProviderStateMixin {
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
    super.dispose();
  }

  refresh() async {
    await Utils.show_loading_timed(
        context: context,
        done: () async {
          ConnectionManager.Humidity_Controller = await cmg.getRequest("get59");
          ConnectionManager.Min_Day_Humidity = await cmg.getRequest("get61");
          ConnectionManager.Min_Night_Humidity = await cmg.getRequest("get63");
          ConnectionManager.Max_Day_Humidity = await cmg.getRequest("get60");
          ConnectionManager.Max_Night_Humidity = await cmg.getRequest("get62");

          if (mounted)
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
  Widget row_humidity_min(value) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: Text("Min: ")),
            Expanded(
              child: TextField(
                  maxLength: 3,
                  style: Theme.of(context).textTheme.bodyText1,
                  controller: TextEditingController()..text = value,
                  onChanged: (value) {
                    humidity_min = Utils.lim_0_100(value);
                    if (is_night) {
                      ConnectionManager.Min_Night_Humidity = int.parse(humidity_min).toString().padLeft(3, '0');
                    } else {
                      ConnectionManager.Min_Day_Humidity = int.parse(humidity_min).toString().padLeft(3, '0');
                    }
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(suffix: Text(' %'), counterText: "")),
            ),
          ],
        ),
      );
  String humidity_max = "";
  Widget row_humidity_max(value) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: Text("Max: ")),
            Expanded(
              child: TextField(
                maxLength: 3,
                style: Theme.of(context).textTheme.bodyText1,
                controller: TextEditingController()..text = value,
                onChanged: (value) {
                  humidity_max = Utils.lim_0_100(value);
                  if (is_night) {
                    ConnectionManager.Max_Night_Humidity = int.parse(humidity_max).toString().padLeft(3, '0');
                  } else {
                    ConnectionManager.Max_Day_Humidity = int.parse(humidity_max).toString().padLeft(3, '0');
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(suffix: Text(' %'), counterText: ""),
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

  Widget humidity_fragment_night() => Column(
        children: [
          row_humidity_min((int.tryParse(ConnectionManager.Min_Night_Humidity) ?? 0).toString()),
          row_humidity_max((int.tryParse(ConnectionManager.Max_Night_Humidity) ?? 0).toString()),
        ],
      );

  Widget humidity_fragment_day() => Column(
        children: [
          row_humidity_min((int.tryParse(ConnectionManager.Min_Day_Humidity) ?? 0).toString()),
          row_humidity_max((int.tryParse(ConnectionManager.Max_Day_Humidity) ?? 0).toString()),
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

  apply_humidity() async {
    try {
      if (int.parse(humidity_min) + 5 >= int.parse(humidity_max)) {
        Utils.alert(context, "Error", "Humidity min and max must have more than 5 diffrentiate , and be positive.");
        return;
      }

      if (!await cmg.set_request(59, (ConnectionManager.Humidity_Controller).padLeft(1))) {
        Utils.handleError(context);
        return;
      }

      await cmg.set_request(61, Utils.lim_0_100(ConnectionManager.Min_Day_Humidity));
      await cmg.set_request(63, Utils.lim_0_100(ConnectionManager.Min_Night_Humidity));
      await cmg.set_request(60, Utils.lim_0_100(ConnectionManager.Max_Day_Humidity));
      await cmg.set_request(62, Utils.lim_0_100(ConnectionManager.Max_Night_Humidity));

      Utils.showSnackBar(context, "Done.");
      if (_tabController!.index == 0) {
        await refresh();

        return;
      } else if (_tabController!.index == 1) {
        await refresh();
      }
    } catch (e) {
      Utils.alert(context, "Error", "please check your input and try again.");
    }
  }

  Widget controller_selector() => build_boxed_titlebox(
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
      ));

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
                Expanded(child: Text("Himudity", style: Theme.of(context).textTheme.bodyText1)),
              ],
            ),
          ),
          SizedBox(
            height: 16,
          ),
          controller_selector(),
          Expanded(
              child: new TabBarView(
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              humidity_fragment_day(),
              humidity_fragment_night(),
            ],
          )),
          build_apply_button(() {
            apply_humidity();
          }),
          build_reset_button(),
        ]));
  }
}