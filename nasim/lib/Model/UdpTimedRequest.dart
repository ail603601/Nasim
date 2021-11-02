import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nasim/provider/ConnectionAvailableChangeNotifier.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:core';

import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/utils.dart';

class UdpTimedRequest {
  Completer<String> completer = new Completer<String>();
  late String id;
  late String request;
  late String ip;

  static const int timeouts_max = 2;
  int timeouts = 0;
  String form_main_data() {
    return id + "/" + request;
  }

  UdpTimedRequest(this.id, this.request, this.ip);

  start() {
    ConnectionManager.udp_send_text(request, ip);
    new Future.delayed(const Duration(milliseconds: 2000), () {
      complete("timeout");
    });

    return completer.future;
  }

  bool ended = false;
  complete(result) {
    if (!ended) {
      try {
        if (result == "timeout") {
          timeouts++;
          if (timeouts < timeouts_max) {
            start();
            return;
          }
          ended = true;
          completer.completeError(result);
          ConnectionManager.udpRequests.remove(id);

          return;
        }
        ended = true;
        completer.complete(result);
        ConnectionManager.udpRequests.remove(id);
      } catch (e) {
        print("Note: udp throwed exception UdpTimedRequest");
        completer.completeError("failure executing request.");
      }
    }
  }
}
