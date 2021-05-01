import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nasim/enums.dart';
import 'package:flutter/foundation.dart';

class MenuInfo extends ChangeNotifier {
  MenuType menuType;
  String title;
  IconData imageSource;

  MenuInfo(this.menuType, {this.title = "undefined", this.imageSource = Icons.format_underlined_sharp});

  updateMenu(MenuInfo menuInfo) {
    this.menuType = menuInfo.menuType;
    this.title = menuInfo.title;
    this.imageSource = menuInfo.imageSource;

//Important
    notifyListeners();
  }
}
