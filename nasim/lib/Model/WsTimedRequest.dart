import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nasim/provider/ConnectionAvailableChangeNotifier.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:core';

import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/utils.dart';

class WsTimedRequest {
  void printSuccess(String text) {
    print('\x1B[32m$text\x1B[0m');
  }

  void printWarning(String text) {
    print('\x1B[33m$text\x1B[0m');
  }

  void printError(String text) {
    print('\x1B[31m$text\x1B[0m');
  }

  Completer<String> completer = new Completer<String>();
  late String id;
  late String request;

  static const int timeouts_max = 3;
  int timeouts = 0;

  WsTimedRequest(this.id, this.request);

  String form_main_data() {
    return id + "/" + request;
  }

  start() {
    ConnectionManager.ws_send_text(form_main_data());

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
            printWarning("WS retrying for request $request count: $timeouts");
            start();
            return;
          }
          ended = true;
          ConnectionAvailableChangeNotifier.updated(true);
          printWarning("WS failure request {$request} reason : $result");
          completer.completeError(result);
          ConnectionManager.wsRequests.remove(id);

          return;
        }
        ended = true;
        ConnectionAvailableChangeNotifier.updated(false);
        printSuccess("WS Request: $request Received: " + result);
        completer.complete(result);
        ConnectionManager.wsRequests.remove(id);
      } catch (e) {
        printError("WS failure request {$request} reason : $e");
        completer.completeError(result);
      }
    }
  }
}
