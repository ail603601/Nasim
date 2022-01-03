import 'dart:async';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nasim/IntroductionScreen/introduction_screen.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils.dart';

class wpage_air_quality extends StatefulWidget {
  @override
  wpage_air_qualityState createState() => wpage_air_qualityState();

  bool Function()? Next = null;
  bool Function()? Back = null;
}

class wpage_air_qualityState extends State<wpage_air_quality> with SingleTickerProviderStateMixin {
  late ConnectionManager cmg;
  TabController? _tabController;
  static bool is_night_set = false;
  static bool is_day_set = false;

  late Timer soft_reftresh_timer;

  final TextEditingController max_iaq_controller = TextEditingController();
  final TextEditingController min_iaq_controller = TextEditingController();
  final TextEditingController max_co2_controller = TextEditingController();
  final TextEditingController min_co2_controller = TextEditingController();

  String Old_Max_Day_IAQ = "";
  String Old_Min_Day_IAQ = "";
  String Old_Max_Night_IAQ = "";
  String Old_Min_Night_IAQ = "";
  String Old_Max_Day_CO2 = "";
  String Old_Min_Day_CO2 = "";
  String Old_Max_Night_CO2 = "";
  String Old_Min_Night_CO2 = "";
  String Old_IAQ_Flag = "";
  String Old_CO2_Flag = "";
  bool MODIFIED = false;
  bool check_modification() {
    if (is_night) {
      if (Old_Max_Night_IAQ == max_iaq_controller.text &&
          Old_Min_Night_IAQ == min_iaq_controller.text &&
          Old_Max_Night_CO2 == max_co2_controller.text &&
          Old_Min_Night_CO2 == min_co2_controller.text) {
        MODIFIED = false;
      } else
        MODIFIED = true;
    } else {
      if (Old_Max_Day_IAQ == max_iaq_controller.text &&
          Old_Min_Day_IAQ == min_iaq_controller.text &&
          Old_Max_Day_CO2 == max_co2_controller.text &&
          Old_Min_Day_CO2 == min_co2_controller.text) {
        MODIFIED = false;
      } else
        MODIFIED = true;
    }

    return MODIFIED;
  }

  refresh() async {
    await Utils.show_loading_timed(
        context: context,
        done: () async {
          ConnectionManager.Max_Day_IAQ = (int.tryParse(await cmg.getRequest(65, context)) ?? 0).toString();
          ConnectionManager.Min_Day_IAQ = (int.tryParse(await cmg.getRequest(66, context)) ?? 0).toString();
          ConnectionManager.Max_Night_IAQ = (int.tryParse(await cmg.getRequest(67, context)) ?? 0).toString();
          ConnectionManager.Min_Night_IAQ = (int.tryParse(await cmg.getRequest(68, context)) ?? 0).toString();
          ConnectionManager.Max_Day_CO2 = (int.tryParse(await cmg.getRequest(70, context)) ?? 0).toString();
          ConnectionManager.Min_Day_CO2 = (int.tryParse(await cmg.getRequest(71, context)) ?? 0).toString();
          ConnectionManager.Max_Night_CO2 = (int.tryParse(await cmg.getRequest(72, context)) ?? 0).toString();
          ConnectionManager.Min_Night_CO2 = (int.tryParse(await cmg.getRequest(73, context)) ?? 0).toString();
          ConnectionManager.IAQ_Flag = (int.tryParse(await cmg.getRequest(64, context)) ?? 0).toString();
          ConnectionManager.CO2_Flag = (int.tryParse(await cmg.getRequest(69, context)) ?? 0).toString();
          radio_gid = ConnectionManager.IAQ_Flag == "1" ? 0 : 1;
          radio_gid = ConnectionManager.CO2_Flag == "1" ? 1 : 0;

          Old_Max_Day_IAQ = ConnectionManager.Max_Day_IAQ;
          Old_Min_Day_IAQ = ConnectionManager.Min_Day_IAQ;
          Old_Max_Night_IAQ = ConnectionManager.Max_Night_IAQ;
          Old_Min_Night_IAQ = ConnectionManager.Min_Night_IAQ;
          Old_Max_Day_CO2 = ConnectionManager.Max_Day_CO2;
          Old_Min_Day_CO2 = ConnectionManager.Min_Day_CO2;
          Old_Max_Night_CO2 = ConnectionManager.Max_Night_CO2;
          Old_Min_Night_CO2 = ConnectionManager.Min_Night_CO2;

          if (mounted)
            setState(() {
              if (is_night) {
                max_iaq_controller.text = ConnectionManager.Max_Night_IAQ;
                min_iaq_controller.text = ConnectionManager.Min_Night_IAQ;
                max_co2_controller.text = ConnectionManager.Max_Night_CO2;
                min_co2_controller.text = ConnectionManager.Min_Night_CO2;
              } else {
                max_iaq_controller.text = ConnectionManager.Max_Day_IAQ;
                min_iaq_controller.text = ConnectionManager.Min_Day_IAQ;
                max_co2_controller.text = ConnectionManager.Max_Day_CO2;
                min_co2_controller.text = ConnectionManager.Min_Day_CO2;
              }
            });
        });
  }

