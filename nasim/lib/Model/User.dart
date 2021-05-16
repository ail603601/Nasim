import 'package:flutter/foundation.dart';

import '../enums.dart';

class User {
  String name;
  String mac;
  ConnectionStatus connectionState;
  bool access;
  int id_table;

  User({this.name = "unknown", this.mac = "", this.connectionState = ConnectionStatus.disconnected, this.access = false, required this.id_table}) {}
}
