import 'package:flutter/foundation.dart';

import '../enums.dart';

class User {
  String name;
  String mac;
  // ConnectionStatus connectionState;
  bool access;
  int id_table;
  bool is_self = false;

  User({this.name = "unknown", this.mac = "", this.access = false, required this.id_table}) {}
}
