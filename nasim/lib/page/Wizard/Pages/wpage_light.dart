import 'dart:async';
import 'dart:math';

import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils.dart';
import '../Wizardpage.dart';

class wpage_light extends StatefulWidget {
  @override
  _wpage_lightState createState() => _wpage_lightState();

  bool Function()? Next = null;
}

class _wpage_lightState extends State<wpage_light> {
  late ConnectionManager cmg;
  static bool is_both_set = false;

  refresh() async {
    await Utils.show_loading_timed(
        context: context,
        done: () async {
          ConnectionManager.Min_Day_Lux = (await cmg.getRequest("get74"));
          ConnectionManager.Max_Night_Lux = (await cmg.getRequest("get75"));
          setState(() {});
        });
  }

  @override
  void initState() {
    super.initState();
    widget.Next = () {
      if (!is_both_set) {
        Utils.alert(context, " ", "Please apply values.");
      }
      return is_both_set;
    };
    cmg = Provider.of<ConnectionManager>(context, listen: false);

    Utils.setTimeOut(0, refresh);
  }

  apply() async {
    if (int.parse(ConnectionManager.Min_Day_Lux) + 50 >= int.parse(ConnectionManager.Max_Night_Lux)) {
      Utils.alert(context, "", "Minimum must be 50 lower than maximum.");
      return false;
    }

    await cmg.set_request(74, Utils.lim_0_9999(ConnectionManager.Min_Day_Lux));

    await cmg.set_request(75, Utils.lim_0_9999(ConnectionManager.Max_Night_Lux));
    is_both_set = true;
    Utils.show_done_dialog(context, "Settings finsihed successfuly.", "Your device is set up and ready to use.", () {
      WizardPageState.wizardEnded(context);
    });
    await refresh();
  }

  build_apply_button() => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 15),
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: OutlinedButton(
            onPressed: () {
              apply();
            },
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

  Widget max_lux() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: Text("Max Light")),
            Expanded(
              child: TextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 4,
                style: Theme.of(context).textTheme.bodyText1,
                controller: TextEditingController()..text = (int.tryParse(ConnectionManager.Max_Night_Lux) ?? 0).toString(),
                onChanged: (value) {
                  ConnectionManager.Max_Night_Lux = value;
                },
                keyboardType: TextInputType.numberWithOptions(decimal: false, signed: false),
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
            Expanded(child: Text("Min Light")),
            Expanded(
              child: TextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 4,
                style: Theme.of(context).textTheme.bodyText1,
                controller: TextEditingController()..text = (int.tryParse(ConnectionManager.Min_Day_Lux) ?? 0).toString(),
                onChanged: (value) {
                  ConnectionManager.Min_Day_Lux = value;
                },
                keyboardType: TextInputType.numberWithOptions(decimal: false, signed: false),
                decoration: InputDecoration(suffix: Text("Lux"), counterText: ""),
              ),
            )
          ],
        ),
      );

  Widget build_boxed_titlebox({required title, required child}) {
    // debugger();
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new InputDecorator(
            decoration: InputDecoration(
                labelText: title, labelStyle: Theme.of(context).textTheme.bodyText1, border: OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow))),
            child: child));
  }

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
            ...make_title("Light levels"),
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
