import 'dart:async';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nasim/Widgets/MyTooltip.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:provider/provider.dart';

import '../../../utils.dart';

class TemperaturePage extends StatefulWidget {
  @override
  _TemperaturePageState createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> with SingleTickerProviderStateMixin {
  late ConnectionManager cmg;
  TabController? _tabController;

  bool set_inprogress = false;

  late Timer soft_reftresh_timer;

  final TextEditingController room_temp_controller = TextEditingController();
  final TextEditingController room_temp_sensivity_controller = TextEditingController();
  final TextEditingController cooler_start_temp_controller = TextEditingController();
  final TextEditingController cooler_stop_temp_controller = TextEditingController();
  final TextEditingController heater_start_temp_controller = TextEditingController();
  final TextEditingController heater_stop_temp_controller = TextEditingController();

  String Old_Favourite_Room_Temp_Day_ = "";
  String Old_Favourite_Room_Temp_Night = "";
  String Old_Room_Temp_Sensitivity_Day = "";
  String Old_Room_Temp_Sensitivity_Night = "";
  String Old_Cooler_Start_Temp_Day = "";
  String Old_Cooler_Start_Temp_Night = "";
  String Old_Cooler_Stop_Temp_Day = "";
  String Old_Cooler_Stop_Temp_Night = "";
  String Old_Heater_Start_Temp_Day = "";
  String Old_Heater_Start_Temp_Night = "";
  String Old_Heater_Stop_Temp_Day = "";
  String Old_Heater_Stop_Temp_Night = "";
  bool MODIFIED = false;

  bool check_modification() {
    if (is_night) {
      if (Old_Favourite_Room_Temp_Night == room_temp_controller.text.toString() &&
          Old_Room_Temp_Sensitivity_Night == room_temp_sensivity_controller.text.toString() &&
          Old_Cooler_Start_Temp_Night == cooler_start_temp_controller.text.toString() &&
          Old_Cooler_Stop_Temp_Night == cooler_stop_temp_controller.text.toString() &&
          Old_Heater_Start_Temp_Night == heater_start_temp_controller.text.toString() &&
          Old_Heater_Stop_Temp_Night == heater_stop_temp_controller.text.toString()) {
        MODIFIED = false;
      } else
        MODIFIED = true;
    } else {
      if (Old_Favourite_Room_Temp_Day_ == room_temp_controller.text.toString() &&
          Old_Room_Temp_Sensitivity_Day == room_temp_sensivity_controller.text.toString() &&
          Old_Cooler_Start_Temp_Day == cooler_start_temp_controller.text.toString() &&
          Old_Cooler_Stop_Temp_Day == cooler_stop_temp_controller.text.toString() &&
          Old_Heater_Start_Temp_Day == heater_start_temp_controller.text.toString() &&
          Old_Heater_Stop_Temp_Day == heater_stop_temp_controller.text.toString()) {
        MODIFIED = false;
      } else
        MODIFIED = true;
    }

    return MODIFIED;
  }

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: tabs.length);

    _tabController!.addListener(() {
      is_night = _tabController!.index == 1;
      refresh();
    });
    soft_reftresh_timer = Timer.periodic(new Duration(seconds: 1), (timer) async {
      soft_refresh();
    });
    cmg = Provider.of<ConnectionManager>(context, listen: false);

    room_temp_controller.addListener(() {
      check_modification();
    });
    room_temp_sensivity_controller.addListener(() {
      check_modification();
    });
    cooler_start_temp_controller.addListener(() {
      check_modification();
    });
    cooler_stop_temp_controller.addListener(() {
      check_modification();
    });
    heater_start_temp_controller.addListener(() {
      check_modification();
    });
    heater_stop_temp_controller.addListener(() {
      check_modification();
    });

