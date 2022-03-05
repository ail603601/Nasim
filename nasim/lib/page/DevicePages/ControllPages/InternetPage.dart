import 'dart:async';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/provider/SavedevicesChangeNofiter.dart';
import 'package:nasim/utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../enums.dart';

class InternetPage extends StatefulWidget {
  const InternetPage({Key? key}) : super(key: key);

  @override
  _InternetPageState createState() => _InternetPageState();
}

class _InternetPageState extends State<InternetPage> {
  late ConnectionManager cmg;
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _wifinameController;
  late TextEditingController _wifipassController;

  @override
  void initState() {
    super.initState();
    _wifinameController = new TextEditingController();
    _wifipassController = new TextEditingController();
    cmg = Provider.of<ConnectionManager>(context, listen: false);
    Utils.setTimeOut(0, refresh);
  }

  bool is_locall_conntection(context) {
    if (SavedDevicesChangeNotifier.getSelectedDevice()!.accessibility == DeviceAccessibility.AccessibleInternet) {
      Utils.setTimeOut(
          0,
          () => Utils.show_error_dialog(context, "Not Available", "This action is not allowed over internt.", () {}).then((value) {
                // Navigator.pop(context);
              }));
      return false;
    }

    return true;
  }

  Widget build_boxed_titlebox({required title, required child}) {
    // debugger();
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: new InputDecorator(
            decoration: InputDecoration(
                labelText: title, labelStyle: Theme.of(context).textTheme.bodyText1, border: OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow))),
            child: child));
  }

  refresh() async {
    await Utils.show_loading_timed(
        context: context,
        done: () async {
          try {
            if (!mounted) return;

            ConnectionManager.DEVICE_WIFI_TO_CONNECT_NAME = await cmg.getRequest(123, context);
            ConnectionManager.DEVICE_WIFI_TO_CONNECT_PASS = await cmg.getRequest(124, context);
            // ConnectionManager.DEVICE_CONNECT_TO_INTERNET = await cmg.getRequest(125);
            _wifinameController.text = (ConnectionManager.DEVICE_WIFI_TO_CONNECT_NAME).toString();
            _wifipassController.text = (ConnectionManager.DEVICE_WIFI_TO_CONNECT_PASS).toString();

            setState(() {});
          } catch (e) {
            print(e);
          }
        });
  }

  List<Widget> make_title(titile) {
    return [
      Container(
        padding: EdgeInsets.all(15),
        alignment: Alignment.centerLeft,
        color: Colors.blueGrey[300],
        child: Text(titile, style: Theme.of(context).textTheme.bodyText1),
      ),
      // Divider(
      //   color: Theme.of(context).accentColor,
      // )
    ];
  }

  List<Widget> build_root_view() {
    return [
      Expanded(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 28,
                ),
                Center(
                    child: build_boxed_titlebox(
                        title: "Information:",
                        child: Text(
                            "provide wifi name and password (if required) so device will connect to the wifi, enabling it to be controlled via internet or other wifi clients.",
                            style: TextStyle(
                              fontSize: 10.0,
                              color: Colors.black,
                            )))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextFormField(
                    controller: _wifinameController,
                    style: Theme.of(context).textTheme.bodyText1,
                    decoration: InputDecoration(hintText: 'Wifi Name'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextFormField(
                    controller: _wifipassController,
                    style: Theme.of(context).textTheme.bodyText1,
                    decoration: InputDecoration(hintText: 'Wifi Password'),
                  ),
                ),
                SizedBox(
                  height: 28,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListTile(
                      leading: Icon(Icons.qr_code),
                      title: Text("Scan Wifi BarCode", style: Theme.of(context).textTheme.bodyText1!),
                      onTap: () async {
                        String return_value = (await Navigator.of(context, rootNavigator: true).pushNamed("/scan_barcode")).toString();
                        if (return_value == "null" || return_value == "") {
                          return;
                        }
                        String _name = return_value.substring(return_value.indexOf("S:") + 2);
                        _name = _name.substring(0, _name.indexOf(";"));
                        _wifinameController.text = _name;
                        String _pass = return_value.substring(return_value.indexOf("P:") + 2);
                        _pass = _pass.substring(0, _pass.indexOf(";"));
                        _wifipassController.text = _pass;
                      }),
                ),
                Divider(
                  color: Theme.of(context).accentColor,
                ),
                Center(
                    child: build_boxed_titlebox(
                        title: "Notes",
                        child: Text(
                            "● This Action will Restart your device.\n\n● Changing device settings is limited via internet.\n\n● In case of fail, the device will create its own wifi like before.",
                            style: TextStyle(
                              fontSize: 10.0,
                              color: Colors.black,
                            ))
                        // the changes will only take effect on next turn on.
                        // in case of successful connection to wifi, your air conditioner will no longer create the wifi server
                        // in order to controll it you must join the same wifi that the air conditioner is connected

                        // "if you provice correct wifi name & password; device will connect to it and no longer create wifi,\n in order to controll it you must connect to the wifi that you are connecting this device in, or you can controll this device over the internet if the wifi you provide has access to internet, but some settings are limited"),
                        )),
                SizedBox(
                  height: 28,
                ),
              ],
            ),
          ),
        ),
      ),
      Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 15),
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: OutlinedButton(
          onPressed: () async {
            try {
              if (is_locall_conntection(context)) {
                if (_wifinameController.text.isEmpty) {
                  Utils.show_error_dialog(context, "", 'Please enter Wifi name', null);
                  return;
                }
                if (_wifinameController.text.length > 20) {
                  Utils.show_error_dialog(context, "", 'Wifi name Maximum 20 characters are allowed', null);
                  return;
                }

                if (_wifipassController.text.length > 20) {
                  Utils.show_error_dialog(context, "", 'Password Maximum 20 characters are allowed', null);
                  return;
                }

                AwesomeDialog(
                  context: context,
                  useRootNavigator: true,
                  dialogType: DialogType.WARNING,
                  animType: AnimType.BOTTOMSLIDE,
                  title: "Confirm",
                  desc:
                      "The Air conditioner will restart and tries to connect to Wifi '${_wifinameController.text}' you must connect to it in order to controll your device, or you can connect to the device over internet if '${_wifinameController.text}' has interner access.\n if connection fails the air conditioner will create it's own Wifi like before. \n",
                  btnOkOnPress: () async {
                    await cmg.setRequest(123, _wifinameController.text);
                    await cmg.setRequest(124, _wifipassController.text);
                    await cmg.setRequest(125, "1");
                    cmg.setRequest(127, "1");
                    Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
                  },
                  btnCancelOnPress: () {},
                )..show();
              }
            } catch (e) {}
          },
          style: OutlinedButton.styleFrom(
              padding: EdgeInsets.only(top: 16, bottom: 16, left: 28, right: 28),
              side: BorderSide(width: 2, color: Theme.of(context).primaryColor),
              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(8.0))),
          child: Text("Submit", style: Theme.of(context).textTheme.bodyText1),
        ),
      ),
      Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 15),
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: OutlinedButton(
          onPressed: () async {
            if (is_locall_conntection(context)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Internet Connection diasbled.')),
              );
              await cmg.setRequest(123, "");
              await cmg.setRequest(124, "");
              await cmg.setRequest(125, "0");
              cmg.setRequest(127, "1");
              Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
            }
          },
          style: OutlinedButton.styleFrom(
              padding: EdgeInsets.only(top: 16, bottom: 16, left: 28, right: 28),
              side: BorderSide(width: 2, color: Theme.of(context).primaryColor),
              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(8.0))),
          child: Text("Reset to Defaults", style: Theme.of(context).textTheme.bodyText1),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Container(
          padding: EdgeInsets.only(top: 0),
          color: Theme.of(context).canvasColor,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ...make_title("Internet Access"),
            SizedBox(
              height: 16,
            ),
            ...build_root_view()
          ])),
    );
  }
}
