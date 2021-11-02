import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:nasim/Widgets/NumericStepButton.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/provider/LicenseChangeNotifier.dart';
import 'package:nasim/utils.dart';
import 'package:provider/provider.dart';

class SmsPage extends StatefulWidget {
  @override
  _SmsPageState createState() => _SmsPageState();
}

class _SmsPageState extends State<SmsPage> {
  String initialCountry = 'IR';
  PhoneNumber number = PhoneNumber(isoCode: 'IR');
  late ConnectionManager cmg;
  late LicenseChangeNotifier lcn;
  List<bool> is_validated = [false, false, false, false, false, false];
  var numbers_to_show = [
    PhoneNumber(isoCode: 'IR'),
    PhoneNumber(isoCode: 'IR'),
    PhoneNumber(isoCode: 'IR'),
    PhoneNumber(isoCode: 'IR'),
    PhoneNumber(isoCode: 'IR'),
    PhoneNumber(isoCode: 'IR')
  ];

  @override
  void initState() {
    super.initState();

    ConnectionManager.SMS_Priorities_State = ConnectionManager.SMS_Priorities_State == "" ? "0000000" : ConnectionManager.SMS_Priorities_State;

    cmg = Provider.of<ConnectionManager>(context, listen: false);
    lcn = Provider.of<LicenseChangeNotifier>(context, listen: false);
    if (!lcn.gsm_modem) {
      Utils.setTimeOut(
          0,
          () => Utils.show_error_dialog(context, "No License", "Gsm modem license is required. use the license tab", () {}).then((value) {
                Navigator.pop(context);
              }));
    }

    refresh();
  }

  @override
  void dispose() {
    // refresher.cancel();
    super.dispose();
  }

  refresh() async {
    ConnectionManager.Mobile_Number_0 = await cmg.getRequest(101);
    ConnectionManager.Mobile_Number_1 = await cmg.getRequest(102);
    ConnectionManager.Mobile_Number_2 = await cmg.getRequest(103);
    ConnectionManager.Mobile_Number_3 = await cmg.getRequest(104);
    ConnectionManager.Mobile_Number_4 = await cmg.getRequest(105);
    ConnectionManager.Mobile_Number_5 = await cmg.getRequest(106);

    if (ConnectionManager.Mobile_Number_0 != "") {
      numbers_to_show[0] = await PhoneNumber.getRegionInfoFromPhoneNumber(ConnectionManager.Mobile_Number_0);
      current_mobile_sms_count = 1;
    }
    if (ConnectionManager.Mobile_Number_1 != "") {
      numbers_to_show[1] = await PhoneNumber.getRegionInfoFromPhoneNumber(ConnectionManager.Mobile_Number_1);

      current_mobile_sms_count = 2;
    }
    if (ConnectionManager.Mobile_Number_2 != "") {
      numbers_to_show[2] = await PhoneNumber.getRegionInfoFromPhoneNumber(ConnectionManager.Mobile_Number_2);

      current_mobile_sms_count = 3;
    }
    if (ConnectionManager.Mobile_Number_3 != "") {
      numbers_to_show[3] = await PhoneNumber.getRegionInfoFromPhoneNumber(ConnectionManager.Mobile_Number_3);

      current_mobile_sms_count = 4;
    }
    if (ConnectionManager.Mobile_Number_4 != "") {
      numbers_to_show[4] = await PhoneNumber.getRegionInfoFromPhoneNumber(ConnectionManager.Mobile_Number_4);

      current_mobile_sms_count = 5;
    }
    if (ConnectionManager.Mobile_Number_5 != "") {
      numbers_to_show[5] = await PhoneNumber.getRegionInfoFromPhoneNumber(ConnectionManager.Mobile_Number_5);

      current_mobile_sms_count = 6;
    }

    ConnectionManager.GSM_SIM_Number = await cmg.getRequest(108);
    ConnectionManager.GSM_Signal_Power = (int.tryParse(await cmg.getRequest(107)) ?? 0).toString();
    ConnectionManager.GSM_SIM_Balance = (int.tryParse(await cmg.getRequest(109)) ?? 0).toString();
    ConnectionManager.SMS_Priorities_State = await cmg.getRequest(110);
    ConnectionManager.SMS_Priorities_State = ConnectionManager.SMS_Priorities_State == "" ? "0000000" : ConnectionManager.SMS_Priorities_State;

    if (mounted) setState(() {});
  }

