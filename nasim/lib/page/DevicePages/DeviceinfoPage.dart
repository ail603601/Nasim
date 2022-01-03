import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/provider/SavedevicesChangeNofiter.dart';
import 'package:nasim/utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DeviceInfoPage extends StatefulWidget {
  const DeviceInfoPage({Key? key}) : super(key: key);

  @override
  _DeviceInfoPageState createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  late ConnectionManager cmg;

  @override
  void initState() {
    super.initState();
    // runs every 1 second

    cmg = Provider.of<ConnectionManager>(context, listen: false);
    Utils.setTimeOut(0, () {
      Utils.show_loading_timed(
          context: context,
          done: () async {
            await refresh();
          });
    });
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

  int device_fan_power = 0;
  refresh() async {
    if (!mounted) return;

    ConnectionManager.Device_Model = await cmg.getRequest(2, context);
    ConnectionManager.Device_Fan_Power = (int.tryParse(await cmg.getRequest(3, context)) ?? 0).toString();
    device_fan_power = parse_device_fan(int.parse(ConnectionManager.Device_Fan_Power));
    setState(() {});
  }

  bool bg_dark = true;

  Widget build_text_row({title, value}) {
    bg_dark = !bg_dark;
    return Column(children: [
      Container(
        color: bg_dark ? Colors.transparent : Colors.black12,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
        child: Row(
          children: [
            Expanded(child: Text(title, style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 13))),
            Expanded(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyText1,
                textAlign: TextAlign.right,
              ),
            )
          ],
        ),
      ),
      Divider(
        height: 1,
        color: Theme.of(context).accentColor,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.transparent,
        child: SafeArea(
            child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.max, children: [
            build_text_row(title: "Company", value: "Fotrousi Electronics"),
            build_text_row(title: "Serial Number", value: SavedDevicesChangeNotifier.getSelectedDevice()!.serial),
            build_text_row(title: "Model", value: ConnectionManager.Device_Model),
            build_text_row(title: "Device Fan Power", value: device_fan_power.toString() + " W"),
            build_text_row(title: "Application Version", value: "0.16"),
            Center(
              child: Text("more information at:", style: Theme.of(context).textTheme.bodyText1),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: OutlinedButton(
                  onPressed: () async {
                    // const url = "https://Fotrousi.com";
                    // if (await canLaunch(url)) await launch(url);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.only(top: 16, bottom: 16, left: 28, right: 28),
                    side: BorderSide(width: 2, color: Theme.of(context).primaryColor),
                    shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    primary: Theme.of(context).primaryColor,
                  ),
                  child: Text("Fotrousi.com", style: Theme.of(context).textTheme.headline4!.copyWith(color: Colors.white)),
                ),
              ),
            )
          ]),
        )));
  }
}
