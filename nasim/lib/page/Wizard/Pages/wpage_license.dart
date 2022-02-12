import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
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
  bool Function()? Back = null;
}

class _wpage_licenseState extends State<wpage_license> {
  UniqueKey? keytile;
  bool expanded_initialy = false;
  int parse_device_fan(int i) {
    if (i == 0) return 300;
    if (i == 1) return 600;
    if (i == 2) return 900;
    if (i == 3) return 1200;
    if (i == 4) return 1500;
    if (i == 5) return 1800;
    if (i == 6) return 2100;

    return 0;
  }

  late ConnectionManager cmg;
  String parsed_fan_power = "loading...";

  @override
  void initState() {
    widget.Next = () {
      if (!can_go_next) {
        Utils.alert(context, "Error", "You have to provide Power Box and Room temperature 0 licenses in order to turn your device On.");
      }
      return can_go_next;
    };
    checkifnextallowed(Provider.of<LicenseChangeNotifier>(context, listen: false));
    cmg = Provider.of<ConnectionManager>(context, listen: false);
    cmg.getRequest(39, context).then((value) {
      ConnectionManager.Real_Output_Fan_Power = (int.tryParse(value) ?? "0").toString();
      parsed_fan_power = parse_device_fan(int.parse(ConnectionManager.Real_Output_Fan_Power)).toString();
    });

    super.initState();
  }

  Future<bool> ask_re_enter_serial({bool is_for_powerbox = false}) {
    Completer<bool> comp = new Completer();
    AwesomeDialog(
      context: context,
      useRootNavigator: true,
      dialogType: DialogType.WARNING,
      animType: AnimType.BOTTOMSLIDE,
      title: "Confirm",
      desc: (is_for_powerbox ? "Device Fan Power: ${parsed_fan_power} W\n" : "") + "Are you sure you want to change the serial number? ",
      btnOkOnPress: () async {
        comp.complete(true);
      },
      btnCancelOnPress: () {
        comp.complete(false);
      },
      onDissmissCallback: (type) {
        comp.complete(false);
      },
    )..show();
    return comp.future;
  }

