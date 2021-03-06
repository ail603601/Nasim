import 'dart:async';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:holding_gesture/holding_gesture.dart';
import 'package:nasim/Widgets/MyTooltip.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils.dart';
import '../Wizardpage.dart';

class wpage_light extends StatefulWidget {
  @override
  _wpage_lightState createState() => _wpage_lightState();

  bool Function()? Next = null;
  bool Function()? Back = null;
}

class _wpage_lightState extends State<wpage_light> {
  late ConnectionManager cmg;
  static bool is_applied = false;

  late Timer soft_reftresh_timer;

  final TextEditingController max_lux_controller = TextEditingController();
  final TextEditingController min_lux_controller = TextEditingController();

  String Old_Min_Day_Lux = "";
  String Old_Max_Night_Lux = "";

  bool MODIFIED = false;
  bool check_modification() {
    if (Old_Min_Day_Lux == max_lux_controller.text.toString() && Old_Max_Night_Lux == min_lux_controller.text.toString()) {
      MODIFIED = false;
    } else
      MODIFIED = true;
    return MODIFIED;
  }

  refresh() async {
    await Utils.show_loading_timed(
        context: context,
        done: () async {
          ConnectionManager.Min_Day_Lux = (int.tryParse(await cmg.getRequest(74, context)) ?? 0).toString();
          ConnectionManager.Max_Night_Lux = (int.tryParse(await cmg.getRequest(75, context)) ?? 0).toString();

          if (Old_Min_Day_Lux == "") {
            Old_Min_Day_Lux = ConnectionManager.Min_Day_Lux;
            Old_Max_Night_Lux = ConnectionManager.Max_Night_Lux;
          }
          max_lux_controller.text = ConnectionManager.Min_Day_Lux;
          min_lux_controller.text = ConnectionManager.Max_Night_Lux;

          setState(() {});
        });
  }

  void soft_refresh() async {
    ConnectionManager.Real_Light_Level = await cmg.getRequest(94, context);
    ConnectionManager.Real_Light_Level = (int.tryParse(ConnectionManager.Real_Light_Level) ?? 0).toString();
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.Next = () {
      if (MODIFIED) {
        Utils.alert(context, "", "Please apply.");
        return false;
      }
      // WizardPageState.wizardEnded(context);

      return true;
    };
    cmg = Provider.of<ConnectionManager>(context, listen: false);
    soft_reftresh_timer = Timer.periodic(new Duration(seconds: 1), (timer) async {
      soft_refresh();
    });

    max_lux_controller.addListener(() {
      check_modification();
    });
    min_lux_controller.addListener(() {
      check_modification();
    });
    Utils.setTimeOut(0, refresh);
  }

  @override
  void dispose() {
    super.dispose();
    soft_reftresh_timer.cancel();
  }

  apply() async {
    try {
      ConnectionManager.Min_Day_Lux = (int.tryParse(min_lux_controller.text) ?? 0).toString();
      ConnectionManager.Max_Night_Lux = (int.tryParse(max_lux_controller.text) ?? 0).toString();

      if (int.parse(ConnectionManager.Min_Day_Lux) + 50 > int.parse(ConnectionManager.Max_Night_Lux)) {
        Utils.alert(context, "", "Maximum must be 50Lux higher than maximum.");
        return false;
      }

      await cmg.setRequest(74, Utils.lim_0_9999(ConnectionManager.Min_Day_Lux), context);

      await cmg.setRequest(75, Utils.lim_0_9999(ConnectionManager.Max_Night_Lux), context);
      is_applied = true;
      Utils.show_done_dialog(context, "Settings finsihed successfuly.", "Your device is initialized completely and ready to use.", () {
        WizardPageState.wizardEnded(context);
      });
      await refresh();
    } catch (e) {
      // if (!(e is FormatException)) Utils.alert(context, "Error", "please check your input and try again.");
    }
  }

  Widget build_boxed_titlebox({required title, required child}) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new InputDecorator(
            decoration: InputDecoration(
                labelText: title, labelStyle: Theme.of(context).textTheme.bodyText1, border: OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow))),
            child: child));
  }

  Widget row_actual_light_level() => build_boxed_titlebox(
      title: "Actual Light level: ",
      child: Center(child: Text((int.tryParse(ConnectionManager.Real_Light_Level) ?? 0).toString() + " Lux", style: Theme.of(context).textTheme.bodyText1)));

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
        child: HoldDetector(
          onHold: () {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.WARNING,
              animType: AnimType.BOTTOMSLIDE,
              title: "Confirm",
              desc: "Reset all settings to factory defaults?",
              btnOkOnPress: () {},
              btnCancelOnPress: () {},
            )..show();
          },
          holdTimeout: Duration(milliseconds: 10000),
          // enableHapticFeedback: true,
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
                  await cmg.setRequest(128, '8');
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
      ));

  Widget max_lux() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: MyTooltip(message: "example tooltip 13", child: Text("Max Light"))),
            Expanded(
              child: TextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 4,
                style: Theme.of(context).textTheme.bodyText1,
                controller: max_lux_controller,
                onTap: () => max_lux_controller.selection = TextSelection(baseOffset: 0, extentOffset: max_lux_controller.value.text.length),
                keyboardType: TextInputType.numberWithOptions(decimal: false, signed: true),
                decoration: InputDecoration(suffix: Text("Lux"), counterText: ""),
              ),
            )
          ],
        ),
      );

  Widget min_lux() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: MyTooltip(message: "example tooltip 14", child: Text("Min Light"))),
            Expanded(
              child: TextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 4,
                style: Theme.of(context).textTheme.bodyText1,
                controller: min_lux_controller,
                onTap: () => min_lux_controller.selection = TextSelection(baseOffset: 0, extentOffset: min_lux_controller.value.text.length),
                keyboardType: TextInputType.numberWithOptions(decimal: false, signed: true),
                decoration: InputDecoration(suffix: Text("Lux"), counterText: ""),
              ),
            )
          ],
        ),
      );

  List<Widget> make_title(titile) {
    return [
      Container(
        padding: EdgeInsets.all(15),
        alignment: Alignment.centerLeft,
        color: Colors.black12,
        child: Text(titile, style: Theme.of(context).textTheme.bodyText1),
      ),
      // Divider(
      //   color: Theme.of(context).accentColor,
      // )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 64),
      child: Container(
          padding: EdgeInsets.only(top: 0),
          color: Theme.of(context).canvasColor,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              color: Colors.black12,
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text("Light", style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 24)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 16,
            ),
            row_actual_light_level(),
            SizedBox(
              height: 16,
            ),
            build_boxed_titlebox(
                title: "Day",
                child: Center(
                  child: min_lux(),
                )),
            SizedBox(height: 16),
            build_boxed_titlebox(
                title: "Night",
                child: Center(
                  child: max_lux(),
                )),
            Expanded(
                child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [build_apply_button(), build_reset_button()],
              ),
            ))
          ])),
    );
  }
}
