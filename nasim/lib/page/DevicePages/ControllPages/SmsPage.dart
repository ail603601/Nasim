import 'dart:async';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:nasim/Widgets/NumericStepButton.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/provider/LicenseChangeNotifier.dart';
import 'package:nasim/utils.dart';
import 'package:provider/provider.dart';

import '../../../enums.dart';
import '../../../provider/SavedevicesChangeNofiter.dart';

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

  bool is_allowed = true;

  final TextEditingController temperature_failure_min_controller = TextEditingController();
  final TextEditingController temperature_failure_max_controller = TextEditingController();
  final TextEditingController posibility_of_asphyxia_min_controller = TextEditingController();
  final TextEditingController posibility_of_asphyxia_max_controller = TextEditingController();
  final TextEditingController over_presure_min_controller = TextEditingController();
  final TextEditingController over_presure_max_controller = TextEditingController();

  bool MODIFIED = false;

  String Old_Mobile_Number_0 = "";
  String Old_Mobile_Number_1 = "";
  String Old_Mobile_Number_2 = "";
  String Old_Mobile_Number_3 = "";
  String Old_Mobile_Number_4 = "";
  String Old_Mobile_Number_5 = "";

  String Old_Min_Valid_Pressure = "";
  String Old_Max_Valid_Pressure = "";
  String Old_Min_Valid_Temperature = "";
  String Old_Max_Valid_Temperature = "";
  String Old_Min_Valid_Asphyxia = "";
  String Old_Max_Valid_Asphyxia = "";

  bool check_phone_equal(String a1, String a2) {
    if (a1.length < 4) {
      a1 = "";
    }
    return a1 == a2;
  }

  bool check_modification() {
    if (check_phone_equal(ConnectionManager.Mobile_Number_0, Old_Mobile_Number_0) &&
        check_phone_equal(ConnectionManager.Mobile_Number_1, Old_Mobile_Number_1) &&
        check_phone_equal(ConnectionManager.Mobile_Number_2, Old_Mobile_Number_2) &&
        check_phone_equal(ConnectionManager.Mobile_Number_3, Old_Mobile_Number_3) &&
        check_phone_equal(ConnectionManager.Mobile_Number_4, Old_Mobile_Number_4) &&
        check_phone_equal(ConnectionManager.Mobile_Number_5, Old_Mobile_Number_5) &&
        Old_Min_Valid_Pressure == over_presure_min_controller.text &&
        Old_Max_Valid_Pressure == over_presure_max_controller.text &&
        Old_Min_Valid_Temperature == temperature_failure_min_controller.text &&
        Old_Max_Valid_Temperature == temperature_failure_max_controller.text &&
        Old_Min_Valid_Asphyxia == posibility_of_asphyxia_min_controller.text &&
        Old_Max_Valid_Asphyxia == posibility_of_asphyxia_max_controller.text) {
      MODIFIED = false;
    } else
      MODIFIED = true;

    setState(() {});
    return MODIFIED;
  }

  UniqueKey? keytile_reasons;
  UniqueKey? keytile_sim_info;
  bool reasons_expanded_initialy = false;
  bool sim_info_expanded_initialy = false;

  togletile_reasons() {
    setState(() {
      keytile_reasons = new UniqueKey();
      reasons_expanded_initialy = !reasons_expanded_initialy;
    });
  }

  togletile_sim_info() {
    setState(() {
      keytile_sim_info = new UniqueKey();
      sim_info_expanded_initialy = !sim_info_expanded_initialy;
    });
  }

  @override
  void initState() {
    super.initState();

    ConnectionManager.SMS_Priorities_State = ConnectionManager.SMS_Priorities_State == "" ? "0000000" : ConnectionManager.SMS_Priorities_State;
    temperature_failure_min_controller.addListener(() {
      check_modification();
    });
    temperature_failure_max_controller.addListener(() {
      check_modification();
    });
    posibility_of_asphyxia_min_controller.addListener(() {
      check_modification();
    });
    posibility_of_asphyxia_max_controller.addListener(() {
      check_modification();
    });
    over_presure_min_controller.addListener(() {
      check_modification();
    });
    over_presure_max_controller.addListener(() {
      check_modification();
    });

    cmg = Provider.of<ConnectionManager>(context, listen: false);
    lcn = Provider.of<LicenseChangeNotifier>(context, listen: false);
    is_allowed = lcn.gsm_modem;
    if (is_allowed) Utils.setTimeOut(0, refresh);
  }

  @override
  void dispose() {
    super.dispose();
  }

  refresh() async {
    await Utils.show_loading_timed(
        context: context,
        done: () async {
          ConnectionManager.Mobile_Number_0 = await cmg.getRequest(101, context);
          ConnectionManager.Mobile_Number_1 = await cmg.getRequest(102, context);
          ConnectionManager.Mobile_Number_2 = await cmg.getRequest(103, context);
          ConnectionManager.Mobile_Number_3 = await cmg.getRequest(104, context);
          ConnectionManager.Mobile_Number_4 = await cmg.getRequest(105, context);
          ConnectionManager.Mobile_Number_5 = await cmg.getRequest(106, context);

          ConnectionManager.Min_Valid_Pressure = (int.tryParse(await cmg.getRequest(132, context)) ?? "").toString();
          ConnectionManager.Max_Valid_Pressure = (int.tryParse(await cmg.getRequest(133, context)) ?? "").toString();
          ConnectionManager.Min_Valid_Temperature = (int.tryParse(await cmg.getRequest(134, context)) ?? "").toString();
          ConnectionManager.Max_Valid_Temperature = (int.tryParse(await cmg.getRequest(135, context)) ?? "").toString();
          ConnectionManager.Min_Valid_Asphyxia = (int.tryParse(await cmg.getRequest(136, context)) ?? "").toString();
          ConnectionManager.Max_Valid_Asphyxia = (int.tryParse(await cmg.getRequest(137, context)) ?? "").toString();

          Old_Mobile_Number_0 = ConnectionManager.Mobile_Number_0;
          Old_Mobile_Number_1 = ConnectionManager.Mobile_Number_1;
          Old_Mobile_Number_2 = ConnectionManager.Mobile_Number_2;
          Old_Mobile_Number_3 = ConnectionManager.Mobile_Number_3;
          Old_Mobile_Number_4 = ConnectionManager.Mobile_Number_4;
          Old_Mobile_Number_5 = ConnectionManager.Mobile_Number_5;

          Old_Min_Valid_Pressure = ConnectionManager.Min_Valid_Pressure;
          Old_Max_Valid_Pressure = ConnectionManager.Max_Valid_Pressure;
          Old_Min_Valid_Temperature = ConnectionManager.Min_Valid_Temperature;
          Old_Max_Valid_Temperature = ConnectionManager.Max_Valid_Temperature;
          Old_Min_Valid_Asphyxia = ConnectionManager.Min_Valid_Asphyxia;
          Old_Max_Valid_Asphyxia = ConnectionManager.Max_Valid_Asphyxia;
          over_presure_min_controller.text = ConnectionManager.Min_Valid_Pressure;
          over_presure_max_controller.text = ConnectionManager.Max_Valid_Pressure;
          temperature_failure_min_controller.text = ConnectionManager.Min_Valid_Temperature;
          temperature_failure_max_controller.text = ConnectionManager.Max_Valid_Temperature;
          posibility_of_asphyxia_min_controller.text = ConnectionManager.Min_Valid_Asphyxia;
          posibility_of_asphyxia_max_controller.text = ConnectionManager.Max_Valid_Asphyxia;

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

          ConnectionManager.GSM_SIM_Number = await cmg.getRequest(108, context);
          ConnectionManager.GSM_Signal_Power = (int.tryParse(await cmg.getRequest(107, context)) ?? 0).toString();
          ConnectionManager.GSM_SIM_Balance = (int.tryParse(await cmg.getRequest(109, context)) ?? 0).toString();
          ConnectionManager.SMS_Priorities_State = await cmg.getRequest(110, context);
          ConnectionManager.SMS_Priorities_State = ConnectionManager.SMS_Priorities_State == "" ? "0000000" : ConnectionManager.SMS_Priorities_State;
          check_modification();
          if (mounted) setState(() {});
        });
  }

  bool validate_inputs() {
    for (var i = 0; i < 6; i++) {
      switch (i) {
        case 0:
          if (ConnectionManager.Mobile_Number_0.length >= 4 && !is_validated[i]) return false;
          break;
        case 1:
          if (ConnectionManager.Mobile_Number_1.length >= 4 && !is_validated[i]) return false;
          break;
        case 2:
          if (ConnectionManager.Mobile_Number_2.length >= 4 && !is_validated[i]) return false;
          break;
        case 3:
          if (ConnectionManager.Mobile_Number_3.length >= 4 && !is_validated[i]) return false;
          break;
        case 4:
          if (ConnectionManager.Mobile_Number_4.length >= 4 && !is_validated[i]) return false;
          break;
        case 5:
          if (ConnectionManager.Mobile_Number_5.length >= 4 && !is_validated[i]) return false;
          break;
      }

      // for (var i = 0; i < current_mobile_sms_count; i++) {
      //   switch (i) {
      //     case 0:
      //       if (!is_validated[i]) return false;
      //       break;
      //     case 1:
      //       if (!is_validated[i]) return false;
      //       break;
      //     case 2:
      //       if (!is_validated[i]) return false;
      //       break;
      //     case 3:
      //       if (!is_validated[i]) return false;
      //       break;
      //     case 4:
      //       if (!is_validated[i]) return false;
      //       break;
      //     case 5:
      //       if (!is_validated[i]) return false;
      //       break;
      //   }
      // }

      // for (var i = 0; i < 6; i++) {
      //   switch (i) {
      //     case 0:
      //       if (!is_validated[i]) ConnectionManager.Mobile_Number_0 = "";
      //       break;
      //     case 1:
      //       if (!is_validated[i]) ConnectionManager.Mobile_Number_1 = "";
      //       break;
      //     case 2:
      //       if (!is_validated[i]) ConnectionManager.Mobile_Number_2 = "";
      //       break;
      //     case 3:
      //       if (!is_validated[i]) ConnectionManager.Mobile_Number_3 = "";
      //       break;
      //     case 4:
      //       if (!is_validated[i]) ConnectionManager.Mobile_Number_4 = "";
      //       break;
      //     case 5:
      //       if (!is_validated[i]) ConnectionManager.Mobile_Number_5 = "";
      //       break;
      //   }
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
    return true;
  }

  apply() async {
    if (!validate_inputs()) {
      Utils.show_error_dialog(context, "", "Invalid phone number.", null);
      return;
    }

    ConnectionManager.Min_Valid_Pressure = (int.tryParse(over_presure_min_controller.text) ?? 0).toString();
    ConnectionManager.Max_Valid_Pressure = (int.tryParse(over_presure_max_controller.text) ?? 0).toString();
    ConnectionManager.Min_Valid_Temperature = (int.tryParse(temperature_failure_min_controller.text) ?? 0).toString();
    ConnectionManager.Max_Valid_Temperature = (int.tryParse(temperature_failure_max_controller.text) ?? 0).toString();
    ConnectionManager.Min_Valid_Asphyxia = (int.tryParse(posibility_of_asphyxia_min_controller.text) ?? 0).toString();
    ConnectionManager.Max_Valid_Asphyxia = (int.tryParse(posibility_of_asphyxia_max_controller.text) ?? 0).toString();

    if (get_string_meaning(ConnectionManager.SMS_Priorities_State.characters.elementAt(3)) != "Off") {
      //Temperature MIN MAX
      if (int.parse(ConnectionManager.Min_Valid_Temperature) != 0 || int.parse(ConnectionManager.Max_Valid_Temperature) != 0) {
        if (int.parse(ConnectionManager.Min_Valid_Temperature) > int.parse(ConnectionManager.Max_Valid_Temperature)) {
          Utils.show_error_dialog(context, "", "Temperature maximum must be higher than minimum.");
          return;
        }
      }
      await cmg.setRequest(134, ConnectionManager.Min_Valid_Temperature, context);
      await cmg.setRequest(135, ConnectionManager.Max_Valid_Temperature, context);
    }
    if (get_string_meaning(ConnectionManager.SMS_Priorities_State.characters.elementAt(4)) != "Off") {
      //Asphyxia MIN MAX
      if (int.parse(ConnectionManager.Min_Valid_Asphyxia) != 0 || int.parse(ConnectionManager.Max_Valid_Asphyxia) != 0) {
        if (int.parse(ConnectionManager.Min_Valid_Asphyxia) > int.parse(ConnectionManager.Max_Valid_Asphyxia)) {
          Utils.show_error_dialog(context, "", "Asphyxia maximum must be higher than minimum.");
          return;
        }
      }
      await cmg.setRequest(136, ConnectionManager.Min_Valid_Asphyxia, context);
      await cmg.setRequest(137, ConnectionManager.Max_Valid_Asphyxia, context);
    }

    if (get_string_meaning(ConnectionManager.SMS_Priorities_State.characters.elementAt(5)) != "Off") {
      //Pressure MIN MAX
      if (int.parse(ConnectionManager.Min_Valid_Pressure) != 0 || int.parse(ConnectionManager.Max_Valid_Pressure) != 0) {
        if (int.parse(ConnectionManager.Min_Valid_Pressure) > int.parse(ConnectionManager.Max_Valid_Pressure)) {
          Utils.show_error_dialog(context, "", "Pressure maximum must be higher than minimum.");
          return;
        }
      }
      await cmg.setRequest(132, ConnectionManager.Min_Valid_Pressure, context);
      await cmg.setRequest(133, ConnectionManager.Max_Valid_Pressure, context);
    }

    // MODIFIED = false;
    await cmg.setRequest(101, ConnectionManager.Mobile_Number_0, context);
    await cmg.setRequest(102, ConnectionManager.Mobile_Number_1, context);
    await cmg.setRequest(103, ConnectionManager.Mobile_Number_2, context);
    await cmg.setRequest(104, ConnectionManager.Mobile_Number_3, context);
    await cmg.setRequest(105, ConnectionManager.Mobile_Number_4, context);
    await cmg.setRequest(106, ConnectionManager.Mobile_Number_5, context);
    await cmg.setRequest(110, ConnectionManager.SMS_Priorities_State, context);

    await refresh();

    Utils.showSnackBar(context, "Done.");
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
        setState(() {
          MODIFIED = true;
        });

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
        check_modification();
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
          build_boxed_titlebox(
              title: "Send SMS to",
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text("")),
                      TextButton(
                          onPressed: () {
                            current_mobile_sms_count++;
                            current_mobile_sms_count = min(current_mobile_sms_count, 5);
                            setState(() {});
                          },
                          child: Text("Add Phone Number", style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.blue)))
                      // NumericStepButton(
                      //   key: UniqueKey(),
                      //   minValue: 1,
                      //   current: current_mobile_sms_count,
                      //   maxValue: 5,
                      //   onChanged: (value) {
                      //     MODIFIED = true;
                      //     setState(() {
                      //       current_mobile_sms_count = value;
                      //     });
                      //   },
                      // )
                    ],
                  ),
                  ...gen_phone_row(current_mobile_sms_count)
                ],
              )),
          SizedBox(
            height: 16,
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
            onPressed: MODIFIED ? apply : null,
            style: OutlinedButton.styleFrom(
                padding: EdgeInsets.only(top: 8, bottom: 8, left: 28, right: 28),
                side: BorderSide(width: 2, color: MODIFIED ? Theme.of(context).primaryColor : Colors.grey),
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
            onPressed: () {
              AwesomeDialog(
                context: context,
                useRootNavigator: true,
                dialogType: DialogType.WARNING,
                animType: AnimType.BOTTOMSLIDE,
                title: "Confirm",
                desc: "Current Page Settings will be restored to factory defaults",
                btnOkOnPress: () async {
                  await cmg.setRequest(128, '7');
                  refresh();
                },
                btnCancelOnPress: () {},
              )..show();
            },
            style: OutlinedButton.styleFrom(
                padding: EdgeInsets.only(top: 16, bottom: 16, left: 28, right: 28),
                side: BorderSide(width: 2, color: Theme.of(context).primaryColor),
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(8.0))),
            child: Text("Restore To Factory Defaults", style: Theme.of(context).textTheme.bodyText1),
          ),
        ),
      );

  String get_string_meaning(String input) {
    if (input == "0") return "Off";
    if (input == "1") return "Low";
    if (input == "2") return "Medium";
    if (input == "3") return "Critical";

    return "parse failed.";
  }

  Widget min_max_temperature_failure() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 3,
                  style: Theme.of(context).textTheme.bodyText1,
                  controller: temperature_failure_min_controller,
                  onTap: () => temperature_failure_min_controller.selection =
                      TextSelection(baseOffset: 0, extentOffset: temperature_failure_min_controller.value.text.length),
                  keyboardType: TextInputType.numberWithOptions(decimal: false, signed: true),
                  decoration: InputDecoration(suffix: Text(' ppm'), counterText: "", labelText: "Min")),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 3,
                  style: Theme.of(context).textTheme.bodyText1,
                  controller: temperature_failure_max_controller,
                  onTap: () => temperature_failure_max_controller.selection =
                      TextSelection(baseOffset: 0, extentOffset: temperature_failure_max_controller.value.text.length),
                  keyboardType: TextInputType.numberWithOptions(decimal: false, signed: true),
                  decoration: InputDecoration(suffix: Text(' ppm'), counterText: "", labelText: "Max")),
            ),
          ),
        ],
      ),
    );
  }

  Widget min_max_posibility_of_asphyxia() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 3,
                  style: Theme.of(context).textTheme.bodyText1,
                  controller: posibility_of_asphyxia_min_controller,
                  onTap: () => posibility_of_asphyxia_min_controller.selection =
                      TextSelection(baseOffset: 0, extentOffset: posibility_of_asphyxia_min_controller.value.text.length),
                  keyboardType: TextInputType.numberWithOptions(decimal: false, signed: true),
                  decoration: InputDecoration(suffix: Text(' ppm'), counterText: "", labelText: "Min")),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 3,
                  style: Theme.of(context).textTheme.bodyText1,
                  controller: posibility_of_asphyxia_max_controller,
                  onTap: () => posibility_of_asphyxia_max_controller.selection =
                      TextSelection(baseOffset: 0, extentOffset: posibility_of_asphyxia_max_controller.value.text.length),
                  keyboardType: TextInputType.numberWithOptions(decimal: false, signed: true),
                  decoration: InputDecoration(suffix: Text(' ppm'), counterText: "", labelText: "Max")),
            ),
          ),
        ],
      ),
    );
  }

  Widget min_max_over_presure() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 3,
                  style: Theme.of(context).textTheme.bodyText1,
                  controller: over_presure_min_controller,
                  onTap: () =>
                      over_presure_min_controller.selection = TextSelection(baseOffset: 0, extentOffset: over_presure_min_controller.value.text.length),
                  keyboardType: TextInputType.numberWithOptions(decimal: false, signed: true),
                  decoration: InputDecoration(suffix: Text(' ppm'), counterText: "", labelText: "Min")),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 3,
                  style: Theme.of(context).textTheme.bodyText1,
                  controller: over_presure_max_controller,
                  onTap: () =>
                      over_presure_max_controller.selection = TextSelection(baseOffset: 0, extentOffset: over_presure_max_controller.value.text.length),
                  keyboardType: TextInputType.numberWithOptions(decimal: false, signed: true),
                  decoration: InputDecoration(suffix: Text(' ppm'), counterText: "", labelText: "Max")),
            ),
          ),
        ],
      ),
    );
  }

  bool sml = false;
  List<Widget> buildonoffrow(title, icon, int index, [bool divider = true]) => [
        ListTile(
          title: Text(title),
          trailing: TextButton(
            onPressed: () async {
              ChangeReasons(index);
            },
            child: Text(get_string_meaning(ConnectionManager.SMS_Priorities_State.characters.elementAt(index)),
                style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.blue)),
          ),
        ),
        if (index == 3 && get_string_meaning(ConnectionManager.SMS_Priorities_State.characters.elementAt(index)) != "Off") min_max_temperature_failure(),
        if (index == 4 && get_string_meaning(ConnectionManager.SMS_Priorities_State.characters.elementAt(index)) != "Off") min_max_posibility_of_asphyxia(),
        if (index == 5 && get_string_meaning(ConnectionManager.SMS_Priorities_State.characters.elementAt(index)) != "Off") min_max_over_presure(),
        if (divider)
          Divider(
            height: 2,
            thickness: 2,
          )
      ];

  Future<void> ChangeReasons(int index) async {
    int value = await showDialog<int>(
            context: context,
            builder: (BuildContext context) {
              return SimpleDialog(
                title: Text('Priority:', style: Theme.of(context).textTheme.bodyText1),
                children: <Widget>[
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 0);
                    },
                    child: const Text('Off'),
                  ),
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 1);
                    },
                    child: const Text('Low'),
                  ),
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 2);
                    },
                    child: const Text('Medium'),
                  ),
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 3);
                    },
                    child: const Text('Critical'),
                  ),
                ],
              );
            }) ??
        0;
    ConnectionManager.SMS_Priorities_State = replaceCharAt(ConnectionManager.SMS_Priorities_State, index, value.toString());
    MODIFIED = true;
    setState(() {});
  }

  Widget build_sim_info_box() => ExpansionTile(
        initiallyExpanded: sim_info_expanded_initialy,
        key: keytile_sim_info,
        tilePadding: EdgeInsets.only(right: 16),
        title: ListTile(
          title: Text("Sim Information", style: Theme.of(context).textTheme.bodyText1!),
          leading: Icon(Icons.sim_card),
          onTap: () {
            togletile_sim_info();
          },
        ),
        children: [
          SizedBox(
            height: 8,
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
                    title: Text(ConnectionManager.GSM_Signal_Power + " %", style: Theme.of(context).textTheme.bodyText1),
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
              ))
        ],
      );
  build_reasons_list() => ExpansionTile(
          initiallyExpanded: reasons_expanded_initialy,
          key: keytile_reasons,
          tilePadding: EdgeInsets.only(right: 16),
          title: ListTile(
            title: Text("Send Notification By", style: Theme.of(context).textTheme.bodyText1!),
            leading: Icon(Icons.sms),
            onTap: () {
              togletile_reasons();
            },
          ),
          children: [
            SizedBox(
              height: 8,
            ),
            build_boxed_titlebox(
                title: "Reasons",
                child: Column(
                  children: [
                    ...buildonoffrow("Power Failure", Icons.power, 0),
                    ...buildonoffrow("Inlet Fan falut", Icons.error_outline, 1),
                    ...buildonoffrow("Outlet Fan falut", Icons.error_outline, 2),
                    ...buildonoffrow("Temperature Failure", Icons.local_fire_department, 3),
                    ...buildonoffrow("Posibility of Asphyxia", Icons.night_shelter, 4),
                    ...buildonoffrow("Over Pressure", Icons.settings_overscan, 5),
                    ...buildonoffrow("Sim Balance Low", Icons.money_off, 6, false)
                  ],
                ))
          ]);

  Widget not_allowed_box(context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Gsm licence not provided"),
          TextButton(
            onPressed: () async {
              if (!is_locall_conntection(context)) return;
              var lcn = Provider.of<LicenseChangeNotifier>(context, listen: false);
              if (lcn.gsm_modem) {
                return;
              }
              var data = await Utils.ask_serial("You have to provdie license's serial number", context);
              if (data == "" || data == "null") {
                return;
              }
              bool is_valid = await Provider.of<ConnectionManager>(context, listen: false).setRequest(5, data, context);
              if (is_valid) {
                lcn.license_gsm_modem(context, false);
                is_allowed = true;
                // Utils.setTimeOut(100, () {
                refresh();
                // });
              } else {
                Utils.showSnackBar(
                  context,
                  "Wrong serial number.",
                );
              }
            },
            child: Text('Enter Gsm modem Licence', style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return is_allowed
        ? Scaffold(
            body: Column(
            children: [
              Container(
                color: Colors.black12,
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text("Sms Page", style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 24)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: SingleChildScrollView(
                      child: Column(
                children: [
                  build_settings_fragment(),
                  build_reasons_list(),
                  build_sim_info_box(),
                ],
              ))),
              build_apply_button(),
              build_reset_button(),
            ],
          ))
        : not_allowed_box(context);
  }
}
