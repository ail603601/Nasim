import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nasim/Model/Device.dart';
import 'package:nasim/Widgets/TabBarMaterialWidget.Dart';
import 'package:nasim/provider/DeviceListFabChangeNotifier.dart';
import 'package:nasim/provider/SavedevicesChangeNofiter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DevicesListConnect extends StatelessWidget {
  //TODO: get this from local
  List<Device> devices = [Device(name: "Nasim N34")];

  @override
  Widget build(BuildContext context) {
    Widget leading_icon = Column(
      children: [Icon(Icons.network_check), Text("6 ms", style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.green[300]))],
      crossAxisAlignment: CrossAxisAlignment.center,
    );
    Widget generate_device_row(Device d) => ListTile(
          // leading: Icon(Icons.arrow_forward_ios),
          title: Text(d.name, style: Theme.of(context).textTheme.headline5!),
          subtitle: Text(d.ip, style: Theme.of(context).textTheme.bodyText2!),
          onTap: () {
            Provider.of<SavedDevicesChangeNotifier>(context, listen: false).setSelectedDevice(d);

            Navigator.pushNamed(context, "/main_device");
          },
          trailing: leading_icon,
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
