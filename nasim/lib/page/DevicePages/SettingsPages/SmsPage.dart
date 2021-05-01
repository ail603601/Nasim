import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class SmsPage extends StatefulWidget {
  @override
  _SmsPageState createState() => _SmsPageState();
}

class _SmsPageState extends State<SmsPage> {
  String initialCountry = 'IR';
  PhoneNumber number = PhoneNumber(isoCode: 'IR');

  Widget build_boxed_titlebox({required title, required child}) {
    // debugger();
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new InputDecorator(
            decoration: InputDecoration(
                labelText: title, labelStyle: Theme.of(context).textTheme.headline6, border: OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow))),
            child: child));
  }

  Widget phone_number_input() => InternationalPhoneNumberInput(
        onInputChanged: (PhoneNumber number) {
          print(number.phoneNumber);
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
            onPressed: () {},
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
  List<Widget> buildonoffrow(title, icon) => [
        SwitchListTile(
          secondary: Icon(icon),
          title: Text(title),
          onChanged: (value) {
            setState(() {});
          },
          value: sml,
        ),
        Divider(
          height: 2,
          thickness: 2,
        )
      ];

  build_reasons_list() => Column(
        children: [
          ...buildonoffrow("Power On / Off", Icons.power),
          ...buildonoffrow("Inlet Fan falut", Icons.error_outline),
          ...buildonoffrow("Outlet Fan falut", Icons.error_outline),
          ...buildonoffrow("Posibility of fire", Icons.local_fire_department),
          ...buildonoffrow("Posibility of Asphyxia", Icons.night_shelter),
          ...buildonoffrow("Over Presure", Icons.settings_overscan),
          ...buildonoffrow("Sim Balance Low", Icons.money_off)
        ],
      );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: TabBar(
          labelStyle: Theme.of(context).textTheme.headline6,
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
