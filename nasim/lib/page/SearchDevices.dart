import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nasim/Model/Device.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/provider/SavedevicesChangeNofiter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../utils.dart';

class SearchDevices extends StatefulWidget {
  @override
  _SearchDevicesState createState() => _SearchDevicesState();
}

class _SearchDevicesState extends State<SearchDevices> {
  late Timer search_timer;
  int interval = 150;

  @override
  void initState() {
    super.initState();
    // runs every 1 second
    search_timer = Timer.periodic(new Duration(seconds: 1), (timer) {
      send_signal();
      setState(() {});
    });
    refresh();
  }

  refresh() {
    Provider.of<ConnectionManager>(context, listen: false).found_devices.forEach((element) async {
      element.ping = await Provider.of<ConnectionManager>(context, listen: false).pingDevice(element);
      setState(() {});
    });
    if (mounted) Utils.setTimeOut(interval, refresh);
  }

  @override
  void dispose() {
    search_timer.cancel();

    super.dispose();
  }

  void send_signal() {
    Provider.of<ConnectionManager>(context, listen: false).sendDiscoverSignal();
  }

  // List<Device> search_devices() {}
  var text_field_value = "";
  Widget buildTextField(BuildContext context) => TextField(
        style: Theme.of(context).textTheme.headline6!,
        // controller: controller,
        keyboardType: TextInputType.number,
        onChanged: (value) {
          text_field_value = value;
        },

        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.enterSerialNumber,
          hintStyle: Theme.of(context).textTheme.bodyText1!,
        ),
      );

  void openBottomSheet(context, Device d) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) => Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Text(AppLocalizations.of(context)!.serialNumberRequired, style: Theme.of(context).textTheme.headline6!),
              ),
              ListTile(
                  leading: Icon(Icons.qr_code),
                  title: Text(AppLocalizations.of(context)!.scanQrCode, style: Theme.of(context).textTheme.headline5!),
                  onTap: () async {
                    var code_received = await Navigator.pushNamed(context, "/scan_barcode");
                    if (code_received == d.serial) {
                      Provider.of<SavedDevicesChangeNotifier>(context, listen: false)..addDevice(d);
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    } else if (code_received != null) {
                      Utils.alert(context, "Error", "serial number was wrong.");
                    }
                  }),
              Divider(
                color: Theme.of(context).accentColor,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 60),
                child: Row(
                  children: [
                    Expanded(child: buildTextField(context)),
                    const SizedBox(width: 12),
                    FloatingActionButton(
                      backgroundColor: Theme.of(context).primaryColor,
                      onPressed: () async {
                        var code_received = text_field_value;
                        if (code_received == d.serial) {
                          Provider.of<SavedDevicesChangeNotifier>(context, listen: false)..addDevice(d);
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        } else {
                          Utils.alert(context, "Error", "serial number was wrong.");
                        }
                      },
                      child: Icon(Icons.done, size: 30),
                      // onPressed: () => setState(() {}),
                    )
                  ],
                ),
              ),
            ]));
  }

  @override
  Widget build(BuildContext context) {
    Widget leading_icon(p) => Column(
          children: [Icon(Icons.network_check), Text("$p  ms", style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.green[300]))],
          crossAxisAlignment: CrossAxisAlignment.center,
        );

    ConnectionManager cmg = Provider.of<ConnectionManager>(context);
    SavedDevicesChangeNotifier saved_devices = Provider.of<SavedDevicesChangeNotifier>(context, listen: false);
    List<Device> found_devices = cmg.found_devices.where((element) => !saved_devices.saved_devices.contains(element)).toList();
    Widget found_devices_list_view = ListView(
        children: found_devices
            .map((d) => ListTile(
                  title: Text(d.name, style: Theme.of(context).textTheme.headline5!),
                  onTap: () {
                    openBottomSheet(context, d);
                  },
                  trailing: leading_icon(d.ping),
                ))
            .toList());

    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.searchingAvailableDevices, style: Theme.of(context).textTheme.headline5!),
          centerTitle: true,
        ),
        extendBody: true,
        body: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SpinKitDualRing(
                  color: Theme.of(context).accentColor,
                  size: 250,
                ),
              ),
            ),
            Container(
                color: Theme.of(context).cardColor,
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
                child: Text(AppLocalizations.of(context)!.searchingUserHint, style: Theme.of(context).textTheme.bodyText2!)),
            Expanded(
                child: found_devices.length > 0
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: found_devices_list_view,
                      )
                    : Center(child: Text(AppLocalizations.of(context)!.searchingNothingFound, style: Theme.of(context).textTheme.bodyText1!)))
          ],
        ));
  }
}
