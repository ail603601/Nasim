import 'dart:async';
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
  _DevicesListConnectState createState() => _DevicesListConnectState();
}

class _DevicesListConnectState extends State<DevicesListConnect> {
  int interval = 50;

  @override
  void initState() {
    super.initState();
    // runs every 1 second
    Utils.setTimeOut(interval, refresh);
  }

  refresh() {
    Provider.of<SavedDevicesChangeNotifier>(context, listen: false).saved_devices.forEach((element) async {
      element.ping = await Provider.of<ConnectionManager>(context, listen: false).pingDevice(element);
    });
    setState(() {});
    if (mounted) Utils.setTimeOut(interval, refresh);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget leading_icon(Device device) => Column(
          children: [
            Icon(Icons.network_check),
            Text("${device.ping == -1 ? "timeout" : (device.ping.toString() + 'ms')} ",
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
          title: Text(d.name, style: Theme.of(context).textTheme.headline5!),
          subtitle: Text(d.ip, style: Theme.of(context).textTheme.bodyText2!),
          onTap: () async {
            Provider.of<SavedDevicesChangeNotifier>(context, listen: false).setSelectedDevice(d);
            if (!await Provider.of<ConnectionManager>(context, listen: false).getRequestAutoCheck("_DISCOVER", context)) {
              Utils.alert(context, "Error", "Sync failed,make sure you are connected to the 'Nasim Air Conditioner' Wifi", () {
                // Navigator.of(context).pop();
              });
            }
            // else
            Navigator.pushNamed(context, "/main_device");
          },
          trailing: leading_icon(d),
        );

    return ChangeNotifierProvider(
        create: (context) => DeviceListFabChangeNotifier(),
        child: Consumer<DeviceListFabChangeNotifier>(
          builder: (context, deive_list_fab_chn, child) => Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.devices, style: Theme.of(context).textTheme.headline5!),
              centerTitle: true,
            ),
            extendBody: true,
            body: Consumer<SavedDevicesChangeNotifier>(
                builder: (context, value, child) => Column(children: value.saved_devices.map(generate_device_row).toList())),
            bottomNavigationBar: TabBarMaterialWidget(),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () => deive_list_fab_chn.clicked(),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          ),
        ));
  }
}
