import 'package:flutter/foundation.dart';

import '../enums.dart';

class Device {
  String name;
  String ip;
  String serial;
  ConnectionStatus connectionState;

  Device({this.name = "unknown", this.serial = "0000000000", this.ip = "0.0.0.0", this.connectionState = ConnectionStatus.disconnected}) {}
  @override
  bool operator ==(Object other) {
    return other is Device && this.serial == other.serial;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => serial.hashCode;
}
