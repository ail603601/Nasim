import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nasim/Model/Device.dart';
import 'package:nasim/enums.dart';
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
  int interval = 500;
  bool conneteced_wifi = true;

  @override
  void initState() {
    super.initState();

    //clear the found devices list and send signal
    Provider.of<ConnectionManager>(context, listen: false).sendDiscoverSignal(true);

    // runs every 1 second
    search_timer = Timer.periodic(new Duration(seconds: 1), (timer) async {
      await send_signal();
      await refresh();
      // setState(() {});
    });
    refresh();
  }

  refresh() async {
    conneteced_wifi = await Provider.of<ConnectionManager>(context, listen: false).isWifi();
    if ((mounted)) setState(() {});

    // if (mounted) Utils.setTimeOut(interval, refresh);
  }

  @override
  void dispose() {
    search_timer.cancel();

    super.dispose();
  }

  send_signal() async {
    Provider.of<ConnectionManager>(context, listen: false).sendDiscoverSignal(false);
  }

  // List<Device> search_devices() {}
  String serialNumberTextFieldValue = "";
  Widget buildTextField(BuildContext context) => TextField(
        style: Theme.of(context).textTheme.bodyText1!,
        // controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: false, signed: true),
        onChanged: (value) {
          serialNumberTextFieldValue = value;
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

  void onDeviceTap(Device d, bool useQR) async {
    var codeReceived = useQR ? await Navigator.pushNamed(context, "/scan_barcode") : serialNumberTextFieldValue;

    if (codeReceived == d.serial) {
      Provider.of<SavedDevicesChangeNotifier>(context, listen: false).setSelectedDevice(d);
      String deviceName = await Provider.of<ConnectionManager>(context, listen: false).getRequest(0);
      if (deviceName == "") {
        if (await _displayDeviceNameDialog(context, d)) serial_validated();
      } else {
        Provider.of<SavedDevicesChangeNotifier>(context, listen: false).updateSelectedDeviceName(deviceName).then((v) {
          serial_validated();
        });
      }
    } else {
      Utils.alert(context, "Error", "serial number was wrong.");
    }
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
                  onTap: () {
                    onDeviceTap(d, true);
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
                      onPressed: () {
                        onDeviceTap(d, false);
                      },
                      child: Icon(Icons.done, size: 30),
                      // onPressed: () => setState(() {}),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).viewInsets.bottom,
              )
            ]));
  }

  String deviceNameDialogInputValue = "BREEZE N25";
  Future<bool> _displayDeviceNameDialog(BuildContext context, d) async {
    Completer<bool> dialog_beify_answer = new Completer<bool>();
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Set Device Name', style: Theme.of(context).textTheme.bodyText1),
            content: TextField(
              inputFormatters: [WhitelistingTextInputFormatter(RegExp(r"[a-zA-Z0-9]+|\s"))],
              maxLength: 10,
              style: Theme.of(context).textTheme.bodyText1,
              onChanged: (value) {
                setState(() {
                  deviceNameDialogInputValue = value;
                });
              },
              decoration: InputDecoration(hintText: "BREEZE N25", counterText: ""),
            ),
            actions: <Widget>[
              FlatButton(
                // color: Colors.red,
                textColor: Colors.black,
                child: Text('CANCEL', style: Theme.of(context).textTheme.bodyText1),
                onPressed: () {
                  dialog_beify_answer.complete(false);
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                // color: Colors.green,
                textColor: Colors.black,
                child: Text('OK', style: Theme.of(context).textTheme.bodyText1),
                onPressed: () async {
                  await Provider.of<ConnectionManager>(context, listen: false).setRequest(0, deviceNameDialogInputValue, context);
                  Provider.of<SavedDevicesChangeNotifier>(context, listen: false).updateSelectedDeviceName(deviceNameDialogInputValue).then((value) {
                    dialog_beify_answer.complete(true);
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
    if (!dialog_beify_answer.isCompleted) dialog_beify_answer.complete(false);
    // print(dialog_beify_answer.isCompleted);

    return dialog_beify_answer.future;
  }

  @override
  Widget build(BuildContext context) {
    Widget leading_icon(DeviceAccessibility p) => Column(
          children: [
            Icon(Icons.network_check),
            Text("${p == DeviceAccessibility.InAccessible ? "InAccessible" : 'Available'} ",
                style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.green[300]))
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
        );

    ConnectionManager cmg = Provider.of<ConnectionManager>(context);
    SavedDevicesChangeNotifier saved_devices = Provider.of<SavedDevicesChangeNotifier>(context, listen: false);
    List<Device> found_devices = cmg.found_devices.where((element) => !saved_devices.saved_devices.contains(element)).toList();
    Widget found_devices_list_view = ListView(
        children: found_devices
            .map((d) => ListTile(
                  title: Text(d.name, style: Theme.of(context).textTheme.bodyText1!),
                  onTap: () {
                    openBottomSheet(context, d);
                  },
                  trailing: leading_icon(d.accessibility),
                ))
            .toList());

    return Scaffold(
        resizeToAvoidBottomInset: false,
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
                child: conneteced_wifi
                    ? SpinKitDualRing(
                        color: Theme.of(context).accentColor,
                        size: 250,
                      )
                    : Icon(Icons.wifi_off, size: 150),
              ),
            ),
            Container(
                color: Colors.black12,
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
                child: Text(AppLocalizations.of(context)!.searchingUserHint, style: Theme.of(context).textTheme.bodyText2!)),
            Expanded(
                child: found_devices.length > 0
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: found_devices_list_view,
                      )
                    : Center(
                        child: Text(AppLocalizations.of(context)!.searchingNothingFound,
                            style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.white))))
          ],
        ));
  }
}
