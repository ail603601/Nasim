import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:holding_gesture/holding_gesture.dart';
import 'package:nasim/Model/Device.dart';
import 'package:nasim/Model/menu_info.dart';
import 'package:nasim/enums.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/provider/SavedevicesChangeNofiter.dart';
import 'package:nasim/utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:math';

import '../../../Widgets/MyTooltip.dart';

class AirSpeedPage extends StatefulWidget {
  @override
  _AirSpeedPageState createState() => _AirSpeedPageState();
}

class _AirSpeedPageState extends State<AirSpeedPage> with SingleTickerProviderStateMixin {
  late ConnectionManager cmg;
  double minimum_negative_presure_fan_speed = 0;
  double maximum_negative_presure_fan_speed = 0;
  int real_output_fan_power = 0;
  late Timer soft_reftresh_timer;

  bool is_minimum_set = false;
  bool is_maximum_set = false;

  List<String> fan_power_licenses = ["600 W", "900 W", "1200 W", "1500 W", "1800 W", "2100 W"];

  late String current_license_selected;

  String Old_Min_Valid_Output_Fan_Speed = "";
  String Old_Max_Valid_Output_Fan_Speed = "";
  bool MODIFIED = false;

  bool check_modification() {
    if (Old_Min_Valid_Output_Fan_Speed == minimum_negative_presure_fan_speed.toInt().toString() &&
        Old_Max_Valid_Output_Fan_Speed == maximum_negative_presure_fan_speed.toInt().toString()) {
      MODIFIED = false;
    } else
      MODIFIED = true;
    return MODIFIED;
  }

  void soft_refresh() async {
    ConnectionManager.Elevation = (int.tryParse(await cmg.getRequest(34, context)) ?? "0").toString();
    ConnectionManager.Pressure = (int.tryParse(await cmg.getRequest(35, context)) ?? "0").toString();
    ConnectionManager.Pressure_change = (int.tryParse(await cmg.getRequest(36, context)) ?? "0").toString();
    ConnectionManager.Real_Output_Fan_Power = (int.tryParse(await cmg.getRequest(39, context)) ?? real_output_fan_power).toString();

    if (mounted)
      setState(() {
        real_output_fan_power = int.parse(ConnectionManager.Real_Output_Fan_Power);
      });
  }

  @override
  void initState() {
    super.initState();

    soft_reftresh_timer = Timer.periodic(new Duration(seconds: 1), (timer) async {
      soft_refresh();
    });

    cmg = Provider.of<ConnectionManager>(context, listen: false);

    minimum_negative_presure_fan_speed = (int.tryParse(ConnectionManager.Min_Valid_Output_Fan_Speed) ?? 0.0).toDouble();
    maximum_negative_presure_fan_speed = (int.tryParse(ConnectionManager.Max_Valid_Output_Fan_Speed) ?? 0.0).toDouble();

    _tabController = new TabController(vsync: this, length: tabs.length);

    current_license_selected = fan_power_licenses[0];
    Utils.setTimeOut(0, refresh);
  }

  refresh() async {
    await Utils.show_loading_timed(
        context: context,
        done: () async {
          ConnectionManager.Min_Valid_Output_Fan_Speed = await cmg.getRequest(37, context);
          ConnectionManager.Real_Output_Fan_Power = await cmg.getRequest(39, context);
          ConnectionManager.Pressure_change = await cmg.getRequest(36, context);
          ConnectionManager.Max_Valid_Output_Fan_Speed = await cmg.getRequest(38, context);
          ConnectionManager.Elevation = (int.tryParse(await cmg.getRequest(34, context)) ?? "").toString();
          ConnectionManager.Pressure = (int.tryParse(await cmg.getRequest(35, context)) ?? "").toString();

          if (mounted)
            setState(() {
              real_output_fan_power = (int.tryParse(ConnectionManager.Real_Output_Fan_Power) ?? real_output_fan_power).toInt();

              minimum_negative_presure_fan_speed =
                  (int.tryParse(ConnectionManager.Min_Valid_Output_Fan_Speed) ?? minimum_negative_presure_fan_speed).toDouble();
              maximum_negative_presure_fan_speed =
                  (int.tryParse(ConnectionManager.Max_Valid_Output_Fan_Speed) ?? maximum_negative_presure_fan_speed).toDouble();

              Old_Min_Valid_Output_Fan_Speed = minimum_negative_presure_fan_speed.toInt().toString();
              Old_Max_Valid_Output_Fan_Speed = maximum_negative_presure_fan_speed.toInt().toString();
            });
        });
  }