  apply() async {
    try {
      if (is_night) {
        ConnectionManager.Max_Night_IAQ = (int.tryParse(max_iaq_controller.text) ?? 0).toString();
        ConnectionManager.Min_Night_IAQ = (int.tryParse(min_iaq_controller.text) ?? 0).toString();
        ConnectionManager.Max_Night_CO2 = (int.tryParse(max_co2_controller.text) ?? 0).toString();
        ConnectionManager.Min_Night_CO2 = (int.tryParse(min_co2_controller.text) ?? 0).toString();

        if (radio_gid == 0) {
          if (int.parse(ConnectionManager.Min_Night_IAQ) + 20 > int.parse(ConnectionManager.Max_Night_IAQ)) {
            Utils.alert(context, "Error", "IAQ maximum must be 20ppm higher than minimum");
            return;
          }
        } else {
          if (int.parse(ConnectionManager.Min_Night_CO2) + 100 > int.parse(ConnectionManager.Max_Night_CO2)) {
            Utils.alert(context, "Error", "CO2 maximum must be 100ppm higher than minimum");
            return;
          }
        }
      } else {
        ConnectionManager.Max_Day_IAQ = (int.tryParse(max_iaq_controller.text) ?? 0).toString();
        ConnectionManager.Min_Day_IAQ = (int.tryParse(min_iaq_controller.text) ?? 0).toString();
        ConnectionManager.Max_Day_CO2 = (int.tryParse(max_co2_controller.text) ?? 0).toString();
        ConnectionManager.Min_Day_CO2 = (int.tryParse(min_co2_controller.text) ?? 0).toString();
        if (radio_gid == 0) {
          if (int.parse(ConnectionManager.Min_Day_IAQ) + 20 > int.parse(ConnectionManager.Max_Day_IAQ)) {
            Utils.alert(context, "Error", "IAQ maximum must be 20ppm higher than minimum");
            return;
          }
        } else {
          if (int.parse(ConnectionManager.Min_Day_CO2) + 100 > int.parse(ConnectionManager.Max_Day_CO2)) {
            Utils.alert(context, "Error", "CO2 maximum must be 100ppm higher than minimum");
            return;
          }
        }
      }
      MODIFIED = false;
      if (_tabController!.index == 0) {
        await cmg.setRequest(65, Utils.lim_0_9999(ConnectionManager.Max_Day_IAQ), context);
        await cmg.setRequest(66, Utils.lim_0_9999(ConnectionManager.Min_Day_IAQ), context);
        await cmg.setRequest(70, Utils.lim_0_9999(ConnectionManager.Max_Day_CO2), context);
        await cmg.setRequest(71, Utils.lim_0_9999(ConnectionManager.Min_Day_CO2), context);
        if (!is_night_set) {
          //night same as day
          await cmg.setRequest(67, Utils.lim_0_9999(ConnectionManager.Max_Day_IAQ), context);
          await cmg.setRequest(68, Utils.lim_0_9999(ConnectionManager.Min_Day_IAQ), context);
          await cmg.setRequest(72, Utils.lim_0_9999(ConnectionManager.Max_Day_CO2), context);
          await cmg.setRequest(73, Utils.lim_0_9999(ConnectionManager.Min_Day_CO2), context);
        }
      } else {
        await cmg.setRequest(67, Utils.lim_0_9999(ConnectionManager.Max_Night_IAQ), context);
        await cmg.setRequest(68, Utils.lim_0_9999(ConnectionManager.Min_Night_IAQ), context);
        await cmg.setRequest(72, Utils.lim_0_9999(ConnectionManager.Max_Night_CO2), context);
        await cmg.setRequest(73, Utils.lim_0_9999(ConnectionManager.Min_Night_CO2), context);
      }

      await cmg.setRequest(64, radio_gid == 0 ? "1" : "0", context);
      await cmg.setRequest(69, radio_gid == 0 ? "0" : "1", context);

      if (_tabController!.index == 0) {
        is_day_set = true;
        _tabController!.animateTo(1);
      } else if (_tabController!.index == 1) {
        is_night_set = true;
        IntroductionScreenState.force_next();
        return;
      }
    } catch (e) {
      // if (!(e is FormatException)) Utils.alert(context, "Error", "please check your input and try again.");
    }
  }

