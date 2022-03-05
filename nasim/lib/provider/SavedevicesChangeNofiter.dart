import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:nasim/Model/Device.dart';
import 'package:nasim/enums.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nasim/utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SavedDevicesChangeNotifier extends ChangeNotifier {
  // List<Device> saved_devices = [Device(name: "Nasim N4", ip: "192.168.1.110")];
  List<Device> saved_devices = [];

  SavedDevicesChangeNotifier() {
    init();
  }
  init() async {
    saved_devices = [];
    final prefs = await SharedPreferences.getInstance();
    int list_count = prefs.getInt('saved_Devices_count') ?? 0;

    for (var i = 0; i < list_count; i++) {
      if ((prefs.getString('Device${i}name') ?? "") == "") {
        continue;
      }
      saved_devices.add(Device(
          name: prefs.getString('Device${i}name') ?? "",
          serial: prefs.getString('Device${i}serial') ?? "",
          // ip: prefs.getString('Device${i}ip') ?? "0.0.0.0",
          username: prefs.getString('Device${i}username') ?? ""));
    }
    notifyListeners();
  }

  addDevice(Device d) async {
    if (saved_devices.contains(d)) {
      return;
    }
    int i = saved_devices.length;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('Device${i}name', d.name);
    prefs.setString('Device${i}serial', d.serial);
    // prefs.setString('Device${i}ip', d.ip);
    prefs.setString('Device${i}username', d.username);

    saved_devices.add(d);
    prefs.setInt('saved_Devices_count', saved_devices.length);
    prefs.commit();

    notifyListeners();
    // subscribe to  device serian nubmer topic
    FirebaseMessaging.instance.subscribeToTopic(d.serial);
  }

  removeDevice(Device d) async {
    int index = saved_devices.indexOf(d);
    if (d == _selected_device) {
      _selected_device = null;
    }
    d.name = "";
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('Device${index}name', "");
    prefs.setString('Device${index}serial', "");
    // prefs.setString('Device${index}ip', "");
    prefs.setString('Device${index}username', "");
    saved_devices.remove(d);
    prefs.commit();

    notifyListeners();
    FirebaseMessaging.instance.unsubscribeFromTopic(d.serial);
  }

  static Device? _selected_device;
  setSelectedDevice(Device d) {
    int index = saved_devices.indexOf(d);
    if (index != -1 && _selected_device != null) {
      //updating device, we dont remove user name, only change ip,name,accs
      _selected_device!.ip = d.ip;
      _selected_device!.accessibility = d.accessibility;
      _selected_device!.name = d.name;
    } else if ((_selected_device != null && _selected_device == d)) {
      //updating device, we dont remove user name, only change ip,name,accs

      _selected_device!.ip = d.ip;
      _selected_device!.accessibility = d.accessibility;
      _selected_device!.name = d.name;
    } else {
      _selected_device = d;
    }
    // subscribe to  device serian nubmer topic
    FirebaseMessaging.instance.subscribeToTopic(d.serial);
  }

  static Device? getSelectedDevice() {
    return _selected_device;
  }

  Future<void> updateSelectedDeviceName(String new_name) async {
    _selected_device?.name = new_name;

    int index = saved_devices.indexOf(_selected_device!);
    if (index != -1) {
      saved_devices[index].name = new_name;
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('Device${index}name', _selected_device!.name);
      prefs.commit();
    }

    notifyListeners();
  }

  Future<void> updateSelectedDeviceUserName(String name) async {
    int index = saved_devices.indexOf(_selected_device!);
    if (index == -1) {
      return;
    }

    saved_devices[index].username = name;
    _selected_device!.username = name;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('Device${index}name', _selected_device!.name);
    prefs.setString('Device${index}serial', _selected_device!.serial);
    // prefs.setString('Device${index}ip', selected_device!.ip);
    prefs.setString('Device${index}username', _selected_device!.username);
    prefs.commit();

    notifyListeners();
  }
}