  bool is_locall_conntection(context) {
    if (SavedDevicesChangeNotifier.getSelectedDevice()!.accessibility == DeviceAccessibility.AccessibleInternet) {
      Utils.setTimeOut(
          0,
          () => Utils.show_error_dialog(context, "Not Available",
                      "You must provide license in order to increase your fan power, but users can't set licenses via internt.", () {})
                  .then((value) {
                // Navigator.pop(context);
              }));
      return false;
    }

    return true;
  }

  int parse_device_fan(int i) {
    if (i == 0) return 300;
    if (i == 1) return 600;
    if (i == 2) return 900;
    if (i == 3) return 1200;
    if (i == 4) return 1500;
    if (i == 5) return 1800;
    if (i == 6) return 2100;

    return 0;
  }

  Future<void> wait_for_fan_power() async {
    await Utils.show_loading(context, () async {
      await Utils.waitMsec(10 * 1000);
    }, title: "Intializing Fan Speed...");

    int device_fan_power = int.tryParse(await cmg.getRequest(3)) ?? 0;
    int output_fan_power = int.tryParse(await cmg.getRequest(39)) ?? 0;
    double fan_speed = _tabController!.index == 0 ? minimum_negative_presure_fan_speed : maximum_negative_presure_fan_speed;

    device_fan_power = parse_device_fan(device_fan_power);

    if (device_fan_power < output_fan_power) {
      if (!is_locall_conntection(context)) return;
      await Utils.ask_license_type_serial(
          context,
          "You must provide license in order to increase your fan power,\nPower limit: ${device_fan_power}W\nOutlet fan power: ${output_fan_power}W for Outlet fan speed: ${fan_speed}%",
          "Fan power limit to:",
          fan_power_licenses,
          fan_power_licenses[0], (String serial, String selected_option) async {
        if (serial != "") {
          int index_selected = fan_power_licenses.indexOf(selected_option);

          ///+1 for being the same
          await cmg.setRequest(76, index_selected.toString(), context);
          bool isvalid = await cmg.setRequest(77, serial);
          if (isvalid) {
            await Utils.alert_license_valid(context);
            Utils.showSnackBar(context, "Done.");
          } else {
            await Utils.alert_license_invalid(context);
          }
        } else {
          return;
        }
      });
    } else
      Utils.showSnackBar(context, "Done.");

    return;
  }

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

