import 'package:flutter/foundation.dart';

import '../enums.dart';

/*
a device has:
name
ip which must be found each time we search for device to see if its there
serial number unique
no ping, we dont care
when we connect to a device, we have a user name
--

*/
class Device {
  String name;
  String ip;
  String serial;
  String username;
  DeviceAccessibility accessibility;

  int _discoverTimeOutTimer = 2;

  Device({
    this.name = "unknown",
    this.ip = "0.0.0.0",
    this.serial = "0000000000",
    this.accessibility = DeviceAccessibility.InAccessible,
    this.username = "",
  }) {}
  @override
  bool operator ==(Object other) {
    return other is Device && this.serial == other.serial;
  }

  @override
  int get hashCode => serial.hashCode;

  bool has_valid_ip() {
    return (!ip.isEmpty && ip != "0.0.0.0");
  }

  void discovered() {
    _discoverTimeOutTimer = 2;
  }

  bool un_discovered() {
    _discoverTimeOutTimer--;
    return _discoverTimeOutTimer <= 0;
  }
}