  @override
  void initState() {
    widget.Back = () {
      if (_tabController!.index == 1) {
        _tabController!.animateTo(0);
        return false;
      }
      return true;
    };
    widget.Next = () {
      if (MODIFIED) {
        Utils.alert(context, "", "Please apply.");
        return false;
      }

      if (_tabController!.index == 0) {
        _tabController!.animateTo(1);
        return false;
      }
      return true;
      // if (_tabController!.index == 0) {
      //   if (!is_day_set) {
      //     Utils.alert(context, "", "Please set Day time Air Quality.");
      //     return false;
      //   }
      //   _tabController!.animateTo(1);
      // } else if (_tabController!.index == 1) {
      //   if (!is_day_set) {
      //     Utils.alert(context, "", "Please set Day time Air Quality.");
      //     return false;
      //   }
      //   if (!is_night_set) {
      //     Utils.alert(context, "", "Please set Night time Air Quality.");
      //     return false;
      //   }
      //   return true;
      // }
      // return false;
    };
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
    max_iaq_controller.addListener(() {
      check_modification();
    });
    min_iaq_controller.addListener(() {
      check_modification();
    });
    max_co2_controller.addListener(() {
      check_modification();
    });
    min_co2_controller.addListener(() {
      check_modification();
    });

    Utils.setTimeOut(0, refresh);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController!.dispose();
    soft_reftresh_timer.cancel();
  }

  void soft_refresh() async {
    ConnectionManager.Real_IAQ = (int.tryParse(await cmg.getRequest(92, context)) ?? 0).toString();
    ConnectionManager.Real_CO2 = (int.tryParse(await cmg.getRequest(93, context)) ?? 0).toString();
    if (mounted) setState(() {});
  }

