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

  refresh() async {
    if (!mounted) return;

    ConnectionManager.Device_Model = await cmg.getRequest(2);
    ConnectionManager.Real_Output_Fan_Power = (int.tryParse(await cmg.getRequest(39)) ?? 0).toString();
  }

  bool bg_dark = true;

  Widget build_text_row({title, value}) {
    bg_dark = !bg_dark;
    return Column(children: [
      Container(
        color: bg_dark ? Colors.white : Colors.black12,
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
        color: Theme.of(context).canvasColor,
        child: SafeArea(
            child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.max, children: [
            build_text_row(title: "Company", value: "Fotrousi Electrnics"),
            build_text_row(title: "Serial Number", value: SavedDevicesChangeNotifier.getSelectedDevice()!.serial),
            build_text_row(title: "Model", value: ConnectionManager.Device_Model),
            build_text_row(title: "Outlet Fan Power", value: ConnectionManager.Real_Output_Fan_Power + " W"),
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
