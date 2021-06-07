import 'dart:async';

import 'package:connectivity/connectivity.dart';
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
  bool conneteced_wifi = true;

  @override
  void initState() {
    super.initState();
    // runs every 1 second
    search_timer = Timer.periodic(new Duration(seconds: 1), (timer) async {
      await send_signal();
      await refresh();
      // setState(() {});
    });
    refresh();
  }

  refresh() async {
    // Provider.of<ConnectionManager>(context, listen: false).found_devices.forEach((element) async {
    //   element.ping = await Provider.of<ConnectionManager>(context, listen: false).pingDevice(element);
    // });
    conneteced_wifi = (await Connectivity().checkConnectivity() == ConnectivityResult.wifi);
    if ((mounted)) setState(() {});

    // if (mounted) Utils.setTimeOut(interval, refresh);
  }

  @override
  void dispose() {
    search_timer.cancel();

    super.dispose();
  }

  send_signal() async {
    await Provider.of<ConnectionManager>(context, listen: false).sendDiscoverSignal();
  }

  // List<Device> search_devices() {}
  var text_field_value = "";
  Widget buildTextField(BuildContext context) => TextField(
        style: Theme.of(context).textTheme.bodyText1!,
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

  void serial_validated() {
    Navigator.pop(context);
    Navigator.pop(context, 1);
  }

  void openBottomSheet(context, Device d) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) => Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                // color: Colors.black12,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Text(AppLocalizations.of(context)!.serialNumberRequired, style: Theme.of(context).textTheme.bodyText1!),
              ),
              ListTile(
                  leading: Icon(Icons.qr_code),
                  title: Text(AppLocalizations.of(context)!.scanQrCode, style: Theme.of(context).textTheme.bodyText1!),
                  onTap: () async {
                    var code_received = await Navigator.pushNamed(context, "/scan_barcode");
                    if (code_received == d.serial) {
                      Provider.of<SavedDevicesChangeNotifier>(context, listen: false).setSelectedDevice(d);
                      String device_name = await Provider.of<ConnectionManager>(context, listen: false).getRequest_non0("get0");
                      if (device_name == "") {
                        await _displayTextInputDialog(context, d);
                      } else {
                        SavedDevicesChangeNotifier.selected_device!.name = last_dialog_text;
                      }
                      serial_validated();
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
                          Provider.of<SavedDevicesChangeNotifier>(context, listen: false).setSelectedDevice(d);
                          String device_name = await Provider.of<ConnectionManager>(context, listen: false).getRequest_non0("get0");
                          if (device_name == "") {
                            await _displayTextInputDialog(context, d);
                          } else {
                            SavedDevicesChangeNotifier.selected_device!.name = device_name;
                          }
                          serial_validated();
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

  String last_dialog_text = "BREEZE N25";
  Future<void> _displayTextInputDialog(BuildContext context, d) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Set Device Name', style: Theme.of(context).textTheme.bodyText1),
            content: TextField(
              style: Theme.of(context).textTheme.bodyText1,
              onChanged: (value) {
                setState(() {
                  last_dialog_text = value;
                });
              },
              decoration: InputDecoration(hintText: "BREEZE N25"),
            ),
            actions: <Widget>[
              FlatButton(
                // color: Colors.red,
                textColor: Colors.black,
                child: Text('CANCEL', style: Theme.of(context).textTheme.bodyText1),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                // color: Colors.green,
                textColor: Colors.black,
                child: Text('OK', style: Theme.of(context).textTheme.bodyText1),
                onPressed: () async {
                  SavedDevicesChangeNotifier.selected_device!.name = last_dialog_text;
                  await Provider.of<ConnectionManager>(context, listen: false).set_request(0, last_dialog_text);
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });

    // Provider.of<SavedDevicesChangeNotifier>(context, listen: false)..addDevice(d);
  }

  @override
  Widget build(BuildContext context) {
    Widget leading_icon(p) => Column(
          children: [
            Icon(Icons.network_check),
            Text("${p == -1 ? "InAccessible" : 'Available'} ", style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.green[300]))
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
        );

    ConnectionManager cmg = Provider.of<ConnectionManager>(context);
    SavedDevicesChangeNotifier saved_devices = Provider.of<SavedDevicesChangeNotifier>(context, listen: false);
    List<Device> found_devices = cmg.found_devices.where((element) => !saved_devices.saved_devices.contains(element)).toList();
    Widget found_devices_list_view = ListView(
        children: found_devices
            .map((d) => ListTile(
                  title: Text(d.wifiname, style: Theme.of(context).textTheme.bodyText1!),
                  onTap: () {
                    openBottomSheet(context, d);
                  },
                  trailing: leading_icon(d.ping),
                ))
            .toList());

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.searchingAvailableDevices, style: Theme.of(context).textTheme.bodyText1!),
          centerTitle: true,
        ),
        extendBody: true,
        body: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: conneteced_wifi
                    ? SpinKitDualRing(
                        color: Theme.of(context).accentColor,
                        size: 250,
                      )
                    : Icon(Icons.wifi_off, size: 150),
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
