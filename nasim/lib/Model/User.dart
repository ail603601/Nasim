import 'package:flutter/foundation.dart';

import '../enums.dart';

class User {
  String name;
  String mac;
  ConnectionStatus connectionState;
  bool access;

  User({this.name = "unknown", this.mac = "0.0.0.0", this.connectionState = ConnectionStatus.disconnected, this.access = false}) {}
}
