import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nasim/utils.dart';

class FirstTimeUsageChangeNotifier extends ChangeNotifier {
  Future<bool> isFirstTime() async {
    return false;
    final prefs = await SharedPreferences.getInstance();
    // await Utils.waitMsec(1500);
// Try reading data from the counter key. If it doesn't exist, return true.
    return prefs.getBool('fisrt_time_usage') ?? true;
  }

  void firstTimeEnded() async {
// obtain shared preferences
    final prefs = await SharedPreferences.getInstance();

// set value
    prefs.setBool('fisrt_time_usage', false);

    notifyListeners();
  }
}