  Widget max_iaq_row() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: Text("Max IAQ", style: Theme.of(context).textTheme.bodyText1)),
            Expanded(
              child: TextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 4,
                style: Theme.of(context).textTheme.bodyText1,
                controller: max_iaq_controller,
                onTap: () => max_iaq_controller.selection = TextSelection(baseOffset: 0, extentOffset: max_iaq_controller.value.text.length),
                keyboardType: TextInputType.numberWithOptions(decimal: false, signed: true),
                decoration: InputDecoration(suffix: Text("ppm", style: Theme.of(context).textTheme.bodyText1), counterText: ""),
              ),
            )
          ],
        ),
      );

  Widget min_iaq_row() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: Text("Min IAQ", style: Theme.of(context).textTheme.bodyText1)),
            Expanded(
              child: TextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 4,
                style: Theme.of(context).textTheme.bodyText1,
                controller: min_iaq_controller,
                onTap: () => min_iaq_controller.selection = TextSelection(baseOffset: 0, extentOffset: min_iaq_controller.value.text.length),
                keyboardType: TextInputType.numberWithOptions(decimal: false, signed: true),
                decoration: InputDecoration(suffix: Text("ppm", style: Theme.of(context).textTheme.bodyText1), counterText: ""),
              ),
            )
          ],
        ),
      );

  //co2
  Widget max_co2_row() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: Text("Max co2", style: Theme.of(context).textTheme.bodyText1)),
            Expanded(
              child: TextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 4,
                style: Theme.of(context).textTheme.bodyText1,
                controller: max_co2_controller,
                onTap: () => max_co2_controller.selection = TextSelection(baseOffset: 0, extentOffset: max_co2_controller.value.text.length),
                keyboardType: TextInputType.numberWithOptions(decimal: false, signed: true),
                decoration: InputDecoration(suffix: Text("ppm", style: Theme.of(context).textTheme.bodyText1), counterText: ""),
              ),
            )
          ],
        ),
      );

  Widget min_co2_row() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: Text("Min co2", style: Theme.of(context).textTheme.bodyText1)),
            Expanded(
              child: TextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 4,
                style: Theme.of(context).textTheme.bodyText1,
                controller: min_co2_controller,
                onTap: () => min_co2_controller.selection = TextSelection(baseOffset: 0, extentOffset: min_co2_controller.value.text.length),
                keyboardType: TextInputType.numberWithOptions(decimal: false, signed: true),
                decoration: InputDecoration(suffix: Text("ppm", style: Theme.of(context).textTheme.bodyText1), counterText: ""),
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
                      if (!is_night) is_night_set = false;
                      if (is_night) is_day_set = false;

                      check_modification();
                    });
                  },
                ),
                labelText: title,
                labelStyle: Theme.of(context).textTheme.bodyText1,
                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow))),
            child: value_id == radio_gid ? child : Center(child: Text("Disabled", style: Theme.of(context).textTheme.bodyText1))));
  }

  Widget build_boxed_infobox({required title, required child}) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new InputDecorator(
            decoration: InputDecoration(
                labelText: title, labelStyle: Theme.of(context).textTheme.bodyText1, border: OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow))),
            child: child));
  }

  Widget build_airquality_inf() => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: build_boxed_infobox(
                title: "Actual IAQ",
                child: Center(child: Text((int.tryParse(ConnectionManager.Real_IAQ) ?? 0).toString() + " ppm", style: Theme.of(context).textTheme.bodyText1)),
              ),
            ),
            Expanded(
                child: build_boxed_infobox(
                    title: "Actual CO2",
                    child:
                        Center(child: Text((int.tryParse(ConnectionManager.Real_CO2) ?? 0).toString() + " ppm", style: Theme.of(context).textTheme.bodyText1))))
          ],
        ),
      );

  bool is_night = false;

  Widget iaq_settings() => Column(children: [
        min_iaq_row(),
        max_iaq_row(),
      ]);
  Widget co2_settings() => Column(children: [
        min_co2_row(),
        max_co2_row(),
      ]);

  build_apply_button() => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 15),
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: OutlinedButton(
            onPressed: MODIFIED ? apply : null,
            style: OutlinedButton.styleFrom(
                padding: EdgeInsets.only(top: 16, bottom: 10, left: 28, right: 28),
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
            onPressed: () {
              AwesomeDialog(
                context: context,
                useRootNavigator: true,
                dialogType: DialogType.WARNING,
                animType: AnimType.BOTTOMSLIDE,
                title: "Confirm",
                desc: "Current Page Settings will be restored to factory defaults",
                btnOkOnPress: () async {
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
            child: Column(
              children: [
                Text("Air Quality", style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 24)),
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
          build_airquality_inf(),
          SizedBox(
            height: 16,
          ),
          Column(mainAxisSize: MainAxisSize.min, children: [
            build_boxed_titlebox(value_id: 0, title: "IAQ Settings", child: iaq_settings()),
            SizedBox(height: 16),
            build_boxed_titlebox(value_id: 1, title: "Co2 Settings", child: co2_settings()),
          ]),
          Expanded(
              child: Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [build_apply_button(), build_reset_button()],
            ),
          )),
          SizedBox(
            height: 64,
          )
        ]));
  }
}