  void validate_inputs() {
    for (var i = 0; i < 6; i++) {
      switch (i) {
        case 0:
          if (!is_validated[i]) ConnectionManager.Mobile_Number_0 = "";
          break;
        case 1:
          if (!is_validated[i]) ConnectionManager.Mobile_Number_1 = "";
          break;
        case 2:
          if (!is_validated[i]) ConnectionManager.Mobile_Number_2 = "";
          break;
        case 3:
          if (!is_validated[i]) ConnectionManager.Mobile_Number_3 = "";
          break;
        case 4:
          if (!is_validated[i]) ConnectionManager.Mobile_Number_4 = "";
          break;
        case 5:
          if (!is_validated[i]) ConnectionManager.Mobile_Number_5 = "";
          break;
      }
    }

    if (current_mobile_sms_count == 1) {
      ConnectionManager.Mobile_Number_1 = "";
      ConnectionManager.Mobile_Number_2 = "";
      ConnectionManager.Mobile_Number_3 = "";
      ConnectionManager.Mobile_Number_4 = "";
      ConnectionManager.Mobile_Number_5 = "";
    }
    if (current_mobile_sms_count == 2) {
      ConnectionManager.Mobile_Number_2 = "";
      ConnectionManager.Mobile_Number_3 = "";
      ConnectionManager.Mobile_Number_4 = "";
      ConnectionManager.Mobile_Number_5 = "";
    }
    if (current_mobile_sms_count == 3) {
      ConnectionManager.Mobile_Number_3 = "";
      ConnectionManager.Mobile_Number_4 = "";
      ConnectionManager.Mobile_Number_5 = "";
    }
    if (current_mobile_sms_count == 4) {
      ConnectionManager.Mobile_Number_4 = "";
      ConnectionManager.Mobile_Number_5 = "";
    }
  }

  apply_phones() async {
    validate_inputs();

    await cmg.setRequest(101, ConnectionManager.Mobile_Number_0, context);
    await cmg.setRequest(102, ConnectionManager.Mobile_Number_1, context);
    await cmg.setRequest(103, ConnectionManager.Mobile_Number_2, context);
    await cmg.setRequest(104, ConnectionManager.Mobile_Number_3, context);
    await cmg.setRequest(105, ConnectionManager.Mobile_Number_4, context);
    await cmg.setRequest(106, ConnectionManager.Mobile_Number_5, context);
    await refresh();
    Utils.showSnackBar(context, "Done.");
  }

  apply_reasons() async {
    await cmg.setRequest(110, ConnectionManager.SMS_Priorities_State, context);
  }

