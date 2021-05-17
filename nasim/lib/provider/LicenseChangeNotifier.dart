import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nasim/utils.dart';

import 'ConnectionManager.dart';

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
    // final prefs = await SharedPreferences.getInstance();
    // prefs.setBool(dserial + 'power_box', true);
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
    // final prefs = await SharedPreferences.getInstance();
    // prefs.setBool(dserial + 'room_temp_$n', true);
    notifyListeners();
  }

  license_6_mobiles() async {
    six_mobiles = true;

    // final prefs = await SharedPreferences.getInstance();
    // prefs.setBool(dserial + 'six_mobiles', true);
    notifyListeners();
  }

  license_outdoor_temp() async {
    outdoor_temp = true;

    // final prefs = await SharedPreferences.getInstance();
    // prefs.setBool(dserial + 'outdoor_temp', true);
    notifyListeners();
  }

  license_gsm_modem() async {
    gsm_modem = true;

    // final prefs = await SharedPreferences.getInstance();
    // prefs.setBool(dserial + 'gsm_modem', true);
    notifyListeners();
  }

  LicenseChangeNotifier(context) {
    init(context);
  }

  Future<String> get_safe(cmd, context, defaul) async {
    String rec = await Provider.of<ConnectionManager>(context, listen: false).getRequest(cmd);
    if (rec == "timeout") {
      rec = defaul;
    }
    notifyListeners();

    return rec;
  }

  init(context) async {
    // final prefs = await SharedPreferences.getInstance();
    power_box = await get_safe("get4", context, "0000000000") != "0000000000";
    room_temp_0 = await get_safe("get6", context, "0000000000") != "0000000000";
    room_temp_1 = await get_safe("get7", context, "0000000000") != "0000000000";
    room_temp_2 = await get_safe("get8", context, "0000000000") != "0000000000";
    room_temp_3 = await get_safe("get9", context, "0000000000") != "0000000000";
    room_temp_4 = await get_safe("get10", context, "0000000000") != "0000000000";
    room_temp_5 = await get_safe("get11", context, "0000000000") != "0000000000";
    room_temp_6 = await get_safe("get12", context, "0000000000") != "0000000000";
    room_temp_7 = await get_safe("get13", context, "0000000000") != "0000000000";
    room_temp_8 = await get_safe("get14", context, "0000000000") != "0000000000";
    room_temp_9 = await get_safe("get15", context, "0000000000") != "0000000000";
    // six_mobiles = await Provider.of<ConnectionManager>(context, listen: false).getRequest("get16", context) != "0000000000";
    // outdoor_temp = axwait Provider.of<ConnectionManager>(context, listen: false).getRequest("get16", context) != "0000000000";
    gsm_modem = await get_safe("get5", context, "0000000000") != "0000000000";
    notifyListeners();
  }
}
