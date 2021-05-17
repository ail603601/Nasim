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

  TimedRequest(this.id);
  timedout() {
    complete("timeout");
  }

  start() {
    Utils.setTimeOut(4000, timedout);
    return completer.future;
  }

  bool ended = false;
  complete(result) {
    if (!ended) {
      ended = true;
      completer.complete(result);
      ConnectionManager.requests.remove(id);
    }
  }
}