  hintbox() => Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        color: Theme.of(context).hintColor,
        child: Text("In order to continue:\nyou have to provide required licenses.\nyou can enter other licenses later.",
            style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.white)),
      );

  license_6_mobile_row(LicenseChangeNotifier lcn) => ListTile(
        title: Text("6 Mobile Connection", style: Theme.of(context).textTheme.bodyText1!),
        subtitle: Row(
          children: [
            if (!lcn.six_mobiles)
              Icon(
                Icons.info_outline,
                size: 18,
              ),
            SizedBox(
              width: 8,
            ),
            lcn.six_mobiles
                ? Text("Registered", style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 10, color: Colors.green))
                : Text("Optional", style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 10))
          ],
        ),
        leading: Icon(Icons.phone_android),
        trailing: Icon(
          lcn.six_mobiles ? Icons.check_box : Icons.check_box_outline_blank,
          color: Theme.of(context).accentColor,
        ),
        onTap: () async {
          if (lcn.six_mobiles && !await ask_re_enter_serial()) {
            return;
          }
          var data = await Utils.ask_serial("You have to provdie license's serial number", context);
          if (data == "" || data == "null") {
            return;
          }
          bool is_valid = await Provider.of<ConnectionManager>(context, listen: false).setRequest(138, data, context);
          if (is_valid) {
            lcn.license_6_mobiles(context);

            setState(() {});
            checkifnextallowed(lcn);
          } else {
            Utils.showSnackBar(context, "Wrong serial number.");
          }
        },
      );
  license_gsm_modem_row(LicenseChangeNotifier lcn) => ListTile(
        title: Text("GSM Modem", style: Theme.of(context).textTheme.bodyText1!),
        subtitle: Row(
          children: [
            if (!lcn.gsm_modem)
              Icon(
                Icons.info_outline,
                size: 18,
              ),
            SizedBox(
              width: 8,
            ),
            lcn.gsm_modem
                ? Text("Registered", style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 10, color: Colors.green))
                : Text("Optional", style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 10))
          ],
        ),
        leading: Icon(Icons.sim_card),
        trailing: Icon(
          lcn.gsm_modem ? Icons.check_box : Icons.check_box_outline_blank,
          color: Theme.of(context).accentColor,
        ),
        onTap: () async {
          if (lcn.gsm_modem && !await ask_re_enter_serial()) {
            return;
          }
          var data = await Utils.ask_serial("You have to provdie license's serial number", context);
          if (data == "" || data == "null") {
            return;
          }
          bool is_valid = await Provider.of<ConnectionManager>(context, listen: false).setRequest(5, data, context);
          if (is_valid) {
            lcn.license_gsm_modem(context);

            setState(() {});
            checkifnextallowed(lcn);
          } else {
            Utils.showSnackBar(context, "Wrong serial number.");
          }
        },
      );
  license_outdoor_temp_sesnsor_row(LicenseChangeNotifier lcn) => ListTile(
        title: Text("Outdoor Temperature Sensor", style: Theme.of(context).textTheme.bodyText1!),
        subtitle: Row(children: [
          if (!lcn.outdoor_temp)
            Icon(
              Icons.info_outline,
              size: 18,
            ),
          SizedBox(
            width: 8,
          ),
          lcn.outdoor_temp
              ? Text("Registered", style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 10, color: Colors.green))
              : Text("Optional", style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 10))
        ]),
        leading: Icon(Icons.thermostat_rounded),
        trailing: Icon(
          lcn.outdoor_temp ? Icons.check_box : Icons.check_box_outline_blank,
          color: Theme.of(context).accentColor,
        ),
        onTap: () async {
          if (lcn.outdoor_temp && !await ask_re_enter_serial()) {
            return;
          }
          var data = await Utils.ask_serial("You have to provdie license's serial number", context);
          if (data == "" || data == "null") {
            return;
          }
          bool is_valid = await Provider.of<ConnectionManager>(context, listen: false).setRequest(15, data, context);
          if (is_valid) {
            lcn.license_outdoor_temp(context);
            setState(() {});
            checkifnextallowed(lcn);
          } else {
            Utils.showSnackBar(context, "Wrong serial number.");
          }
        },
      );
  license_power_box_row(LicenseChangeNotifier lcn) => ListTile(
        title: Text("Power Box", style: Theme.of(context).textTheme.bodyText1!),
        subtitle: Row(
          children: [
            if (!lcn.power_box)
              Icon(
                Icons.info_outline,
                size: 18,
                color: Colors.red,
              ),
            SizedBox(
              width: 8,
            ),
            lcn.power_box
                ? Text("Registered", style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 10, color: Colors.green))
                : Text("Required", style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.red, fontSize: 10))
          ],
        ),
        leading: Icon(Icons.power),
        trailing: Icon(
          lcn.power_box ? Icons.check_box : Icons.check_box_outline_blank,
          color: Theme.of(context).accentColor,
        ),
        onTap: () async {
          if (lcn.power_box && !await ask_re_enter_serial(is_for_powerbox: true)) {
            return;
          }
          var data = await Utils.ask_serial("You have to provdie license's serial number", context);
          if (data == "" || data == "null") {
            return;
          }
          bool is_valid = await Provider.of<ConnectionManager>(context, listen: false).setRequest(4, data, context);
          if (is_valid) {
            lcn.license_power_box(context);

            setState(() {});
            checkifnextallowed(lcn);
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
          title: Text("Room Temperature Sensor", style: Theme.of(context).textTheme.bodyText1!),
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
            if (!lcn.room_temp_0)
              Icon(
                Icons.info_outline,
                size: 18,
                color: Colors.red,
              ),
            SizedBox(
              width: 8,
            ),
            lcn.room_temp_0
                ? Text("Registered", style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 10, color: Colors.green))
                : Text("Required", style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.red, fontSize: 10))
          ],
        ),
        trailing: Icon(
          lcn.room_temp_0 ? Icons.check_box : Icons.check_box_outline_blank,
          color: Theme.of(context).accentColor,
        ),
        onTap: () async {
          if (lcn.room_temp_0 && !await ask_re_enter_serial()) {
            return;
          }
          var data = await Utils.ask_serial("You have to provdie license's serial number", context);
          if (data == "" || data == "null") {
            return;
          }
          bool is_valid = await Provider.of<ConnectionManager>(context, listen: false).setRequest(6, data, context);
          if (is_valid) {
            await lcn.license_room_temp(0, context);

            checkifnextallowed(lcn);
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
            if (!checked)
              Icon(
                Icons.info_outline,
                size: 18,
              ),
            SizedBox(
              width: 8,
            ),
            checked
                ? Text("Registered", style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 10, color: Colors.green))
                : Text("Optional", style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 10))
          ],
        ),
        trailing: Icon(
          checked ? Icons.check_box : Icons.check_box_outline_blank,
          color: Theme.of(context).accentColor,
        ),
        onTap: () async {
          if (checked && !await ask_re_enter_serial()) {
            return;
          }
          var data = await Utils.ask_serial("You have to provdie license's serial number", context);
          if (data == "" || data == "null") {
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

  bool can_go_next = false;

  checkifnextallowed(LicenseChangeNotifier lcn) {
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
            checkifnextallowed(lcn);
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
                license_gsm_modem_row(lcn),
                Divider(
                  height: 0,
                ),
                license_6_mobile_row(lcn)
              ],
            );
          }),
        ));
  }
}