  Widget build_boxed_titlebox({required title, required child}) {
    // debugger();
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: new InputDecorator(
            decoration: InputDecoration(
                labelText: title, labelStyle: Theme.of(context).textTheme.bodyText1, border: OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow))),
            child: child));
  }

  Widget build_elevation_presure() => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: build_boxed_titlebox(
                title: "Elevation",
                child: Center(child: Text((int.tryParse(ConnectionManager.Elevation) ?? 0).toString() + " m", style: Theme.of(context).textTheme.bodyText1)),
              ),
            ),
            Expanded(
                child: build_boxed_titlebox(
                    title: "Pressure",
                    child:
                        Center(child: Text((int.tryParse(ConnectionManager.Pressure) ?? 0).toString() + " hpa", style: Theme.of(context).textTheme.bodyText1))))
          ],
        ),
      );

  Future<void> set_air_speed_min_negative_pressure(double value) async {
    ConnectionManager.Min_Valid_Output_Fan_Speed = value.toInt().toString().padLeft(3, '0');
    await cmg.setRequest(37, ConnectionManager.Min_Valid_Output_Fan_Speed, context);
    if (maximum_negative_presure_fan_speed < value + 5) {
      await set_air_speed_max_negative_pressure(value + 5);
    }
    MODIFIED = false;
    is_minimum_set = true;
  }

  Future<void> set_air_speed_max_negative_pressure(double value) async {
    // if (!is_minimum_set) {
    //   await Utils.alert(context, "", "please set minimum fan speed before setting maximum.");
    //   return;
    // }

    if (minimum_negative_presure_fan_speed + 5 > value) {
      await Utils.alert(context, "Error", "Maximum negative fan pressure must be at least 5 percent more than minimum.");
      return;
    }
    ConnectionManager.Max_Valid_Output_Fan_Speed = value.toInt().toString().padLeft(3, '0');
    cmg.setRequest(38, ConnectionManager.Max_Valid_Output_Fan_Speed, context);
    is_maximum_set = true;
    MODIFIED = false;
  }

  build_icon_btn(bool up, Function() clicked) {}

  Widget build_air_speed_min_negative_pressure() {
    return build_boxed_titlebox(
      title: "Minimum Negative Pressure",
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(
          children: [
            MyTooltip(message: "example tooltip", child: Text("Outlet Fan Speed: ", style: Theme.of(context).textTheme.bodyText1)),
            Text(minimum_negative_presure_fan_speed.toString() + " %", style: Theme.of(context).textTheme.bodyText1),
          ],
        ),
        CupertinoSlider(
          value: minimum_negative_presure_fan_speed,
          min: 0.0,
          max: 95.0,
          divisions: 100,
          onChanged: (double newValue) {},
          onChangeEnd: (double newValue) async {},
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Text("Outlet Fan Power: ", style: Theme.of(context).textTheme.bodyText1)),
            Expanded(child: Center(child: Text((real_output_fan_power).toString() + " W", style: Theme.of(context).textTheme.bodyText1)))
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Text("Pressure Change: ", style: Theme.of(context).textTheme.bodyText1)),
            Expanded(
                child: Center(
                    child: Text((int.tryParse(ConnectionManager.Pressure_change) ?? 0).toString() + "hpa", style: Theme.of(context).textTheme.bodyText1)))
          ],
        ),
        SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Expanded(
            child: Material(
              clipBehavior: Clip.hardEdge,
              borderRadius: BorderRadius.circular(5.0),
              child: Ink(
                decoration: const ShapeDecoration(
                  color: Colors.blue,
                  shape: Border(),
                ),
                child: HoldDetector(
                  onHold: () async {
                    setState(() {
                      minimum_negative_presure_fan_speed = min(minimum_negative_presure_fan_speed.roundToDouble() + 2.0, 95);
                      check_modification();
                    });
                  },
                  holdTimeout: Duration(milliseconds: 1000),
                  enableHapticFeedback: true,
                  child: IconButton(
                    icon: Icon(Icons.keyboard_arrow_up),
                    iconSize: 50,
                    color: Colors.white,
                    onPressed: () async {
                      setState(() {
                        minimum_negative_presure_fan_speed = min(minimum_negative_presure_fan_speed.roundToDouble() + 1.0, 95);
                        check_modification();
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 40,
          ),
          Expanded(
            child: Material(
              clipBehavior: Clip.hardEdge,
              borderRadius: BorderRadius.circular(5.0),
              child: Ink(
                decoration: const ShapeDecoration(
                  color: Colors.blue,
                  shape: Border(),
                ),
                child: HoldDetector(
                  onHold: () async {
                    setState(() {
                      minimum_negative_presure_fan_speed = max(minimum_negative_presure_fan_speed.roundToDouble() - 2.0, 0);
                      check_modification();
                    });
                  },
                  holdTimeout: Duration(milliseconds: 1000),
                  enableHapticFeedback: true,
                  child: IconButton(
                    icon: Icon(Icons.keyboard_arrow_down),
                    iconSize: 50,
                    color: Colors.white,
                    onPressed: () async {
                      setState(() {
                        minimum_negative_presure_fan_speed = max(minimum_negative_presure_fan_speed.roundToDouble() - 1.0, 0);
                        check_modification();
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
          // RaisedButton.icon(onPressed: null, icon: null, label: null),
        ])
      ]),
    );
  }

  Widget build_air_speed_max_negative_pressure() {
    return build_boxed_titlebox(
      title: "Maximum Negative Pressure",
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(
          children: [
            MyTooltip(message: "example tooltip", child: Text("Outlet Fan Speed: ", style: Theme.of(context).textTheme.bodyText1)),
            Text(maximum_negative_presure_fan_speed.toString() + " %", style: Theme.of(context).textTheme.bodyText1),
          ],
        ),
        CupertinoSlider(
          value: maximum_negative_presure_fan_speed,
          min: 0.0,
          max: 100.0,
          divisions: 100,
          onChanged: (double newValue) {},
          onChangeEnd: (double newValue) async {},
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Text("Outlet Fan Power: ", style: Theme.of(context).textTheme.bodyText1)),
            Expanded(child: Center(child: Text((real_output_fan_power).toString() + " W", style: Theme.of(context).textTheme.bodyText1)))
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Text("Pressure Change: ", style: Theme.of(context).textTheme.bodyText1)),
            Expanded(
                child: Center(
                    child: Text((int.tryParse(ConnectionManager.Pressure_change) ?? 0).toString() + "hpa", style: Theme.of(context).textTheme.bodyText1)))
          ],
        ),
        SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Expanded(
            child: Material(
              clipBehavior: Clip.hardEdge,
              borderRadius: BorderRadius.circular(5.0),
              child: Ink(
                decoration: const ShapeDecoration(
                  color: Colors.blue,
                  shape: Border(),
                ),
                child: HoldDetector(
                  onHold: () async {
                    setState(() {
                      maximum_negative_presure_fan_speed = min(maximum_negative_presure_fan_speed.roundToDouble() + 2.0, 100);
                      check_modification();
                    });
                  },
                  holdTimeout: Duration(milliseconds: 1000),
                  enableHapticFeedback: true,
                  child: IconButton(
                    icon: Icon(Icons.keyboard_arrow_up),
                    iconSize: 50,
                    color: Colors.white,
                    onPressed: () async {
                      setState(() {
                        maximum_negative_presure_fan_speed = min(maximum_negative_presure_fan_speed.roundToDouble() + 1.0, 100);
                        check_modification();
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 40,
          ),
          Expanded(
            child: Material(
              clipBehavior: Clip.hardEdge,
              borderRadius: BorderRadius.circular(5.0),
              child: Ink(
                decoration: const ShapeDecoration(
                  color: Colors.blue,
                  shape: Border(),
                ),
                child: HoldDetector(
                  onHold: () async {
                    setState(() {
                      maximum_negative_presure_fan_speed = max(maximum_negative_presure_fan_speed.roundToDouble() - 2.0, 0);
                      check_modification();
                    });
                  },
                  holdTimeout: Duration(milliseconds: 1000),
                  enableHapticFeedback: true,
                  child: IconButton(
                    icon: Icon(Icons.keyboard_arrow_down),
                    iconSize: 50,
                    color: Colors.white,
                    onPressed: () async {
                      setState(() {
                        maximum_negative_presure_fan_speed = max(maximum_negative_presure_fan_speed.roundToDouble() - 1.0, 0);
                        check_modification();
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
          // RaisedButton.icon(onPressed: null, icon: null, label: null),
        ])
      ]),
    );
  }

  build_apply_button(click) => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 15),
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: OutlinedButton(
            onPressed: MODIFIED ? click : null,
            style: OutlinedButton.styleFrom(
                padding: EdgeInsets.only(top: 10, bottom: 10, left: 28, right: 28),
                side: BorderSide(width: 2, color: MODIFIED ? Theme.of(context).primaryColor : Colors.grey),
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
            onPressed: () async {
              AwesomeDialog(
                context: context,
                useRootNavigator: true,
                dialogType: DialogType.WARNING,
                animType: AnimType.BOTTOMSLIDE,
                title: "Confirm",
                desc: "Current Page Settings will be restored to factory defaults",
                btnOkOnPress: () async {
                  await cmg.setRequest(128, '1');
                  refresh();
                },
                btnCancelOnPress: () {},
              )..show();
            },
            style: OutlinedButton.styleFrom(
                padding: EdgeInsets.only(top: 16, bottom: 16, left: 28, right: 28),
                side: BorderSide(width: 2, color: Theme.of(context).primaryColor),
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(8.0))),
            child: Text("Restore To Factory Defaults", style: Theme.of(context).textTheme.bodyText1),
          ),
        ),
      );

  TabController? _tabController;

  @override
  void dispose() {
    _tabController!.dispose();
    soft_reftresh_timer.cancel();

    // refresher.cancel();
    super.dispose();
  }

  final List<Tab> tabs = <Tab>[
    new Tab(
      text: "Minimum",
    ),
    new Tab(
      text: "Maximum",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Container(
          color: Colors.black12,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              Text("Outlet Fan", style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 24)),
              Align(
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
                  ),
                  labelStyle: Theme.of(context).textTheme.bodyText1,
                  tabs: tabs,
                  controller: _tabController,
                ),
              ),
            ],
          ),
        ),
        build_elevation_presure(),
        Expanded(
          child: new TabBarView(controller: _tabController, physics: NeverScrollableScrollPhysics(), children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: build_air_speed_min_negative_pressure(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: build_air_speed_max_negative_pressure(),
            )
          ]),
        ),
        build_apply_button(() async {
          if (_tabController!.index == 0) {
            await set_air_speed_min_negative_pressure(minimum_negative_presure_fan_speed);
          } else {
            await set_air_speed_max_negative_pressure(maximum_negative_presure_fan_speed);
          }
          wait_for_fan_power().then((value) {
            refresh();
          });
        }),
        build_reset_button(),
      ],
    ));
  }
}
