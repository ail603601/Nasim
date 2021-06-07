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
  @override
  void initState() {
    super.initState();

    cmg = Provider.of<ConnectionManager>(context, listen: false);
    lcn = Provider.of<LicenseChangeNotifier>(context, listen: false);
    if (!lcn.gsm_modem) {
      Utils.show_error_dialog(context, "No License", "you must provide gsm modem license. use the license tab", () {
        Navigator.pop(context);
      });
    }

    refresh();
  }

  refresh() async {
    ConnectionManager.Mobile_Name_0 = await cmg.getRequest_non0("get101");
    ConnectionManager.Mobile_Name_1 = await cmg.getRequest_non0("get102");
    ConnectionManager.Mobile_Name_2 = await cmg.getRequest_non0("get103");
    ConnectionManager.Mobile_Name_3 = await cmg.getRequest_non0("get104");
    ConnectionManager.Mobile_Name_4 = await cmg.getRequest_non0("get105");
    ConnectionManager.Mobile_Name_5 = await cmg.getRequest_non0("get106");
    if (ConnectionManager.Mobile_Name_0 != "") {
      current_mobile_sms_count = 1;
    }
    if (ConnectionManager.Mobile_Name_1 != "") {
      current_mobile_sms_count = 2;
    }
    if (ConnectionManager.Mobile_Name_2 != "") {
      current_mobile_sms_count = 3;
    }
    if (ConnectionManager.Mobile_Name_3 != "") {
      current_mobile_sms_count = 4;
    }
    if (ConnectionManager.Mobile_Name_4 != "") {
      current_mobile_sms_count = 5;
    }
    if (ConnectionManager.Mobile_Name_5 != "") {
      current_mobile_sms_count = 6;
    }

    ConnectionManager.GSM_SIM_Number = await cmg.getRequest("get108");
    ConnectionManager.GSM_Signal_Power = await cmg.getRequest("get107");
    ConnectionManager.GSM_SIM_Balance = await cmg.getRequest("get109");

    ConnectionManager.SMS_Priorities_State = await cmg.getRequest("get110");

    setState(() {});
  }

  apply() async {
    await cmg.set_request(101, ConnectionManager.Mobile_Number_0);
    await cmg.set_request(102, ConnectionManager.Mobile_Number_1);
    await cmg.set_request(103, ConnectionManager.Mobile_Number_2);
    await cmg.set_request(104, ConnectionManager.Mobile_Number_3);
    await cmg.set_request(105, ConnectionManager.Mobile_Number_4);
    await cmg.set_request(106, ConnectionManager.Mobile_Number_5);

    await cmg.set_request(110, ConnectionManager.SMS_Priorities_State);
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

  Widget phone_number_input(int i) => InternationalPhoneNumberInput(
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
          print(value);
        },
        selectorConfig: SelectorConfig(
          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
        ),
        ignoreBlank: false,
        autoValidateMode: AutovalidateMode.disabled,
        selectorTextStyle: Theme.of(context).textTheme.bodyText1,
        initialValue: number,
        textStyle: Theme.of(context).textTheme.bodyText1,
        // textFieldController: controller,
        formatInput: false,
        keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
        inputBorder: OutlineInputBorder(),

        onSaved: (PhoneNumber number) {
          print('On Saved: $number');
        },
      );

  int current_mobile_sms_count = 1;
  List<Widget> gen_phone_row(count) {
    List<Widget> listed = [];
    for (var i = 0; i < count; i++) {
      listed.add(phone_number_input(i));
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
                        minValue: 1,
                        maxValue: 6,
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
                    title: Text(ConnectionManager.GSM_Signal_Power, style: Theme.of(context).textTheme.bodyText1),
                  ),
                  ListTile(
                    leading: Text("Sim Number:", style: Theme.of(context).textTheme.bodyText1),
                    title: Text(ConnectionManager.GSM_SIM_Number, style: Theme.of(context).textTheme.bodyText2),
                  ),
                  ListTile(
                    leading: Text("Sim Balance:", style: Theme.of(context).textTheme.bodyText1),
                    title: Text(ConnectionManager.GSM_SIM_Balance, style: Theme.of(context).textTheme.bodyText1),
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
              apply();
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
            apply();
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
