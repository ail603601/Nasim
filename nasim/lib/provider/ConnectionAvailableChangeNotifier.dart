import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ConnectionAvailableChangeNotifier extends ChangeNotifier {
  static bool _CONNECTION_OFFLINE = false;
  static ConnectionAvailableChangeNotifier? instance;

  void re_notify() {
    try {
      notifyListeners();
    } catch (e) {
      instance = null;
    }
  }

  bool is_offline() {
    return _CONNECTION_OFFLINE;
  }

  static void updated(bool newval) {
    // if (_CONNECTION_OFFLINE != newval) {
    //   _CONNECTION_OFFLINE = newval;
    //   instance?.re_notify();
    // }
  }
}
