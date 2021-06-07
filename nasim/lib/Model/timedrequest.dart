import 'dart:async';

import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:core';

import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/utils.dart';

class TimedRequest {
  Completer<String> completer = new Completer<String>();
  late String id;
  late String resquest_str;
  String? ip = null;

  static const int timeouts_max = 15;
  int timeouts = 0;

  TimedRequest(this.id, this.resquest_str, this.ip);

  start() {
    new Future.delayed(const Duration(milliseconds: 500), () {
      complete("timeout");
    });

    return completer.future;
  }

  bool ended = false;
  complete(result) {
    if (!ended) {
      if (result == "timeout") {
        timeouts++;
        if (timeouts < timeouts_max) {
          ConnectionManager.execute(id: id, request_data: resquest_str, ip: ip);
          start();
        }

        return;
      }
      ended = true;
      completer.complete(result);
      ConnectionManager.requests.remove(id);
    }
  }
}
