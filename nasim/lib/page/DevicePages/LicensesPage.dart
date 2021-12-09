import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nasim/enums.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/provider/SavedevicesChangeNofiter.dart';
import 'package:provider/provider.dart';
import 'package:nasim/provider/LicenseChangeNotifier.dart';

import '../../utils.dart';

class LicensesPage extends StatefulWidget {
  @override
  _LicensesPageState createState() => _LicensesPageState();
}

class _LicensesPageState extends State<LicensesPage> {
  @override
  void initState() {
    super.initState();
  }

  UniqueKey? keytile;
  bool expanded_initialy = false;

  List<Widget> build_license_row(title) {
    return [
      ListTile(
        subtitle: Text(
          "valid untill 2023/06/25",
          style: Theme.of(context).textTheme.bodyText2,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        trailing: Icon(Icons.verified_outlined),
      ),
      Divider(
        color: Theme.of(context).accentColor,
      ),
    ];
  }

  hintbox() => Container(
        padding: EdgeInsets.all(16),
        color: Theme.of(context).hintColor,
        child: Text("Before we continue setting things up , you have to provide required licenses in order to turn your device On.",
            style: Theme.of(context).textTheme.headline6!),
      );
  license_gsm_modem_row(LicenseChangeNotifier lcn) => ListTile(
        title: Text("GSM Modem License", style: Theme.of(context).textTheme.bodyText1!),
        subtitle: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 18,
            ),
            SizedBox(
              width: 8,
            ),
            Text("Optional", style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 10))
          ],
        ),
        leading: Icon(Icons.sim_card),
        trailing: Icon(
          lcn.gsm_modem ? Icons.check_box : Icons.check_box_outline_blank,
          color: Theme.of(context).accentColor,
        ),
        onTap: () async {
          if (lcn.gsm_modem) {
            return;
          }
          var data = await Utils.ask_serial("You have to provdie license's serial number", context);
          if (data == "" && data != "null") {
            return;
          }
          bool is_valid = await Provider.of<ConnectionManager>(context, listen: false).setRequest(5, data, context);
          if (is_valid) {
            lcn.license_gsm_modem(context);

            setState(() {});
          } else {
            Utils.showSnackBar(context, "Wrong serial number.");
          }
        },
      );
  license_outdoor_temp_sesnsor_row(LicenseChangeNotifier lcn) => ListTile(
        title: Text("Outdoor Temperature License", style: Theme.of(context).textTheme.bodyText1!),
        subtitle: Row(children: [
          Icon(
            Icons.info_outline,
            size: 18,
          ),
          SizedBox(
            width: 8,
          ),
          Text("Optional", style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 10))
        ]),
        leading: Icon(Icons.thermostat_rounded),
        trailing: Icon(
          lcn.outdoor_temp ? Icons.check_box : Icons.check_box_outline_blank,
          color: Theme.of(context).accentColor,
        ),
        onTap: () async {
          if (lcn.outdoor_temp) {
            return;
          }
          var data = await Utils.ask_serial("You have to provdie license's serial number", context);
          if (data == "" && data != "null") {
            return;
          }
          bool is_valid = await Provider.of<ConnectionManager>(context, listen: false).setRequest(15, data, context);
          if (is_valid) {
            lcn.license_outdoor_temp(context);
            setState(() {});
          } else {
            Utils.showSnackBar(context, "Wrong serial number.");
          }
        },
      );
  license_power_box_row(LicenseChangeNotifier lcn) => ListTile(
        title: Text("Power Box License", style: Theme.of(context).textTheme.bodyText1!),
        subtitle: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 18,
              color: Colors.red,
            ),
            SizedBox(
              width: 8,
            ),
            Text("Reuired", style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.red, fontSize: 10))
          ],
        ),
        leading: Icon(Icons.power),
        trailing: Icon(
          lcn.power_box ? Icons.check_box : Icons.check_box_outline_blank,
          color: Theme.of(context).accentColor,
        ),
        onTap: () async {
          if (lcn.power_box) {
            return;
          }
          var data = await Utils.ask_serial("You have to provdie license's serial number", context);
          if (data == "" && data != "null") {
            return;
          }
          bool is_valid = await Provider.of<ConnectionManager>(context, listen: false).setRequest(4, data, context);
          if (is_valid) {
            lcn.license_power_box(context);

            setState(() {});
          } else {
            Utils.showSnackBar(context, "Wrong serial number.");
          }
        },
      );

  togletile() {
    setState(() {
      keytile = new UniqueKey();
      expanded_initialy = !expanded_initialy;
    });
  }

  license_room_temp_row_expansion(LicenseChangeNotifier lcn) => ExpansionTile(
        initiallyExpanded: expanded_initialy,
        key: keytile,
        tilePadding: EdgeInsets.only(right: 16),
        title: ListTile(
          title: Text("Room Temperature License", style: Theme.of(context).textTheme.bodyText1!),
          leading: Icon(Icons.thermostat_rounded),
          onTap: () {
            togletile();
          },
        ),
        children: [
          license_room_temp_row_0(lcn),
          license_room_temp_row_other(1, lcn.room_temp_1, () async {
            await lcn.license_room_temp(1, context);
          }),
          license_room_temp_row_other(2, lcn.room_temp_2, () async {
            await lcn.license_room_temp(2, context);
          }),
          license_room_temp_row_other(3, lcn.room_temp_3, () async {
            await lcn.license_room_temp(3, context);
          }),
          license_room_temp_row_other(4, lcn.room_temp_4, () async {
            await lcn.license_room_temp(4, context);
          }),
          license_room_temp_row_other(5, lcn.room_temp_5, () async {
            await lcn.license_room_temp(5, context);
          }),
          license_room_temp_row_other(6, lcn.room_temp_6, () async {
            await lcn.license_room_temp(6, context);
          }),
          license_room_temp_row_other(7, lcn.room_temp_7, () async {
            await lcn.license_room_temp(7, context);
          }),
          license_room_temp_row_other(8, lcn.room_temp_8, () async {
            await lcn.license_room_temp(8, context);
          }),
        ],
      );

  license_room_temp_row_0(LicenseChangeNotifier lcn) => ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        title: Text("Sensor 0", style: Theme.of(context).textTheme.bodyText1!),
        subtitle: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 18,
              color: Colors.red,
            ),
            SizedBox(
              width: 8,
            ),
            Text("Reuired", style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.red, fontSize: 10))
          ],
        ),
        trailing: Icon(
          lcn.room_temp_0 ? Icons.check_box : Icons.check_box_outline_blank,
          color: Theme.of(context).accentColor,
        ),
        onTap: () async {
          if (lcn.room_temp_0) {
            return;
          }
          var data = await Utils.ask_serial("You have to provdie license's serial number", context);
          if (data == "" && data != "null") {
            return;
          }
          bool is_valid = await Provider.of<ConnectionManager>(context, listen: false).setRequest(6, data, context);
          if (is_valid) {
            await lcn.license_room_temp(0, context);

            setState(() {});
          } else {
            Utils.showSnackBar(context, "Wrong serial number.");
          }
        },
      );

  license_room_temp_row_other(num, bool checked, VoidCallback onvalidated) => ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        title: Text("Sensor $num", style: Theme.of(context).textTheme.bodyText1!),
        subtitle: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 18,
            ),
            SizedBox(
              width: 8,
            ),
            Text("Optional", style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 10))
          ],
        ),
        trailing: Icon(
          checked ? Icons.check_box : Icons.check_box_outline_blank,
          color: Theme.of(context).accentColor,
        ),
        onTap: () async {
          if (checked) {
            return;
          }
          var data = await Utils.ask_serial("You have to provdie license's serial number", context);
          if (data == "" && data != "null") {
            return;
          }
          bool is_valid = await Provider.of<ConnectionManager>(context, listen: false).setRequest((num + 6), data, context);
          if (is_valid) {
            onvalidated();

            setState(() {});
          } else {
            Utils.showSnackBar(context, "Wrong serial number.");
          }
        },
      );

  List<String> _license_types = [
    "fan power to 600 W",
    "fan power to 900 W",
    "fan power to 1200 W",
    "fan power to 1500 W",
    "fan power to 1800 W",
    "fan power to 2100 W",
    "6 mobiles can connect to device"
  ];

  build_new_license_button(mcontext) => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 15),
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: OutlinedButton(
            onPressed: () {
              if (SavedDevicesChangeNotifier.getSelectedDevice()!.accessibility == DeviceAccessibility.AccessibleInternet) {
                Utils.setTimeOut(
                    0,
                    () => Utils.show_error_dialog(context, "Not Available", "users can't set licenses via internt.", () {}).then((value) {
                          // Navigator.pop(context);
                        }));
                return;
              }
              Utils.ask_license_type_serial(context, "Choose your license", "license:", _license_types, _license_types[0],
                  (String serial, String selected_option) async {
                if (serial != "") {
                  int index_selected = _license_types.indexOf(selected_option);
                  await Provider.of<ConnectionManager>(context, listen: false).setRequest(76, index_selected.toString(), context);
                  if (await Provider.of<ConnectionManager>(context, listen: false).setRequest(77, serial, context)) {
                    Utils.showSnackBar(context, "License accepted.");
                  } else {
                    Utils.showSnackBar(context, "License not accepted.");
                  }
                }
              });
            },
            style: OutlinedButton.styleFrom(
                padding: EdgeInsets.only(top: 16, bottom: 16, left: 28, right: 28),
                side: BorderSide(width: 2, color: Theme.of(context).primaryColor),
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(8.0))),
            child: Text("New License", style: Theme.of(context).textTheme.bodyText1),
          ),
        ),
      );

  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Consumer<LicenseChangeNotifier>(builder: (context, lcn, child) {
                  return Column(
                    children: [
                      Column(
                        children: [
                          license_power_box_row(lcn),
                          Divider(
                            height: 0,
                          ),
                          license_room_temp_row_expansion(lcn),
                          Divider(
                            height: 0,
                          ),
                          license_outdoor_temp_sesnsor_row(lcn),
                          Divider(
                            height: 0,
                          ),
                          license_gsm_modem_row(lcn),
                        ],
                      ),
                    ],
                  );
                }),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: build_new_license_button(context),
            )
          ],
        ),
      ),
    );
  }
}
