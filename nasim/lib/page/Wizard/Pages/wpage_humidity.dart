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
import '../Wizardpage.dart';

class wpage_humidity extends StatefulWidget {
  @override
  wpage_humidityState createState() => wpage_humidityState();

  bool Function()? Next = null;
  bool Function()? Back = null;
}

class wpage_humidityState extends State<wpage_humidity> with SingleTickerProviderStateMixin {
  late ConnectionManager cmg;
  TabController? _tabController;

  final TextEditingController humidity_min_controller = TextEditingController();
  final TextEditingController humidity_max_controller = TextEditingController();
  late Timer soft_reftresh_timer;

  String Old_Humidity_Controller = "";
  String Old_Min_Day_Humidity = "";
  String Old_Min_Night_Humidity = "";
  String Old_Max_Day_Humidity = "";
  String Old_Max_Night_Humidity = "";

  bool MODIFIED = false;

  bool check_modification() {
    if (is_night) {
      if (Old_Humidity_Controller == ConnectionManager.Humidity_Controller &&
          Old_Min_Night_Humidity == humidity_min_controller.text.toString() &&
          Old_Max_Night_Humidity == humidity_max_controller.text.toString()) {
        MODIFIED = false;
      } else
        MODIFIED = true;
    } else {
      if (Old_Humidity_Controller == ConnectionManager.Humidity_Controller &&
          Old_Min_Day_Humidity == humidity_min_controller.text.toString() &&
          Old_Max_Day_Humidity == humidity_max_controller.text.toString()) {
        MODIFIED = false;
      } else
        MODIFIED = true;
    }
    return MODIFIED;
  }

  @override
  void initState() {
    super.initState();
    humidity_min_controller.addListener(() {
      check_modification();
    });
    humidity_max_controller.addListener(() {
      check_modification();
    });

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
      // if (!MODIFIED) return true;
      // if (_tabController!.index == 0) {
      //   if (!is_day_set) {
      //     Utils.alert(context, "", "Please set Day time Humidity.");
      //     return false;
      //   }
      //   _tabController!.animateTo(1);
      // } else if (_tabController!.index == 1) {
      //   if (!is_day_set) {
      //     Utils.alert(context, "", "Please set night time Humidity.");
      //     return false;
      //   }
      //   if (!is_night_set) {
      //     Utils.alert(context, "", "Please set night time Humidity.");
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

    // Utils.setTimeOut(0, change_selected_humidifier_dialog);
    Utils.setTimeOut(0, refresh);
  }

  @override
  void dispose() {
    super.dispose();
    soft_reftresh_timer.cancel();
    _tabController!.dispose();
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

          Old_Humidity_Controller = ConnectionManager.Humidity_Controller;
          Old_Min_Day_Humidity = ConnectionManager.Min_Day_Humidity;
          Old_Min_Night_Humidity = ConnectionManager.Min_Night_Humidity;
          Old_Max_Day_Humidity = ConnectionManager.Max_Day_Humidity;
          Old_Max_Night_Humidity = ConnectionManager.Max_Night_Humidity;

          if (mounted)
            setState(() {
              Old_Humidity_Controller = (int.tryParse(ConnectionManager.Humidity_Controller) ?? 0).toString();

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

  Widget row_actual_humidity() => build_boxed_titlebox(
      title: "Actual Humidity: ",
      child: Center(child: Text((int.tryParse(ConnectionManager.Real_Humidity) ?? 0).toString() + " %", style: Theme.of(context).textTheme.bodyText1)));

  Widget row_humidity_min() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: MyTooltip(message: "example tooltip 9", child: Text("Min: "))),
            Expanded(
              child: TextField(
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 3,
                  style: Theme.of(context).textTheme.bodyText1,
                  controller: humidity_min_controller,
                  onTap: () => humidity_min_controller.selection = TextSelection(baseOffset: 0, extentOffset: humidity_min_controller.value.text.length),
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
            Expanded(child: MyTooltip(message: "example tooltip 10", child: Text("Max: "))),
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
            onPressed: MODIFIED ? click : null,
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
                  await cmg.setRequest(128, '4');
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
  bool is_night = false;

  apply_humidity() async {
    try {
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

        //night same as day
        await cmg.setRequest(63, Utils.lim_0_100(ConnectionManager.Min_Day_Humidity), context);
        await cmg.setRequest(62, Utils.lim_0_100(ConnectionManager.Max_Day_Humidity), context);
      } else {
        ConnectionManager.Min_Night_Humidity = (int.tryParse(humidity_min_controller.text) ?? 0).toString();
        ConnectionManager.Max_Night_Humidity = (int.tryParse(humidity_max_controller.text) ?? 0).toString();
        await cmg.setRequest(63, Utils.lim_0_100(ConnectionManager.Min_Night_Humidity), context);
        await cmg.setRequest(62, Utils.lim_0_100(ConnectionManager.Max_Night_Humidity), context);
      }

      MODIFIED = false;
      if (_tabController!.index == 0) {
        _tabController!.animateTo(1);

        return;
      } else if (_tabController!.index == 1) {
        IntroductionScreenState.force_next();
      }
    } catch (e) {}
  }

  Widget controller_selector() {
    String controller = ConnectionManager.Humidity_Controller == "0" ? 'Humidifier' : 'DeHumidifier';
    return build_boxed_titlebox(
        title: "Selected Controller is",
        child: ListTile(
            title: Text(controller, style: Theme.of(context).textTheme.bodyText1),
            trailing: FlatButton(
                onPressed: () {
                  change_selected_humidifier_dialog();
                },
                child: Text("Change", style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.red)))));
  }

  Future<void> change_selected_humidifier_dialog() async {
    switch (await showDialog<int>(
        context: context,
        useRootNavigator: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('Select Humidity Controller', style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 18)),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0); //Humidifier
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Humidifier', style: Theme.of(context).textTheme.bodyText1),
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1); //DeHumidifier
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('DeHumidifier', style: Theme.of(context).textTheme.bodyText1),
                ),
              ),
            ],
          );
        })) {
      case 0:
        // Humidifier
        setState(() {
          ConnectionManager.Humidity_Controller = "0"; //means humidifer
          check_modification();
        });
        break;
      case 1:
        // DeHumidifier
        setState(() {
          ConnectionManager.Humidity_Controller = "1"; //means humidifer
          check_modification();
        });
        break;
      case null:
        // dialog dismissed
        break;
    }
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
                Text("Humidity", style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 24)),
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
          SizedBox(
            height: 64,
          )
        ]));
  }
}
