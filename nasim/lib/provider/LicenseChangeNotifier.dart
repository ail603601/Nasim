import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nasim/utils.dart';

class LicenseChangeNotifier extends ChangeNotifier {
  bool power_box = false;
  bool room_temp_0 = false;
  bool room_temp_1 = false;
  bool room_temp_2 = false;
  bool room_temp_3 = false;
  bool room_temp_4 = false;
  bool room_temp_5 = false;
  bool room_temp_6 = false;
  bool room_temp_7 = false;
  bool room_temp_8 = false;
  bool room_temp_9 = false;
  bool six_mobiles = false;
  bool outdoor_temp = false;
  bool gsm_modem = false;

  var dserial = "";
  bool is_both_licensed() => power_box && room_temp_0;

  void license_power_box() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(dserial + 'power_box', true);
    power_box = true;
    notifyListeners();
  }

  license_room_temp(int n) async {
    switch (n) {
      case 0:
        room_temp_0 = true;
        break;
      case 1:
        room_temp_1 = true;
        break;
      case 2:
        room_temp_2 = true;
        break;
      case 3:
        room_temp_3 = true;
        break;
      case 4:
        room_temp_4 = true;
        break;
      case 5:
        room_temp_5 = true;
        break;
      case 6:
        room_temp_6 = true;
        break;
      case 7:
        room_temp_7 = true;
        break;
      case 8:
        room_temp_8 = true;
        break;
      case 9:
        room_temp_9 = true;
        break;
    }
    final prefs = await SharedPreferences.getInstance();

    prefs.setBool(dserial + 'room_temp_$n', true);
    notifyListeners();
  }

  license_6_mobiles() async {
    six_mobiles = true;

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(dserial + 'six_mobiles', true);
    notifyListeners();
  }

  license_outdoor_temp() async {
    outdoor_temp = true;

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(dserial + 'outdoor_temp', true);
    notifyListeners();
  }

  license_gsm_modem() async {
    gsm_modem = true;

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(dserial + 'gsm_modem', true);
    notifyListeners();
  }

  LicenseChangeNotifier(dserial) {
    this.dserial = dserial;
    init();
  }

  init() async {
    final prefs = await SharedPreferences.getInstance();
    // power_box = prefs.getBool(dserial + 'power_box') ?? false;
    // room_temp_0 = prefs.getBool(dserial + 'room_temp_0') ?? false;
    // room_temp_1 = prefs.getBool(dserial + 'room_temp_1') ?? false;
    // room_temp_2 = prefs.getBool(dserial + 'room_temp_2') ?? false;
    // room_temp_3 = prefs.getBool(dserial + 'room_temp_3') ?? false;
    // room_temp_4 = prefs.getBool(dserial + 'room_temp_4') ?? false;
    // room_temp_5 = prefs.getBool(dserial + 'room_temp_5') ?? false;
    // room_temp_6 = prefs.getBool(dserial + 'room_temp_6') ?? false;
    // room_temp_7 = prefs.getBool(dserial + 'room_temp_7') ?? false;
    // room_temp_8 = prefs.getBool(dserial + 'room_temp_8') ?? false;
    // room_temp_9 = prefs.getBool(dserial + 'room_temp_9') ?? false;
    // six_mobiles = prefs.getBool(dserial + 'six_mobiles') ?? false;
    // outdoor_temp = prefs.getBool(dserial + 'outdoor_temp') ?? false;
    // gsm_modem = prefs.getBool(dserial + 'gsm_modem') ?? false;
    notifyListeners();
  }
}