  Widget build_boxed_titlebox({required title, required child}) {
    // debugger();
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new InputDecorator(
            decoration: InputDecoration(
                labelText: title, labelStyle: Theme.of(context).textTheme.bodyText1, border: OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow))),
            child: child));
  }

  String replaceCharAt(String oldString, int index, String newChar) {
    return oldString.substring(0, index) + newChar + oldString.substring(index + 1);
  }

  Widget phone_number_input(PhoneNumber initial, int i) {
    String def_val = "";
    switch (i) {
      case 0:
        def_val = ConnectionManager.Mobile_Number_0;
        break;
      case 1:
        def_val = ConnectionManager.Mobile_Number_1;
        break;
      case 2:
        def_val = ConnectionManager.Mobile_Number_2;
        break;
      case 3:
        def_val = ConnectionManager.Mobile_Number_3;
        break;
      case 4:
        def_val = ConnectionManager.Mobile_Number_4;
        break;
      case 5:
        def_val = ConnectionManager.Mobile_Number_5;
        break;
    }
    // await PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber, 'US');
    // PhoneNumber newnumber = PhoneNumber(isoCode: def_val == '' ? 'IR' : null, phoneNumber: def_val);

    return InternationalPhoneNumberInput(
      onInputChanged: (PhoneNumber number) {
        print(number.phoneNumber);
        if (number.phoneNumber != null)
          switch (i) {
            case 0:
              ConnectionManager.Mobile_Number_0 = number.phoneNumber!;
              break;
            case 1:
              ConnectionManager.Mobile_Number_1 = number.phoneNumber!;
              break;
            case 2:
              ConnectionManager.Mobile_Number_2 = number.phoneNumber!;
              break;
            case 3:
              ConnectionManager.Mobile_Number_3 = number.phoneNumber!;
              break;
            case 4:
              ConnectionManager.Mobile_Number_4 = number.phoneNumber!;
              break;
            case 5:
              ConnectionManager.Mobile_Number_5 = number.phoneNumber!;
              break;
          }
      },
      onInputValidated: (bool value) {
        is_validated[i] = value;
      },
      selectorConfig: SelectorConfig(
        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
      ),
      ignoreBlank: true,
      autoValidateMode: AutovalidateMode.always,
      selectorTextStyle: Theme.of(context).textTheme.bodyText1,
      initialValue: initial,
      textStyle: Theme.of(context).textTheme.bodyText1,
      // textFieldController: TextEditingController()..text = def_val,
      // textFieldController: controller,
      formatInput: false,
      keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
      inputBorder: OutlineInputBorder(),
    );
  }

  int current_mobile_sms_count = 1;
  List<Widget> gen_phone_row(count) {
    List<Widget> listed = [];

    for (var i = 0; i < count; i++) {
      listed.add(phone_number_input(numbers_to_show[i], i));

      listed.add(SizedBox(
        height: 16,
      ));
    }

    return listed;
  }

  Widget build_settings_fragment() => Container(
      padding: EdgeInsets.only(top: 10),
      color: Theme.of(context).canvasColor,
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // build_boxed_titlebox(title: "Send sms to", child: phone_number_input()),
          build_boxed_titlebox(
              title: "Send sms to",
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text("Count:")),
                      NumericStepButton(
                        key: UniqueKey(),
                        minValue: 1,
                        current: current_mobile_sms_count,
                        maxValue: 5,
                        onChanged: (value) {
                          setState(() {
                            current_mobile_sms_count = value;
                          });
                        },
                      )
                    ],
                  ),
                  ...gen_phone_row(current_mobile_sms_count)
                ],
              )),

          SizedBox(
            height: 16,
          ),
          build_boxed_titlebox(
              title: "GSM Modem",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: Text("Model:", style: Theme.of(context).textTheme.bodyText1),
                    title: Text("Elfin-EGLL", style: Theme.of(context).textTheme.bodyText1),
                  ),
                  ListTile(
                    leading: Text("Signal Power:", style: Theme.of(context).textTheme.bodyText1),
                    title: Text(ConnectionManager.GSM_Signal_Power + " db", style: Theme.of(context).textTheme.bodyText1),
                  ),
                  ListTile(
                    leading: Text("Sim Number:", style: Theme.of(context).textTheme.bodyText1),
                    title: Text(ConnectionManager.GSM_SIM_Number, style: Theme.of(context).textTheme.bodyText2),
                  ),
                  ListTile(
                    leading: Text("Sim Balance:", style: Theme.of(context).textTheme.bodyText1),
                    title: Text(ConnectionManager.GSM_SIM_Balance + " \$", style: Theme.of(context).textTheme.bodyText1),
                  ),
                ],
              )),
          SizedBox(
            height: 16,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              build_apply_button(),
            ],
          ),
        ]),
      ));
  build_apply_button() => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 15),
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: OutlinedButton(
            onPressed: () {
              apply_phones();
            },
            style: OutlinedButton.styleFrom(
                padding: EdgeInsets.only(top: 16, bottom: 16, left: 28, right: 28),
                side: BorderSide(width: 2, color: Theme.of(context).primaryColor),
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(8.0))),
            child: Text("Apply", style: Theme.of(context).textTheme.bodyText1),
          ),
        ),
      );
  build_reset_button() => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 15),
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
                padding: EdgeInsets.only(top: 16, bottom: 16, left: 28, right: 28),
                side: BorderSide(width: 2, color: Theme.of(context).primaryColor),
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(8.0))),
            child: Text("Restore Defaults", style: Theme.of(context).textTheme.bodyText1),
          ),
        ),
      );
  bool sml = false;
  List<Widget> buildonoffrow(title, icon, int index) => [
        SwitchListTile(
          secondary: Icon(icon),
          title: Text(title),
          onChanged: (value) {
            ConnectionManager.SMS_Priorities_State = replaceCharAt(ConnectionManager.SMS_Priorities_State, index, value ? "1" : "0");
            apply_reasons();
            setState(() {});
          },
          value: ConnectionManager.SMS_Priorities_State.characters.elementAt(index) == "1",
        ),
        Divider(
          height: 2,
          thickness: 2,
        )
      ];

  build_reasons_list() => Column(
        children: [
          ...buildonoffrow("Power On / Off", Icons.power, 0),
          ...buildonoffrow("Inlet Fan falut", Icons.error_outline, 1),
          ...buildonoffrow("Outlet Fan falut", Icons.error_outline, 2),
          ...buildonoffrow("Posibility of fire", Icons.local_fire_department, 3),
          ...buildonoffrow("Posibility of Asphyxia", Icons.night_shelter, 4),
          ...buildonoffrow("Over Presure", Icons.settings_overscan, 5),
          ...buildonoffrow("Sim Balance Low", Icons.money_off, 6)
        ],
      );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: TabBar(
          labelStyle: Theme.of(context).textTheme.bodyText1,
          labelColor: Theme.of(context).textTheme.bodyText1!.color,
          // labelStyle: Theme.of(context).textTheme.bodyText1,
          tabs: [
            Tab(
              text: "Settings",
            ),
            Tab(
              text: "Reasons",
            ),
          ],
        ),
        body: TabBarView(
          children: [
            build_settings_fragment(),
            build_reasons_list(),
          ],
        ),
      ),
    );
  }
}
