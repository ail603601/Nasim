import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nasim/utils.dart';

class LicenseChangeNotifier extends ChangeNotifier {
  static bool power_box = false;
  static bool room_temp = false;
  var dserial = "";
  bool is_both_licensed() => power_box && room_temp;

  void license_power_box() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(dserial + 'power_box', true);
    power_box = true;
    notifyListeners();
  }

  void license_room_temp() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(dserial + 'room_temp', true);
    room_temp = true;
    notifyListeners();
  }

  LicenseChangeNotifier(dserial) {
    this.dserial = dserial;
    init();
  }

  init() async {
    final prefs = await SharedPreferences.getInstance();
    power_box = prefs.getBool(dserial + 'power_box') ?? false;
    room_temp = prefs.getBool(dserial + 'room_temp') ?? false;
    notifyListeners();
  }
}
