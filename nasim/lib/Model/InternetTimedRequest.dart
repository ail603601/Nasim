import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nasim/Model/Device.dart';
import 'package:nasim/provider/ConnectionAvailableChangeNotifier.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:core';

import 'package:nasim/provider/ConnectionManager.dart';
import 'package:nasim/utils.dart';

class InternetTimedRequest {
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
  late int request_type;
  late String request;
  late String serial;

  static const int timeouts_max = 3;
  int timeouts = 0;
  String form_main_data() {
    return id + "/" + request;
  }

  InternetTimedRequest(this.id, this.request_type, this.request, this.serial);

  Future<String> start() {
    ConnectionManager.internet_http_request(request_type, form_main_data(), serial);

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
            printWarning("Internet retrying for request $request type $request_type count: $timeouts");
            start();
            return;
          }
          ended = true;
          printWarning("Internet failure request {$request} type $request_type reason : $result");

          completer.completeError(result);
          ConnectionManager.internetRequests.remove(id);
          if (request_type != 5) ConnectionAvailableChangeNotifier.updated(true);

          return;
        }
        ended = true;
        printSuccess("Internet Request: $request Received: " + result);
        completer.complete(result);
        ConnectionManager.internetRequests.remove(id);
        if (request_type != 5) ConnectionAvailableChangeNotifier.updated(false);
      } catch (e) {
        printError("Internet failure request {$request} type $request_type reason : $e");
        completer.completeError("Internet failure request {$request} type $request_type reason : $e");
        ;
      }
    }
  }
}
