import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:nasim/Model/Device.dart';
import 'package:nasim/enums.dart';
import 'package:nasim/provider/ConnectionManager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nasim/utils.dart';

class SavedDevicesChangeNotifier extends ChangeNotifier {
  // List<Device> saved_devices = [Device(name: "Nasim N4", ip: "192.168.1.110")];
  List<Device> saved_devices = [];

  SavedDevicesChangeNotifier() {
    init();
  }
  init() async {
    final prefs = await SharedPreferences.getInstance();
    int list_count = prefs.getInt('saved_Devices_count') ?? 0;
    for (var i = 0; i < list_count; i++) {
      saved_devices.add(Device(
          name: prefs.getString('Device${i}name') ?? "",
          serial: prefs.getString('Device${i}serial') ?? "",
          ip: prefs.getString('Device${i}ip') ?? "0.0.0.0",
          username: prefs.getString('Device${i}username') ?? "",
          connectionState: ConnectionStatus.connected_close));
    }
    notifyListeners();
  }

  addDevice(Device d) async {
    int i = saved_devices.length;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('Device${i}name', d.name);
    prefs.setString('Device${i}serial', d.serial);
    prefs.setString('Device${i}ip', d.ip);
    prefs.setString('Device${i}username', d.username);

    saved_devices.add(d);
    prefs.setInt('saved_Devices_count', saved_devices.length);
    notifyListeners();
  }

  static Device? selected_device;
  setSelectedDevice(Device d) {
    selected_device = d;
  }

  updateSelecteduser_name(name) async {
    int index = saved_devices.indexOf(selected_device!);
    saved_devices[index].username = name;
    selected_device!.username = name;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('Device${index}name', selected_device!.name);
    prefs.setString('Device${index}serial', selected_device!.serial);
    prefs.setString('Device${index}ip', selected_device!.ip);
    prefs.setString('Device${index}username', selected_device!.username);

    notifyListeners();
  }
}
