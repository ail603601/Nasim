import 'dart:async';
import 'dart:developer';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nasim/Model/Device.dart';
import 'package:nasim/Model/menu_info.dart';
import 'package:nasim/Widgets/TabBarMaterialWidget.Dart';
import 'package:nasim/enums.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/provider/DeviceListFabChangeNotifier.dart';
import 'package:nasim/provider/SavedevicesChangeNofiter.dart';
import 'package:nasim/utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class DevicesListConnect extends StatefulWidget {
  @override
  DevicesListConnectState createState() => DevicesListConnectState();
}

class DevicesListConnectState extends State<DevicesListConnect> {
  static bool flag_only_user = false;

  int interval = 1500;
  late Timer refresher;

  bool timer_run = true;
  @override
  void initState() {
    super.initState();
    refresher = Timer.periodic(new Duration(milliseconds: interval), (timer) {
      if (timer_run) refresh();
    });
  }

  refresh() {
    // return;
    if (mounted && timer_run) {
      Provider.of<SavedDevicesChangeNotifier>(context, listen: false).saved_devices.forEach((element) async {
        try {
          Provider.of<ConnectionManager>(context, listen: false).CheckConnectivityToDevice(element);
          Provider.of<SavedDevicesChangeNotifier>(context, listen: false).setSelectedDevice(element);
          String last_name = element.name;
          element.name = await Provider.of<ConnectionManager>(context, listen: false).getRequest(0);
          if (element.name != last_name) Provider.of<SavedDevicesChangeNotifier>(context, listen: false).updateSelectedDeviceName(element.name);
          if (["", null, false, 0].contains(element.name)) {
            element.name = "New Air Conditioner (un named)";
          }
        } catch (e) {
          print(e);
        }
      });
      setState(() {});

      // for (var i = 0; i < Provider.of<SavedDevicesChangeNotifier>(context, listen: false).saved_devices.length; i++) {
      //   Provider.of<ConnectionManager>(context, listen: false)
      //       .CheckConnectivityToDevice(Provider.of<SavedDevicesChangeNotifier>(context, listen: false).saved_devices[i])
      //       .then((Device? d) {
      //     if (d != null && mounted) Provider.of<SavedDevicesChangeNotifier>(context, listen: false).saved_devices[i] = d;
      //   });

      // List device_after_ping = Provider.of<SavedDevicesChangeNotifier>(context, listen: falsec).saved_devices;
      // setState(() {});
      //   // }
    }
  }

  @override
  void dispose() {
    refresher.cancel();

    super.dispose();
  }

  var babycheckDialogInputValue = "";
  Future<bool> babyCheck(BuildContext context) async {
    var rng = new Random();
    var num1 = rng.nextInt(10);
    var num2 = rng.nextInt(10);
    var math_res = (num1 * num2).toString();
    Completer<bool> dialog_beify_answer = new Completer<bool>();
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Result of  $num1 * $num2 ?", style: Theme.of(context).textTheme.bodyText1),
            content: TextField(
              maxLength: 10,
              style: Theme.of(context).textTheme.bodyText1,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (math_res == value)
                  setState(() {
                    babycheckDialogInputValue = value;
                  });
              },
              decoration: InputDecoration(hintText: "", counterText: ""),
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
                  if (math_res == babycheckDialogInputValue) {
                    dialog_beify_answer.complete(true);
                    Navigator.pop(context);
                  } else {
                    dialog_beify_answer.complete(false);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          );
        });
    if (!dialog_beify_answer.isCompleted) dialog_beify_answer.complete(false);
    // print(dialog_beify_answer.isCompleted);

    return dialog_beify_answer.future;
  }

  Future<bool> check_key_i(i) async {
    // String name_n = await Provider.of<ConnectionManager>(context, listen: false).getRequest(${i + 16}");
    // return SavedDevicesChangeNotifier.getSelectedDevice()!.name == name_n;

    String key_in_dev = await Provider.of<ConnectionManager>(context, listen: false).getRequest(i + 28);
    String serial = SavedDevicesChangeNotifier.getSelectedDevice()!.serial;
    String name = SavedDevicesChangeNotifier.getSelectedDevice()!.username;
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
    // Provider.of<SavedDevicesChangeNotifier>(context, listen: false).setSelectedDevice(d);
    // await Navigator.pushNamed(context, "/wizard");
    // return;

    var device_init_state = await Provider.of<ConnectionManager>(context, listen: false).getRequest(121);

    if (device_init_state == "") {
      //go to wizard
      if (SavedDevicesChangeNotifier.getSelectedDevice()!.accessibility == DeviceAccessibility.AccessibleInternet) {
        Utils.show_error_dialog(context, "Permission Denied.", "This device is Uninitialized. Initialization is not allowed over internet connection.", null);
        timer_run = true;

        return;
      }

      flag_only_user = false;
      timer_run = false;
      if (await Navigator.pushNamed(context, "/wizard") == true) {
        await Navigator.pushNamed(context, "/main_device");
        timer_run = true;
      }
    }
    if (device_init_state == "1") {
      if (!await babyCheck(context)) {
        return;
      }

      //already initialized
      Provider.of<MenuInfo>(context, listen: false).updateMenu(MenuInfo(MenuType.Licenses));
      timer_run = false;

      if (await can_login()) {
        await Provider.of<SavedDevicesChangeNotifier>(context, listen: false)
          ..addDevice(SavedDevicesChangeNotifier.getSelectedDevice()!);

        await Navigator.pushNamed(context, "/main_device");
        timer_run = true;
      } else {
        if (SavedDevicesChangeNotifier.getSelectedDevice()!.accessibility == DeviceAccessibility.AccessibleInternet) {
          timer_run = true;

          Utils.show_error_dialog(
              context,
              "Permission Denied.",
              "Your phone is not defined in users list or might have been removed by another user. in order to access your device; connect to it locally and add your phone again.",
              null);

          return;
        }
        flag_only_user = true;

        if (await Navigator.pushNamed(context, "/wizard") == true) {
          Utils.setTimeOut(0, () async {
            await Navigator.pushNamed(context, "/main_device");
            timer_run = true;
          });
        }
      }
    }
  }

  void ask_remove_device(Device d) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.WARNING,
      animType: AnimType.BOTTOMSLIDE,
      title: "Confirm",
      desc: "Remove this device from your list?",
      btnOkOnPress: () {
        Provider.of<SavedDevicesChangeNotifier>(context, listen: false).removeDevice(d);
      },
      btnCancelOnPress: () {},
    )..show();
  }

  @override
  Widget build(BuildContext context) {
    Widget leading_icon(Device device) => Column(
          children: [
            Icon(Icons.network_check),
            Text("${device.accessibility == DeviceAccessibility.InAccessible ? "InAccessible" : 'Available'} ",
                style: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .copyWith(color: device.accessibility == DeviceAccessibility.InAccessible ? Colors.red[300] : Colors.green[300]))
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
          onLongPress: () {
            ask_remove_device(d);
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
            builder: (context, value, child) => Center(child: Column(children: value.saved_devices.map((e) => generate_device_row(e)).toList()))),
        bottomNavigationBar: TabBarMaterialWidget(),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () async {
              if (await Navigator.pushNamed(context, '/search_devices') == 1) {
                connect_to_device(SavedDevicesChangeNotifier.getSelectedDevice()!);
              }
            }),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
