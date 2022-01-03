import 'dart:async';

import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late Timer soft_reftresh_timer;
  final TextEditingController humidity_min_controller = TextEditingController();
  final TextEditingController humidity_max_controller = TextEditingController();
  @override
  void initState() {
    super.initState();

    _tabController = new TabController(vsync: this, length: tabs.length);

    _tabController!.addListener(() {
      is_night = _tabController!.index == 1;
      refresh();
    });
    cmg = Provider.of<ConnectionManager>(context, listen: false);
    soft_reftresh_timer = Timer.periodic(new Duration(seconds: 1), (timer) async {
      soft_refresh();
    });
    humidity_min_controller.addListener(() {
      String value = humidity_min_controller.text;
      if ((int.tryParse(value) ?? 0) > 100) {
        setState(() {
          humidity_min_controller.text = "100";
        });
      }
    });

    humidity_max_controller.addListener(() {
      String value = humidity_max_controller.text;
      if ((int.tryParse(value) ?? 0) > 100) {
        setState(() {
          humidity_min_controller.text = "100";
        });
      }
    });

    Utils.setTimeOut(0, refresh);
  }

  @override
  void dispose() {
    soft_reftresh_timer.cancel();

    super.dispose();
  }

  void soft_refresh() async {
    ConnectionManager.Real_Humidity = await cmg.getRequest(91, context);
    ConnectionManager.Real_Humidity = (int.tryParse(ConnectionManager.Real_Humidity) ?? 0).toString();
    if (mounted) setState(() {});
  }

  refresh() async {
    await Utils.show_loading_timed(
        context: context,
        done: () async {
          ConnectionManager.Humidity_Controller = (int.tryParse(await cmg.getRequest(59, context)) ?? 0).toString();
          ConnectionManager.Min_Day_Humidity = (int.tryParse(await cmg.getRequest(61, context)) ?? 0).toString();
          ConnectionManager.Min_Night_Humidity = (int.tryParse(await cmg.getRequest(63, context)) ?? 0).toString();
          ConnectionManager.Max_Day_Humidity = (int.tryParse(await cmg.getRequest(60, context)) ?? 0).toString();
          ConnectionManager.Max_Night_Humidity = (int.tryParse(await cmg.getRequest(62, context)) ?? 0).toString();

          if (mounted)
            setState(() {
              humidity_controller_radio_gvalue = (int.tryParse(ConnectionManager.Humidity_Controller) ?? 0);

              if (is_night) {
                humidity_min_controller.text = (int.tryParse(ConnectionManager.Min_Night_Humidity) ?? 0).toString();
                humidity_max_controller.text = (int.tryParse(ConnectionManager.Max_Night_Humidity) ?? 0).toString();
              } else {
                humidity_min_controller.text = (int.tryParse(ConnectionManager.Min_Day_Humidity) ?? 0).toString();
                humidity_max_controller.text = (int.tryParse(ConnectionManager.Max_Day_Humidity) ?? 0).toString();
              }
            });
        });
  }

  Widget build_boxed_titlebox({required title, required child}) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new InputDecorator(
            decoration: InputDecoration(
                labelText: title, labelStyle: Theme.of(context).textTheme.bodyText1, border: OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow))),
            child: child));
  }

  int humidity_controller_radio_gvalue = 0;

  Widget row_actual_humidity() => build_boxed_titlebox(
      title: "Actual Humidity: ",
      child: Center(child: Text((int.tryParse(ConnectionManager.Real_Humidity) ?? 0).toString() + " %", style: Theme.of(context).textTheme.bodyText1)));

  Widget row_humidity_min() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: Text("Min: ")),
            Expanded(
              child: TextField(
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 3,
                  style: Theme.of(context).textTheme.bodyText1,
                  controller: humidity_min_controller,
                  onTap: () => humidity_min_controller.selection = TextSelection(baseOffset: 0, extentOffset: humidity_min_controller.value.text.length),

                  // onChanged: (value) {
                  //   humidity_min = Utils.lim_0_100(value);
                  //   if (is_night) {
                  //     ConnectionManager.Min_Night_Humidity = int.parse(humidity_min).toString().padLeft(3, '0');
                  //   } else {
                  //     ConnectionManager.Min_Day_Humidity = int.parse(humidity_min).toString().padLeft(3, '0');
                  //   }
                  //   if (int.parse(humidity_min) == 100) setState(() {});
                  // },
                  keyboardType: TextInputType.numberWithOptions(decimal: false, signed: true),
                  decoration: InputDecoration(suffix: Text(' %'), counterText: "")),
            ),
          ],
        ),
      );
  Widget row_humidity_max() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: Text("Max: ")),
            Expanded(
              child: TextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 3,
                style: Theme.of(context).textTheme.bodyText1,
                controller: humidity_max_controller,
                onTap: () => humidity_max_controller.selection = TextSelection(baseOffset: 0, extentOffset: humidity_max_controller.value.text.length),
                keyboardType: TextInputType.numberWithOptions(decimal: false, signed: true),
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

  Widget humidity_fragment() => Column(
        children: [
          row_humidity_min(),
          row_humidity_max(),
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
            child: Text("Restore To Factory Defaults", style: Theme.of(context).textTheme.bodyText1),
          ),
        ),
      );
  bool is_night = false;

  apply_humidity() async {
    int humidity_min = (int.tryParse(humidity_min_controller.text) ?? 0);
    int humidity_max = (int.tryParse(humidity_max_controller.text) ?? 0);

    if ((humidity_min) + 5 > (humidity_max)) {
      Utils.alert(context, "Error", "Humidity max must be 5 percent more than min.");
      return;
    }

    await cmg.setRequest(59, (ConnectionManager.Humidity_Controller).padLeft(1), context);

    if (_tabController!.index == 0) {
      ConnectionManager.Min_Day_Humidity = (int.tryParse(humidity_min_controller.text) ?? 0).toString();
      ConnectionManager.Max_Day_Humidity = (int.tryParse(humidity_max_controller.text) ?? 0).toString();

      await cmg.setRequest(61, Utils.lim_0_100(ConnectionManager.Min_Day_Humidity), context);
      await cmg.setRequest(60, Utils.lim_0_100(ConnectionManager.Max_Day_Humidity), context);
    } else {
      ConnectionManager.Min_Night_Humidity = (int.tryParse(humidity_min_controller.text) ?? 0).toString();
      ConnectionManager.Max_Night_Humidity = (int.tryParse(humidity_max_controller.text) ?? 0).toString();
      await cmg.setRequest(63, Utils.lim_0_100(ConnectionManager.Min_Night_Humidity), context);
      await cmg.setRequest(62, Utils.lim_0_100(ConnectionManager.Max_Night_Humidity), context);
    }
    Utils.showSnackBar(context, "Done.");
  }

  Widget controller_selector() => build_boxed_titlebox(
      title: "Controller is",
      child: Column(
        children: [
          ListTile(
            title: Text('Humidifier', style: Theme.of(context).textTheme.bodyText1),
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
      text: "Day",
    ),
    new Tab(
      text: "Night",
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
                Text("Humidity", style: Theme.of(context).textTheme.bodyText1),
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
              ],
            ),
          ),
          SizedBox(
            height: 16,
          ),
          row_actual_humidity(),
          SizedBox(
            height: 16,
          ),
          controller_selector(),
          Expanded(
              child: new TabBarView(
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              humidity_fragment(),
              humidity_fragment(),
            ],
          )),
          build_apply_button(() {
            apply_humidity();
          }),
          build_reset_button(),
        ]));
  }
}
