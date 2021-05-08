import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/material.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/utils.dart';
import 'package:provider/provider.dart';

class LightPage extends StatefulWidget {
  @override
  _LightPageState createState() => _LightPageState();
}

class _LightPageState extends State<LightPage> {
  late ConnectionManager cmg;
  refresh() async {
    ConnectionManager.Min_Day_Lux = Utils.int_str(await cmg.getRequest("get50"), ConnectionManager.Min_Day_Lux);
    ConnectionManager.Max_Night_Lux = Utils.int_str(await cmg.getRequest("get51"), ConnectionManager.Max_Night_Lux);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    cmg = Provider.of<ConnectionManager>(context, listen: false);

    refresh();
  }

  apply() async {
    if (!await cmg.set_request(50, Utils.lim_0_100(ConnectionManager.Min_Day_Lux))) {
      Utils.handleError(context);
      return;
    }

    await cmg.set_request(51, Utils.lim_0_100(ConnectionManager.Max_Night_Lux));

    refresh();
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
            child: Text("Apply", style: Theme.of(context).textTheme.headline6),
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
            child: Text("Restore Defaults", style: Theme.of(context).textTheme.headline6),
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
                style: Theme.of(context).textTheme.bodyText1,
                controller: TextEditingController()..text = ConnectionManager.Max_Night_Lux,
                onChanged: (value) {
                  ConnectionManager.Max_Night_Lux = value;
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(suffix: Text("Lux")),
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
                style: Theme.of(context).textTheme.bodyText1,
                controller: TextEditingController()..text = ConnectionManager.Min_Day_Lux,
                onChanged: (value) {
                  ConnectionManager.Min_Day_Lux = value;
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(suffix: Text("Lux")),
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
                labelText: title, labelStyle: Theme.of(context).textTheme.headline6, border: OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow))),
            child: child));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: 10),
        color: Theme.of(context).canvasColor,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
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
