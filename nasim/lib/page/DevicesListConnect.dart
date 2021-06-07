import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nasim/Model/Device.dart';
import 'package:nasim/Widgets/TabBarMaterialWidget.Dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/provider/DeviceListFabChangeNotifier.dart';
import 'package:nasim/provider/SavedevicesChangeNofiter.dart';
import 'package:nasim/utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DevicesListConnect extends StatefulWidget {
  @override
  DevicesListConnectState createState() => DevicesListConnectState();
}

class DevicesListConnectState extends State<DevicesListConnect> {
  static bool flag_only_user = false;

  int interval = 500;
  late Timer refresher;

  @override
  void initState() {
    super.initState();
    refresher = Timer.periodic(new Duration(milliseconds: interval), (timer) {
      refresh();
    });
  }

  refresh() {
    if (mounted) {
      Provider.of<SavedDevicesChangeNotifier>(context, listen: false).saved_devices.forEach((element) async {
        element.ping = await Provider.of<ConnectionManager>(context, listen: false).pingDevice(element);
      });
      setState(() {});
    }
  }

  @override
  void dispose() {
    refresher.cancel();

    super.dispose();
  }

  Future<bool> check_key_i(i) async {
    String key_in_dev = await Provider.of<ConnectionManager>(context, listen: false).getRequest(("get${i + 28}"));
    String serial = SavedDevicesChangeNotifier.selected_device!.serial;
    String name = SavedDevicesChangeNotifier.selected_device!.username;
    String local_key = serial + name;
    if (name == "") return false;

    if ((local_key != "") && key_in_dev.contains(local_key)) {
      return true;
    }
    return false;
  }

  Future<bool> can_login() async {
    bool b0 = await check_key_i(0);
    bool b1 = await check_key_i(1);
    bool b2 = await check_key_i(2);
    bool b3 = await check_key_i(3);
    bool b4 = await check_key_i(4);
    bool b5 = await check_key_i(5);
    return b0 || b1 || b2 || b3 || b4 || b5;
  }

  void connect_to_device(Device d) async {
    Provider.of<SavedDevicesChangeNotifier>(context, listen: false).setSelectedDevice(d);
    // await Navigator.pushNamed(context, "/wizard");
    // return;

    var device_init_state = await Provider.of<ConnectionManager>(context, listen: false).getRequest("get121");

    refresher.cancel();
    if (device_init_state == "0") {
      //go to wizard
      flag_only_user = false;

      if (await Navigator.pushNamed(context, "/wizard") == true) {
        Utils.setTimeOut(0, () async {
          await Navigator.pushNamed(context, "/main_device");
          refresher = Timer.periodic(new Duration(milliseconds: interval), (timer) {
            refresh();
          });
        });
      }
    }
    if (device_init_state == "1") {
      //already initialized

      if (await can_login()) {
        await Navigator.pushNamed(context, "/main_device");
        refresher = Timer.periodic(new Duration(milliseconds: interval), (timer) {
          refresh();
        });
      } else {
        flag_only_user = true;

        if (await Navigator.pushNamed(context, "/wizard") == true) {
          Utils.setTimeOut(0, () async {
            await Navigator.pushNamed(context, "/main_device");
            refresher = Timer.periodic(new Duration(milliseconds: interval), (timer) {
              refresh();
            });
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget leading_icon(Device device) => Column(
          children: [
            Icon(Icons.network_check),
            Text("${device.ping == -1 ? "InAccessible" : 'Available'} ",
                style: Theme.of(context).textTheme.bodyText2!.copyWith(
                    color: device.ping < 0
                        ? Colors.red[300]
                        : ((0 <= device.ping) && (device.ping < 400))
                            ? Colors.green[300]
                            : Colors.red[300]))
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
        );
    Widget generate_device_row(Device d) => ListTile(
          // leading: Icon(Icons.arrow_forward_ios),
          title: Text(d.name, style: Theme.of(context).textTheme.bodyText1!),
          subtitle: Text(d.ip, style: Theme.of(context).textTheme.bodyText2!),
          onTap: () {
            connect_to_device(d);
          },
          trailing: leading_icon(d),
        );

    return ChangeNotifierProvider(
      create: (context) => DeviceListFabChangeNotifier(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.devices, style: Theme.of(context).textTheme.headline5!),
          centerTitle: true,
        ),
        extendBody: true,
        body: Consumer<SavedDevicesChangeNotifier>(
            builder: (context, value, child) => Column(children: value.saved_devices.map((e) => generate_device_row(e)).toList())),
        bottomNavigationBar: TabBarMaterialWidget(),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () async {
              if (await Navigator.pushNamed(context, '/search_devices') == 1) {
                connect_to_device(SavedDevicesChangeNotifier.selected_device!);
              }
            }),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