    Utils.setTimeOut(0, refresh);
  }

  @override
  void dispose() {
    super.dispose();

    _tabController!.dispose();
    soft_reftresh_timer.cancel();
  }

  void soft_refresh() async {
    ConnectionManager.Real_Room_Temp_0 = (int.tryParse(await cmg.getRequest(79, context)) ?? 0).toString();
    ConnectionManager.Real_Outdoor_Temp = (int.tryParse(await cmg.getRequest(89, context)) ?? 0).toString();
    if (mounted) setState(() {});
  }

  refresh() async {
    await Utils.show_loading_timed(
        context: context,
        done: () async {
          if (is_night) {
            ConnectionManager.Favourite_Room_Temp_Night = (int.tryParse(await cmg.getRequest(53, context)) ?? 0).toString();
            ConnectionManager.Room_Temp_Sensitivity_Night = (double.tryParse(await cmg.getRequest(54, context)) ?? 0).toString();
            ConnectionManager.Cooler_Start_Temp_Night = (int.tryParse(await cmg.getRequest(55, context)) ?? 0).toString();
            ConnectionManager.Cooler_Stop_Temp_Night = (int.tryParse(await cmg.getRequest(56, context)) ?? 0).toString();
            ConnectionManager.Heater_Start_Temp_Night = (int.tryParse(await cmg.getRequest(57, context)) ?? 0).toString();
            ConnectionManager.Heater_Stop_Temp_Night = (int.tryParse(await cmg.getRequest(58, context)) ?? 0).toString();
            Old_Favourite_Room_Temp_Night = ConnectionManager.Favourite_Room_Temp_Night;

            Old_Room_Temp_Sensitivity_Night = ConnectionManager.Room_Temp_Sensitivity_Night;
            Old_Cooler_Start_Temp_Night = ConnectionManager.Cooler_Start_Temp_Night;
            Old_Cooler_Stop_Temp_Night = ConnectionManager.Cooler_Stop_Temp_Night;
            Old_Heater_Start_Temp_Night = ConnectionManager.Heater_Start_Temp_Night;
            Old_Heater_Stop_Temp_Night = ConnectionManager.Heater_Stop_Temp_Night;
          } else {
            ConnectionManager.Favourite_Room_Temp_Day_ = (int.tryParse(await cmg.getRequest(47, context)) ?? 0).toString();
            ConnectionManager.Room_Temp_Sensitivity_Day = (double.tryParse(await cmg.getRequest(48, context)) ?? 0).toString();
            ConnectionManager.Cooler_Start_Temp_Day = (int.tryParse(await cmg.getRequest(49, context)) ?? 0).toString();
            ConnectionManager.Cooler_Stop_Temp_Day = (int.tryParse(await cmg.getRequest(50, context)) ?? 0).toString();
            ConnectionManager.Heater_Start_Temp_Day = (int.tryParse(await cmg.getRequest(51, context)) ?? 0).toString();
            ConnectionManager.Heater_Stop_Temp_Day = (int.tryParse(await cmg.getRequest(52, context)) ?? 0).toString();

            Old_Favourite_Room_Temp_Day_ = ConnectionManager.Favourite_Room_Temp_Day_;
            Old_Room_Temp_Sensitivity_Day = ConnectionManager.Room_Temp_Sensitivity_Day;
            Old_Cooler_Start_Temp_Day = ConnectionManager.Cooler_Start_Temp_Day;
            Old_Cooler_Stop_Temp_Day = ConnectionManager.Cooler_Stop_Temp_Day;
            Old_Heater_Start_Temp_Day = ConnectionManager.Heater_Start_Temp_Day;
            Old_Heater_Stop_Temp_Day = ConnectionManager.Heater_Stop_Temp_Day;
          }
          if (mounted)
            setState(() {
              if (is_night) {
                room_temp_controller.text = (int.tryParse(ConnectionManager.Favourite_Room_Temp_Night) ?? 0).toString();
                room_temp_sensivity_controller.text = ((double.tryParse(ConnectionManager.Room_Temp_Sensitivity_Night) ?? 0.0)).toString();
                cooler_start_temp_controller.text = (int.tryParse(ConnectionManager.Cooler_Start_Temp_Night) ?? 0).toString();
                cooler_stop_temp_controller.text = (int.tryParse(ConnectionManager.Cooler_Stop_Temp_Night) ?? 0).toString();
                heater_start_temp_controller.text = (int.tryParse(ConnectionManager.Heater_Start_Temp_Night) ?? 0).toString();
                heater_stop_temp_controller.text = (int.tryParse(ConnectionManager.Heater_Stop_Temp_Night) ?? 0).toString();
              } else {
                room_temp_controller.text = (int.tryParse(ConnectionManager.Favourite_Room_Temp_Day_) ?? 0).toString();
                room_temp_sensivity_controller.text = ((double.tryParse(ConnectionManager.Room_Temp_Sensitivity_Day) ?? 0.0)).toString();
                cooler_start_temp_controller.text = (int.tryParse(ConnectionManager.Cooler_Start_Temp_Day) ?? 0).toString();
                cooler_stop_temp_controller.text = (int.tryParse(ConnectionManager.Cooler_Stop_Temp_Day) ?? 0).toString();
                heater_start_temp_controller.text = (int.tryParse(ConnectionManager.Heater_Start_Temp_Day) ?? 0).toString();
                heater_stop_temp_controller.text = (int.tryParse(ConnectionManager.Heater_Stop_Temp_Day) ?? 0).toString();
              }
            });
        });
  }

  apply_temp() async {
    try {
      int _room_temp = (int.tryParse(room_temp_controller.text) ?? 0);
      double _room_temp_sensivity = (double.tryParse(room_temp_sensivity_controller.text) ?? 0.0);
      int _cooler_start_temp = (int.tryParse(cooler_start_temp_controller.text) ?? 0);
      int _cooler_stop_temp = (int.tryParse(cooler_stop_temp_controller.text) ?? 0);
      int _heater_start_temp = (int.tryParse(heater_start_temp_controller.text) ?? 0);
      int _heater_stop_temp = (int.tryParse(heater_stop_temp_controller.text) ?? 0);

      if (!(_cooler_start_temp > _cooler_stop_temp)) {
        Utils.alert(context, "Error", "Cooler start temperature must be higher than Cooler stop temperature.");
        return;
      }

      if (!(_cooler_start_temp > (_room_temp + _room_temp_sensivity))) {
        Utils.alert(context, "Error", "Cooler start temperature must be higher than Desired Temperature.");
        return;
      }
      if (!(_cooler_stop_temp >= (_room_temp + _room_temp_sensivity))) {
        Utils.alert(context, "Error", "Cooler stop temperature must be higher than Desired Temperature.");
        return;
      }
      if (!(_room_temp_sensivity > 0)) {
        Utils.alert(context, "Error", "Sensitivity must be positive.");
        return;
      }
      if (!(_room_temp_sensivity <= 2)) {
        Utils.alert(context, "Error", "Sensitivity maximum is 2.");
        return;
      }

      if (!(_heater_start_temp < _heater_stop_temp)) {
        Utils.alert(context, "Error", "Heater start temperature must be lower than Desired Temperature.");
        return;
      }

      if (!(_heater_start_temp < (_room_temp - _room_temp_sensivity))) {
        Utils.alert(context, "Error", "Heater start temperature must be lower than Desired Temperature.");
        return;
      }

      if (!(_heater_stop_temp <= (_room_temp - _room_temp_sensivity))) {
        Utils.alert(context, "Error", "Heater stop temperature must be lower than Desired Temperature.");
        return;
      }
      await Utils.show_loading_timed(
          context: context,
          done: () async {
            if (_tabController!.index == 0) {
              ConnectionManager.Favourite_Room_Temp_Day_ = (int.tryParse(room_temp_controller.text) ?? 0).toString().padLeft(3, '0');
              double val_f = (double.tryParse(room_temp_sensivity_controller.text) ?? 0.0);
              ConnectionManager.Room_Temp_Sensitivity_Day = max(0, min((val_f), 2)).toString().padLeft(3, '0');
              ConnectionManager.Cooler_Start_Temp_Day = (int.tryParse(cooler_start_temp_controller.text) ?? 0).toString().padLeft(3, '0');
              ConnectionManager.Cooler_Stop_Temp_Day = (int.tryParse(cooler_stop_temp_controller.text) ?? 0).toString().padLeft(3, '0');
              ConnectionManager.Heater_Start_Temp_Day = (int.tryParse(heater_start_temp_controller.text) ?? 0).toString().padLeft(3, '0');
              ConnectionManager.Heater_Stop_Temp_Day = (int.tryParse(heater_stop_temp_controller.text) ?? 0).toString().padLeft(3, '0');

              //Day Time
              await cmg.setRequest(47, Utils.sign_int_100(ConnectionManager.Favourite_Room_Temp_Day_), context);
              await cmg.setRequest(48, (ConnectionManager.Room_Temp_Sensitivity_Day), context);
              await cmg.setRequest(49, Utils.sign_int_100(ConnectionManager.Cooler_Start_Temp_Day), context);
              await cmg.setRequest(50, Utils.sign_int_100(ConnectionManager.Cooler_Stop_Temp_Day), context);
              await cmg.setRequest(51, Utils.sign_int_100(ConnectionManager.Heater_Start_Temp_Day), context);
              await cmg.setRequest(52, Utils.sign_int_100(ConnectionManager.Heater_Stop_Temp_Day), context);
            } else {
              ConnectionManager.Favourite_Room_Temp_Night = (int.tryParse(room_temp_controller.text) ?? 0).toString().padLeft(3, '0');
              double val_f = (double.tryParse(room_temp_sensivity_controller.text) ?? 0.0);
              ConnectionManager.Room_Temp_Sensitivity_Night = max(0, min((val_f), 2)).toString().padLeft(3, '0');
              ConnectionManager.Cooler_Start_Temp_Night = (int.tryParse(cooler_start_temp_controller.text) ?? 0).toString().padLeft(3, '0');
              ConnectionManager.Cooler_Stop_Temp_Night = (int.tryParse(cooler_stop_temp_controller.text) ?? 0).toString().padLeft(3, '0');
              ConnectionManager.Heater_Start_Temp_Night = (int.tryParse(heater_start_temp_controller.text) ?? 0).toString().padLeft(3, '0');
              ConnectionManager.Heater_Stop_Temp_Night = (int.tryParse(heater_stop_temp_controller.text) ?? 0).toString().padLeft(3, '0');

              //Night Time
              await cmg.setRequest(53, Utils.sign_int_100(ConnectionManager.Favourite_Room_Temp_Night), context);
              await cmg.setRequest(54, (ConnectionManager.Room_Temp_Sensitivity_Night), context);
              await cmg.setRequest(55, Utils.sign_int_100(ConnectionManager.Cooler_Start_Temp_Night), context);
              await cmg.setRequest(56, Utils.sign_int_100(ConnectionManager.Cooler_Stop_Temp_Night), context);
              await cmg.setRequest(57, Utils.sign_int_100(ConnectionManager.Heater_Start_Temp_Night), context);
              await cmg.setRequest(58, Utils.sign_int_100(ConnectionManager.Heater_Stop_Temp_Night), context);
            }

            MODIFIED = false;
            if (_tabController!.index == 0) {
              Utils.showSnackBar(context, "Done.");

              return;
            } else if (_tabController!.index == 1) {
              Utils.showSnackBar(context, "Done.");
              return;
            }
          });
    } catch (e) {}
    await refresh();
  }

  bool is_night = false;

  void on_keyboard_button() async {
    await Utils.show_loading_timed(
        context: context,
        done: () async {
          if (_tabController!.index == 0) {
            ConnectionManager.Favourite_Room_Temp_Day_ = (int.tryParse(room_temp_controller.text) ?? 0).toString().padLeft(3, '0');
            double val_f = (double.tryParse(room_temp_sensivity_controller.text) ?? 0.0);
            ConnectionManager.Room_Temp_Sensitivity_Day = max(0, min((val_f), 2)).toString().padLeft(3, '0');
            ConnectionManager.Cooler_Start_Temp_Day = (int.tryParse(cooler_start_temp_controller.text) ?? 0).toString().padLeft(3, '0');
            ConnectionManager.Cooler_Stop_Temp_Day = (int.tryParse(cooler_stop_temp_controller.text) ?? 0).toString().padLeft(3, '0');
            ConnectionManager.Heater_Start_Temp_Day = (int.tryParse(heater_start_temp_controller.text) ?? 0).toString().padLeft(3, '0');
            ConnectionManager.Heater_Stop_Temp_Day = (int.tryParse(heater_stop_temp_controller.text) ?? 0).toString().padLeft(3, '0');

            //Day Time
            await cmg.setRequest(47, Utils.sign_int_100(ConnectionManager.Favourite_Room_Temp_Day_), context);
            await cmg.setRequest(48, (ConnectionManager.Room_Temp_Sensitivity_Day), context);
            await cmg.setRequest(49, Utils.sign_int_100(ConnectionManager.Cooler_Start_Temp_Day), context);
            await cmg.setRequest(50, Utils.sign_int_100(ConnectionManager.Cooler_Stop_Temp_Day), context);
            await cmg.setRequest(51, Utils.sign_int_100(ConnectionManager.Heater_Start_Temp_Day), context);
            await cmg.setRequest(52, Utils.sign_int_100(ConnectionManager.Heater_Stop_Temp_Day), context);
            // if (!is_night_set) {
            //night same as day
            // }
          } else {
            ConnectionManager.Favourite_Room_Temp_Night = (int.tryParse(room_temp_controller.text) ?? 0).toString().padLeft(3, '0');
            double val_f = (double.tryParse(room_temp_sensivity_controller.text) ?? 0.0);
            ConnectionManager.Room_Temp_Sensitivity_Night = max(0, min((val_f), 2)).toString().padLeft(3, '0');
            ConnectionManager.Cooler_Start_Temp_Night = (int.tryParse(cooler_start_temp_controller.text) ?? 0).toString().padLeft(3, '0');
            ConnectionManager.Cooler_Stop_Temp_Night = (int.tryParse(cooler_stop_temp_controller.text) ?? 0).toString().padLeft(3, '0');
            ConnectionManager.Heater_Start_Temp_Night = (int.tryParse(heater_start_temp_controller.text) ?? 0).toString().padLeft(3, '0');
            ConnectionManager.Heater_Stop_Temp_Night = (int.tryParse(heater_stop_temp_controller.text) ?? 0).toString().padLeft(3, '0');

            //Night Time
            await cmg.setRequest(53, Utils.sign_int_100(ConnectionManager.Favourite_Room_Temp_Night), context);
            await cmg.setRequest(54, (ConnectionManager.Room_Temp_Sensitivity_Night), context);
            await cmg.setRequest(55, Utils.sign_int_100(ConnectionManager.Cooler_Start_Temp_Night), context);
            await cmg.setRequest(56, Utils.sign_int_100(ConnectionManager.Cooler_Stop_Temp_Night), context);
            await cmg.setRequest(57, Utils.sign_int_100(ConnectionManager.Heater_Start_Temp_Night), context);
            await cmg.setRequest(58, Utils.sign_int_100(ConnectionManager.Heater_Stop_Temp_Night), context);
          }

          MODIFIED = false;
        });
    await refresh();
  }

  Widget build_boxed_titlebox({required title, required child}) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new InputDecorator(
            decoration: InputDecoration(
                labelText: title, labelStyle: Theme.of(context).textTheme.bodyText1, border: OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow))),
            child: child));
  }

  Widget build_temperature_inf() => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: build_boxed_titlebox(
                title: "Actual Room Temperature",
                child: Center(
                    child: Text((int.tryParse(ConnectionManager.Real_Room_Temp_0) ?? 0).toString() + " °C", style: Theme.of(context).textTheme.bodyText1)),
              ),
            ),
            Expanded(
                child: build_boxed_titlebox(
                    title: "Actual Outdoor Temperature",
                    child: Center(
                        child:
                            Text((int.tryParse(ConnectionManager.Real_Outdoor_Temp) ?? 0).toString() + " °C", style: Theme.of(context).textTheme.bodyText1))))
          ],
        ),
      );

  Widget row_room_temp() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded(child: MyTooltip(message: "example tooltip", child: Text("Desired Temperature:"))),
          Expanded(
            child: TextField(
              textInputAction: TextInputAction.done,
              onSubmitted: (value) {
                on_keyboard_button();
              },
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              keyboardType: TextInputType.numberWithOptions(decimal: false, signed: true),
              maxLength: 4,
              style: Theme.of(context).textTheme.bodyText1,
              controller: room_temp_controller,
              onTap: () => room_temp_controller.selection = TextSelection(baseOffset: 0, extentOffset: room_temp_controller.value.text.length),
              decoration: InputDecoration(suffix: Text(' °C'), counterText: ""),
            ),
          )
        ],
      ),
    );
  }

  Widget row_room_temp_sensivity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded(child: MyTooltip(message: "example tooltip", child: Text("Desired Temp Sensitivity:"))),
          Expanded(
            child: TextField(
              textInputAction: TextInputAction.done,
              onSubmitted: (value) {
                on_keyboard_button();
              },
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"^\d+\.?\d{0,1}"))],
              keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
              maxLength: 4,
              style: Theme.of(context).textTheme.bodyText1,
              controller: room_temp_sensivity_controller,
              onTap: () =>
                  room_temp_sensivity_controller.selection = TextSelection(baseOffset: 0, extentOffset: room_temp_sensivity_controller.value.text.length),
              decoration: InputDecoration(suffix: Text(' °C'), counterText: ""),
            ),
          )
        ],
      ),
    );
  }

  Widget row_cooler_start_temp() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: MyTooltip(message: "example tooltip", child: Text("Cooler Start Temp: "))),
            Expanded(
              child: TextField(
                textInputAction: TextInputAction.done,
                onSubmitted: (value) {
                  on_keyboard_button();
                },
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.numberWithOptions(decimal: false, signed: true),
                maxLength: 4,
                style: Theme.of(context).textTheme.bodyText1,
                controller: cooler_start_temp_controller,
                onTap: () =>
                    cooler_start_temp_controller.selection = TextSelection(baseOffset: 0, extentOffset: cooler_start_temp_controller.value.text.length),
                decoration: InputDecoration(suffix: Text(' °C'), counterText: ""),
              ),
            )
          ],
        ),
      );
  Widget row_cooler_stop_temp() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: MyTooltip(message: "example tooltip", child: Text("Cooler Stop Temp: "))),
            Expanded(
              child: TextField(
                textInputAction: TextInputAction.done,
                onSubmitted: (value) {
                  on_keyboard_button();
                },
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.numberWithOptions(decimal: false, signed: true),
                maxLength: 4,
                style: Theme.of(context).textTheme.bodyText1,
                controller: cooler_stop_temp_controller,
                onTap: () => cooler_stop_temp_controller.selection = TextSelection(baseOffset: 0, extentOffset: cooler_stop_temp_controller.value.text.length),
                decoration: InputDecoration(suffix: Text(' °C'), counterText: ""),
              ),
            )
          ],
        ),
      );
  Widget row_heater_start_temp() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: MyTooltip(message: "example tooltip", child: Text("Heater Start Temp: "))),
            Expanded(
              child: TextField(
                textInputAction: TextInputAction.done,
                onSubmitted: (value) {
                  on_keyboard_button();
                },
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.numberWithOptions(decimal: false, signed: true),
                maxLength: 4,
                style: Theme.of(context).textTheme.bodyText1,
                controller: heater_start_temp_controller,
                onTap: () =>
                    heater_start_temp_controller.selection = TextSelection(baseOffset: 0, extentOffset: heater_start_temp_controller.value.text.length),
                decoration: InputDecoration(suffix: Text(' °C'), counterText: ""),
              ),
            )
          ],
        ),
      );
  Widget row_heater_stop_temp() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(child: MyTooltip(message: "example tooltip", child: Text("Heater Stop Temp: "))),
            Expanded(
              child: TextField(
                textInputAction: TextInputAction.done,
                onSubmitted: (value) {
                  on_keyboard_button();
                },
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.numberWithOptions(decimal: false, signed: true),
                maxLength: 4,
                style: Theme.of(context).textTheme.bodyText1,
                controller: heater_stop_temp_controller,
                onTap: () => heater_stop_temp_controller.selection = TextSelection(baseOffset: 0, extentOffset: heater_stop_temp_controller.value.text.length),
                decoration: InputDecoration(suffix: Text(' °C'), counterText: ""),
              ),
            )
          ],
        ),
      );
  Widget temperature_fragment() {
    return SingleChildScrollView(
      child: Column(
        children: [
          row_room_temp(),
          row_room_temp_sensivity(),
          row_cooler_start_temp(),
          row_cooler_stop_temp(),
          row_heater_start_temp(),
          row_heater_stop_temp(),
        ],
      ),
    );
  }

  build_apply_button(click) => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 15),
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: OutlinedButton(
            onPressed: MODIFIED ? click : null,
            style: OutlinedButton.styleFrom(
                padding: EdgeInsets.only(top: 16, bottom: 10, left: 28, right: 28),
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
            onPressed: () async {
              AwesomeDialog(
                context: context,
                useRootNavigator: true,
                dialogType: DialogType.WARNING,
                animType: AnimType.BOTTOMSLIDE,
                title: "Confirm",
                desc: "Current Page Settings will be restored to factory defaults",
                btnOkOnPress: () async {
                  await cmg.setRequest(128, '3');
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
  List<Widget> make_title(titile) {
    return [
      Container(
        padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
        alignment: Alignment.centerLeft,
        child: Text(titile, style: Theme.of(context).textTheme.bodyText1),
      ),
      Divider(
        color: Theme.of(context).accentColor,
      )
    ];
  }

  final List<Tab> tabs = <Tab>[
    new Tab(
      text: "Day",
    ),
    new Tab(
      text: "Night",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(children: [
        Container(
          color: Colors.black12,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              Text("Temperature", style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 24)),
              Align(
                alignment: Alignment.centerRight,
                child: TabBar(
                  isScrollable: false,
                  unselectedLabelColor: Colors.grey,
                  labelColor: Colors.white,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: new BubbleTabIndicator(
                    indicatorHeight: 25.0,
                    indicatorColor: Colors.blueAccent,
                    tabBarIndicatorSize: TabBarIndicatorSize.tab,
                  ),
                  labelStyle: Theme.of(context).textTheme.bodyText1,
                  tabs: tabs,
                  controller: _tabController,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        build_temperature_inf(),
        Expanded(
            child: new TabBarView(
          controller: _tabController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            temperature_fragment(),
            temperature_fragment(),
          ],
        )),
        build_apply_button(() async {
          if (set_inprogress) return;
          set_inprogress = true;
          await apply_temp();
          set_inprogress = false;
        }),
        build_reset_button(),
      ]),
    );
  }
}
