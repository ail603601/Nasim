import 'dart:async';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nasim/IntroductionScreen/introduction_screen.dart';
import 'package:nasim/Widgets/MyTooltip.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils.dart';
import 'wpage_controller_status.dart';

class wpage_air_quality extends StatefulWidget {
  @override
  wpage_air_qualityState createState() => wpage_air_qualityState();

  bool Function()? Next = null;
  bool Function()? Back = null;
}

class wpage_air_qualityState extends State<wpage_air_quality> with SingleTickerProviderStateMixin {
  late ConnectionManager cmg;
  TabController? _tabController;
  bool is_night_set = false;

  late Timer soft_reftresh_timer;

  final TextEditingController max_controller = TextEditingController();
  final TextEditingController min_controller = TextEditingController();

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
      if (iaq_1_co2_0 == 1) {
        if (Old_Max_Night_IAQ == max_controller.text && Old_Min_Night_IAQ == min_controller.text && iaq_1_co2_0.toString() == Old_IAQ_Flag) {
          MODIFIED = false;
        } else
          MODIFIED = true;
      } else {
        if (Old_Max_Night_CO2 == max_controller.text && Old_Min_Night_CO2 == min_controller.text && iaq_1_co2_0.toString() == Old_IAQ_Flag) {
          MODIFIED = false;
        } else
          MODIFIED = true;
      }
    } else {
      if (iaq_1_co2_0 == 1) {
        if (Old_Max_Day_IAQ == max_controller.text && Old_Min_Day_IAQ == min_controller.text && iaq_1_co2_0.toString() == Old_IAQ_Flag) {
          MODIFIED = false;
        } else
          MODIFIED = true;
      } else {
        if (Old_Max_Day_CO2 == max_controller.text && Old_Min_Day_CO2 == min_controller.text && iaq_1_co2_0.toString() == Old_IAQ_Flag) {
          MODIFIED = false;
        } else
          MODIFIED = true;
      }
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
          iaq_1_co2_0 = ConnectionManager.IAQ_Flag == "1" ? 1 : 0;
          // iaq_1_co2_0 = ConnectionManager.CO2_Flag == "1" ? 0 : 1;

          Old_Max_Day_IAQ = ConnectionManager.Max_Day_IAQ;
          Old_Min_Day_IAQ = ConnectionManager.Min_Day_IAQ;
          Old_Max_Night_IAQ = ConnectionManager.Max_Night_IAQ;
          Old_Min_Night_IAQ = ConnectionManager.Min_Night_IAQ;
          Old_Max_Day_CO2 = ConnectionManager.Max_Day_CO2;
          Old_Min_Day_CO2 = ConnectionManager.Min_Day_CO2;
          Old_Max_Night_CO2 = ConnectionManager.Max_Night_CO2;
          Old_Min_Night_CO2 = ConnectionManager.Min_Night_CO2;
          Old_IAQ_Flag = ConnectionManager.IAQ_Flag;
          Old_CO2_Flag = ConnectionManager.CO2_Flag;
          if (mounted)
            setState(() {
              if (is_night) {
                if (iaq_1_co2_0 == 1) {
                  max_controller.text = ConnectionManager.Max_Night_IAQ;
                  min_controller.text = ConnectionManager.Min_Night_IAQ;
                } else {
                  max_controller.text = ConnectionManager.Max_Night_CO2;
                  min_controller.text = ConnectionManager.Min_Night_CO2;
                }
              } else {
                if (iaq_1_co2_0 == 1) {
                  max_controller.text = ConnectionManager.Max_Day_IAQ;
                  min_controller.text = ConnectionManager.Min_Day_IAQ;
                } else {
                  max_controller.text = ConnectionManager.Max_Day_CO2;
                  min_controller.text = ConnectionManager.Min_Day_CO2;
                }
              }
              check_modification();
            });
        });
  }

  apply() async {
    try {
      if (is_night) {
        if (iaq_1_co2_0 == 1) {
          ConnectionManager.Max_Night_IAQ = (int.tryParse(max_controller.text) ?? 0).toString();
          ConnectionManager.Min_Night_IAQ = (int.tryParse(min_controller.text) ?? 0).toString();
        } else {
          ConnectionManager.Max_Night_CO2 = (int.tryParse(max_controller.text) ?? 0).toString();
          ConnectionManager.Min_Night_CO2 = (int.tryParse(min_controller.text) ?? 0).toString();
        }

        if (iaq_1_co2_0 == 1) {
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
        if (iaq_1_co2_0 == 1) {
          ConnectionManager.Max_Day_IAQ = (int.tryParse(max_controller.text) ?? 0).toString();
          ConnectionManager.Min_Day_IAQ = (int.tryParse(min_controller.text) ?? 0).toString();
        } else {
          ConnectionManager.Max_Day_CO2 = (int.tryParse(max_controller.text) ?? 0).toString();
          ConnectionManager.Min_Day_CO2 = (int.tryParse(min_controller.text) ?? 0).toString();
        }

        if (iaq_1_co2_0 == 1) {
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

      await cmg.setRequest(64, iaq_1_co2_0 == 1 ? "1" : "0", context);
      await cmg.setRequest(69, iaq_1_co2_0 == 0 ? "1" : "0", context);

      if (_tabController!.index == 0) {
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
    super.initState();

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

      //before going to next page, make sure to call next page refresh
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
    _tabController = new TabController(vsync: this, length: tabs.length);

    _tabController!.addListener(() {
      is_night = _tabController!.index == 1;
      refresh();
    });

    cmg = Provider.of<ConnectionManager>(context, listen: false);
    soft_reftresh_timer = Timer.periodic(new Duration(seconds: 1), (timer) async {
      soft_refresh();
    });
    max_controller.addListener(() {
      check_modification();
    });
    min_controller.addListener(() {
      check_modification();
    });

    // Utils.setTimeOut(0, change_selected_iaq_contreller_dialog);

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

  int iaq_1_co2_0 = 0;
  Widget build_boxed_titlebox({required int value_id, required title, required child}) {
    // debugger();
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new InputDecorator(
            decoration: InputDecoration(
                icon: Radio(
                  value: value_id,
                  groupValue: iaq_1_co2_0,
                  onChanged: (int? value) {
                    setState(() {
                      if (iaq_1_co2_0 != value) iaq_1_co2_0 = value!;
                      if (!is_night) is_night_set = false;

                      check_modification();
                    });
                  },
                ),
                labelText: title,
                labelStyle: Theme.of(context).textTheme.bodyText1,
                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow))),
            child: value_id == iaq_1_co2_0 ? child : Center(child: Text("Disabled", style: Theme.of(context).textTheme.bodyText1))));
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
                  await cmg.setRequest(128, '5');

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

  Widget controller_selector() {
    String controller = iaq_1_co2_0 == 1 ? 'IAQ' : 'Co2';
    return build_boxed_infobox(
        title: "Selected Controller is",
        child: ListTile(
            title: Text(controller, style: Theme.of(context).textTheme.bodyText1),
            trailing: FlatButton(
                onPressed: () {
                  change_selected_iaq_contreller_dialog();
                },
                child: Text("Change", style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.red)))));
  }

  Future<void> change_selected_iaq_contreller_dialog() async {
    switch (await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('Select AirQuality Controller', style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 18)),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0); //IAQ
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('IAQ', style: Theme.of(context).textTheme.bodyText1),
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1); //Co2
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Co2', style: Theme.of(context).textTheme.bodyText1),
                ),
              ),
            ],
          );
        })) {
      case 0:
        // IAQ
        setState(() {
          iaq_1_co2_0 = 1; //means IAQ
          check_modification();
        });
        break;
      case 1:
        // Co2
        setState(() {
          iaq_1_co2_0 = 0; //means Co2
          check_modification();
        });
        break;
      case null:
        // dialog dismissed
        break;
    }
  }

  Widget row_min() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: MyTooltip(message: "example tooltip 11", child: Text("Min: "))),
            Expanded(
              child: TextField(
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 4,
                  style: Theme.of(context).textTheme.bodyText1,
                  controller: min_controller,
                  onTap: () => min_controller.selection = TextSelection(baseOffset: 0, extentOffset: min_controller.value.text.length),
                  keyboardType: TextInputType.numberWithOptions(decimal: false, signed: true),
                  decoration: InputDecoration(suffix: Text(' ppm'), counterText: "")),
            ),
          ],
        ),
      );
  Widget row_max() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: MyTooltip(message: "example tooltip 12", child: Text("Max: "))),
            Expanded(
              child: TextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 4,
                style: Theme.of(context).textTheme.bodyText1,
                controller: max_controller,
                onTap: () => max_controller.selection = TextSelection(baseOffset: 0, extentOffset: max_controller.value.text.length),
                keyboardType: TextInputType.numberWithOptions(decimal: false, signed: true),
                decoration: InputDecoration(suffix: Text(' ppm'), counterText: ""),
              ),
            )
          ],
        ),
      );

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
            controller_selector(),
            row_min(),
            row_max(),
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
