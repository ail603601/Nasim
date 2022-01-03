import 'dart:async';

import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/utils.dart';
import 'package:provider/provider.dart';

class LightPage extends StatefulWidget {
  @override
  _LightPageState createState() => _LightPageState();
}

class _LightPageState extends State<LightPage> {
  late ConnectionManager cmg;
  static bool is_both_set = false;
  late Timer soft_reftresh_timer;

  final TextEditingController max_lux_controller = TextEditingController();
  final TextEditingController min_lux_controller = TextEditingController();
  refresh() async {
    await Utils.show_loading_timed(
        context: context,
        done: () async {
          ConnectionManager.Min_Day_Lux = (int.tryParse(await cmg.getRequest(74, context)) ?? 0).toString();
          ConnectionManager.Max_Night_Lux = (int.tryParse(await cmg.getRequest(75, context)) ?? 0).toString();

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
  void dispose() {
    super.dispose();
    soft_reftresh_timer.cancel();
  }

  @override
  void initState() {
    super.initState();

    cmg = Provider.of<ConnectionManager>(context, listen: false);
    soft_reftresh_timer = Timer.periodic(new Duration(seconds: 1), (timer) async {
      soft_refresh();
    });
    Utils.setTimeOut(0, refresh);
  }

  apply() async {
    ConnectionManager.Min_Day_Lux = (int.tryParse(min_lux_controller.text) ?? 0).toString();
    ConnectionManager.Max_Night_Lux = (int.tryParse(max_lux_controller.text) ?? 0).toString();

    if (int.parse(ConnectionManager.Min_Day_Lux) + 50 > int.parse(ConnectionManager.Max_Night_Lux)) {
      Utils.alert(context, "", "Minimum must be 50 lower than maximum.");
      return false;
    }

    await cmg.setRequest(74, Utils.lim_0_9999(ConnectionManager.Min_Day_Lux), context);

    await cmg.setRequest(75, Utils.lim_0_9999(ConnectionManager.Max_Night_Lux), context);
    is_both_set = true;
    Utils.showSnackBar(context, "Done.");
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
            child: Text("Restore To Factory Defaults", style: Theme.of(context).textTheme.bodyText1),
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
            Expanded(child: Text("Min Light")),
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
    return Container(
        padding: EdgeInsets.only(top: 0),
        color: Theme.of(context).canvasColor,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ...make_title("Light levels"),
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
        ]));
  }
}
