import 'package:flutter/material.dart';
import 'package:nasim/IntroductionScreen/introduction_screen.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/provider/LicenseChangeNotifier.dart';
import 'package:nasim/utils.dart';
import 'package:provider/provider.dart';

import '../Wizardpage.dart';

class wpage_license extends StatefulWidget {
  @override
  _wpage_licenseState createState() => _wpage_licenseState();

  bool Function()? Next = null;
}

class _wpage_licenseState extends State<wpage_license> {
  UniqueKey? keytile;
  bool expanded_initialy = false;
  @override
  void initState() {
    widget.Next = () {
      if (!can_go_next) {
        Utils.alert(context, "Error", "you have to provide Power Box and Room temperature 0 licenses in order to turn your device On.");
      }
      return can_go_next;
    };
    checkifnexyallowed(Provider.of<LicenseChangeNotifier>(context, listen: false));
    super.initState();
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
          bool is_valid = await Provider.of<ConnectionManager>(context, listen: false).set_request(5, data);
          if (is_valid) {
            lcn.license_gsm_modem();

            setState(() {});
            checkifnexyallowed(lcn);
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
        leading: Icon(Icons.sensor_door),
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
          bool is_valid = await Provider.of<ConnectionManager>(context, listen: false).set_request(15, data);
          if (is_valid) {
            lcn.license_outdoor_temp();
            setState(() {});
            checkifnexyallowed(lcn);
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
          bool is_valid = await Provider.of<ConnectionManager>(context, listen: false).set_request(4, data);
          if (is_valid) {
            lcn.license_power_box();

            setState(() {});
            checkifnexyallowed(lcn);
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
            await lcn.license_room_temp(1);
          }),
          license_room_temp_row_other(2, lcn.room_temp_2, () async {
            await lcn.license_room_temp(2);
          }),
          license_room_temp_row_other(3, lcn.room_temp_3, () async {
            await lcn.license_room_temp(3);
          }),
          license_room_temp_row_other(4, lcn.room_temp_4, () async {
            await lcn.license_room_temp(4);
          }),
          license_room_temp_row_other(5, lcn.room_temp_5, () async {
            await lcn.license_room_temp(5);
          }),
          license_room_temp_row_other(6, lcn.room_temp_6, () async {
            await lcn.license_room_temp(6);
          }),
          license_room_temp_row_other(7, lcn.room_temp_7, () async {
            await lcn.license_room_temp(7);
          }),
          license_room_temp_row_other(8, lcn.room_temp_8, () async {
            await lcn.license_room_temp(8);
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
          bool is_valid = await Provider.of<ConnectionManager>(context, listen: false).set_request(6, data);
          if (is_valid) {
            await lcn.license_room_temp(0);

            checkifnexyallowed(lcn);
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
          bool is_valid = await Provider.of<ConnectionManager>(context, listen: false).set_request((num + 6), data);
          if (is_valid) {
            onvalidated();

            setState(() {});
          } else {
            Utils.showSnackBar(context, "Wrong serial number.");
          }
        },
      );

  bool can_go_next = false;

  checkifnexyallowed(LicenseChangeNotifier lcn) {
    if (lcn.power_box && lcn.room_temp_0) {
      can_go_next = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // checkifnexyallowed(Provider.of<LicenseChangeNotifier>(context, listen: false));

    return Container(
        padding: const EdgeInsets.only(bottom: 64),
        child: SingleChildScrollView(
          child: Consumer<LicenseChangeNotifier>(builder: (context, lcn, child) {
            checkifnexyallowed(lcn);
            return Column(
              children: [
                hintbox(),
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
                license_gsm_modem_row(lcn)
              ],
            );
          }),
        ));
  }
}
