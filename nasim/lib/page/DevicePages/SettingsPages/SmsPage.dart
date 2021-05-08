import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:nasim/provider/ConnectionManager.dart';
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
  @override
  void initState() {
    super.initState();

    cmg = Provider.of<ConnectionManager>(context, listen: false);

    refresh();
  }

  refresh() async {
    var phonenum = await cmg.getRequest("get70");
    ConnectionManager.GSM_SIM_Number = phonenum == "timeout" ? ConnectionManager.GSM_SIM_Number : phonenum;

    var piror = await cmg.getRequest("get72");

    ConnectionManager.SMS_Priorities_State = piror == "timeout" ? ConnectionManager.SMS_Priorities_State : piror;

    setState(() {});
  }

  apply() async {
    if (!await cmg.set_request(70, Utils.lim_0_100(ConnectionManager.GSM_SIM_Number))) {
      Utils.handleError(context);
      return;
    }
    await cmg.set_request(72, ConnectionManager.SMS_Priorities_State);
  }

  Widget build_boxed_titlebox({required title, required child}) {
    // debugger();
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new InputDecorator(
            decoration: InputDecoration(
                labelText: title, labelStyle: Theme.of(context).textTheme.headline6, border: OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow))),
            child: child));
  }

  String replaceCharAt(String oldString, int index, String newChar) {
    return oldString.substring(0, index) + newChar + oldString.substring(index + 1);
  }

  Widget phone_number_input() => InternationalPhoneNumberInput(
        onInputChanged: (PhoneNumber number) {
          print(number.phoneNumber);
          if (number.phoneNumber != null) ConnectionManager.GSM_SIM_Number = number.phoneNumber!;
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
  Widget build_settings_fragment() => Container(
      padding: EdgeInsets.only(top: 10),
      color: Theme.of(context).canvasColor,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        build_boxed_titlebox(title: "Send sms to", child: phone_number_input()),
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
                  title: Text("60%", style: Theme.of(context).textTheme.bodyText1),
                ),
                ListTile(
                  leading: Text("Sim Number:", style: Theme.of(context).textTheme.bodyText1),
                  title: Text("+34123465789", style: Theme.of(context).textTheme.bodyText2),
                ),
                ListTile(
                  leading: Text("Sim Balance:", style: Theme.of(context).textTheme.bodyText1),
                  title: Text("5.63\$", style: Theme.of(context).textTheme.bodyText1),
                ),
              ],
            )),
        Expanded(
            child: Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [build_apply_button(), build_reset_button()],
          ),
        ))
      ]));
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
            child: Text("Apply", style: Theme.of(context).textTheme.headline6),
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
            child: Text("Restore Defaults", style: Theme.of(context).textTheme.headline6),
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
          value: ConnectionManager.SMS_Priorities_State[index] == "1",
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
        appBar: TabBar(
          labelStyle: Theme.of(context).textTheme.headline6,
          labelColor: Theme.of(context).textTheme.headline6!.color,
          // labelStyle: Theme.of(context).textTheme.headline6,
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
