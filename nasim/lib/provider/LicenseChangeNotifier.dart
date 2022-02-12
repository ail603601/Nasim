import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nasim/utils.dart';

import '../enums.dart';
import 'ConnectionManager.dart';
import 'SavedevicesChangeNofiter.dart';

class LicenseChangeNotifier extends ChangeNotifier {
  late Completer<bool> loading_finished;

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
  bool outdoor_temp = false;
  bool six_mobiles = false;

  bool gsm_modem = false;

  var dserial = "";
  bool is_both_licensed() => power_box && room_temp_0;

  bool is_locall_conntection(context) {
    if (SavedDevicesChangeNotifier.getSelectedDevice()!.accessibility == DeviceAccessibility.AccessibleInternet) {
      Utils.setTimeOut(
          0,
          () => Utils.show_error_dialog(context, "Not Available", "users can't set licenses via internt.", () {}).then((value) {
                // Navigator.pop(context);
              }));
      return false;
    }

    return true;
  }

  void license_power_box(context) async {
    if (is_locall_conntection(context)) {
      power_box = true;
      notifyListeners();
    }
  }

  license_room_temp(int n, context) async {
    if (is_locall_conntection(context)) {
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
      }

      notifyListeners();
    }
  }

  license_6_mobiles(context) async {
    if (is_locall_conntection(context)) {
      six_mobiles = true;

      notifyListeners();
    }
  }

  license_outdoor_temp(context) async {
    if (is_locall_conntection(context)) {
      outdoor_temp = true;

      notifyListeners();
    }
  }

  license_gsm_modem(context) async {
    if (is_locall_conntection(context)) {
      gsm_modem = true;

      notifyListeners();
    }
  }

  LicenseChangeNotifier(context) {
    // init(context);
    loading_finished = new Completer<bool>();
    init(context);
  }

  init(context) async {
    ConnectionManager cmd = Provider.of<ConnectionManager>(context, listen: false);

    String _power_box = await cmd.getRequest(4, context);
    String _room_temp_0 = await cmd.getRequest(6, context);
    String _room_temp_1 = await cmd.getRequest(7, context);
    String _room_temp_2 = await cmd.getRequest(8, context);
    String _room_temp_3 = await cmd.getRequest(9, context);
    String _room_temp_4 = await cmd.getRequest(10, context);
    String _room_temp_5 = await cmd.getRequest(11, context);
    String _room_temp_6 = await cmd.getRequest(12, context);
    String _room_temp_7 = await cmd.getRequest(13, context);
    String _room_temp_8 = await cmd.getRequest(14, context);
    String _outdoor_temp = await cmd.getRequest(15, context);
    String _six_mobiles = await cmd.getRequest(138, context);
    String _gsm_modem = await cmd.getRequest(5, context);
    power_box = _power_box != "";
    room_temp_0 = _room_temp_0 != "";
    room_temp_1 = _room_temp_1 != "";
    room_temp_2 = _room_temp_2 != "";
    room_temp_3 = _room_temp_3 != "";
    room_temp_4 = _room_temp_4 != "";
    room_temp_5 = _room_temp_5 != "";
    room_temp_6 = _room_temp_6 != "";
    room_temp_7 = _room_temp_7 != "";
    room_temp_8 = _room_temp_8 != "";
    outdoor_temp = _outdoor_temp != "";
    six_mobiles = _six_mobiles != "";
    gsm_modem = _gsm_modem != "";
    loading_finished.complete(true);
    notifyListeners();
  }
}
