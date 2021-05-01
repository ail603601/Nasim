import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DeviceListFabChangeNotifier extends ChangeNotifier {
  bool current_status = false;

  void clicked() {
    current_status = !current_status;
    notifyListeners();
  }
}
