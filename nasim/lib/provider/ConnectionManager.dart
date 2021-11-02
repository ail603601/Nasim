import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:nasim/Model/Device.dart';
import 'package:nasim/Model/InternetTimedRequest.dart';
import 'package:nasim/Model/UdpTimedRequest.dart';
import 'package:nasim/Model/WsTimedRequest.dart';
import 'package:nasim/provider/SavedevicesChangeNofiter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../enums.dart';
import '../utils.dart';

class ConnectionManager extends ChangeNotifier {
  List<Device> found_devices = [];
  static RawDatagramSocket? udpSocket;
  static final Map<String, UdpTimedRequest> udpRequests = {};
  static final Map<String, WsTimedRequest> wsRequests = {};
  static final Map<String, InternetTimedRequest> internetRequests = {};

  static var uuid = Uuid();

  static WebSocketChannel? wsChannel;

  var last_sender_host = "0.0.0.0";

  re_listen(u_socket) {}

  udpCreateSocket() {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 9315).then(
      (RawDatagramSocket _udpSocket) {
        udpSocket = _udpSocket;
        udpSocket!.broadcastEnabled = true;
        udpSocket!.listen(
            (e) {
              // if (udpSocket == null) return; //socket is null nothing to listen
              Datagram? dg = udpSocket!.receive();
              if (dg != null) {
                last_sender_host = dg.address.host;
                String stringReceived = AsciiCodec().decode(dg.data);
                if (stringReceived[stringReceived.length - 1] == '\n') {
                  stringReceived = stringReceived.substring(0, stringReceived.length - 1);
                }
                //subtract id
                var str_splited = stringReceived.split('*');
                if (str_splited.length == 2) {
                  String id = str_splited[0];
                  stringReceived = str_splited[1];

<<<<<<< HEAD
                  if (stringReceived.contains("_INFO")) {
                    // answer of discover packet
                    //custom handle for discoveer requests because it will be answered by multiple devices
                    var arr = stringReceived.split(',');

                    const String discover_symbol = "_INFO";
                    if (arr.length == 2 && arr[0] == discover_symbol) {
                      Device device = Device(name: "loading...", serial: arr[1], ip: last_sender_host, accessibility: DeviceAccessibility.AccessibleLocal);
                      wsConnect(last_sender_host);
                      ws_send_request("get000").then((value) {
                        value = removeSpecialChars(value);
                        if (["", null, false, 0].contains(value)) {
                          device.name = "New Air Conditioner (un named)";
                        } else {
                          device.name = value;
                        }
                        discover_stream_controller.sink.add(device);
                        if (!found_devices.contains(device)) {
                          found_devices.add(device);
                        } else {
                          //we know that we had a device with  same  serial number,
                          //but we make other things the same just for safety
                          found_devices[found_devices.indexOf(device)].ip = device.ip;
                          found_devices[found_devices.indexOf(device)].name = device.name;
                        }
                      });
                    }
                  }
                  udpRequests[id]?.complete(stringReceived);
                }
                if (!stringReceived.contains("_DISCOVER")) print("udp received " + stringReceived + "from: " + dg.address.host);
              }
            },
            cancelOnError: false,
            onError: (dg) {
              print("received error: $dg"); //dg.address.host
              found_devices = [];
              udpSocket!.close();
              udpSocket = null;
              Utils.setTimeOut(1000, udpCreateSocket);
            });
=======
        udpSocket!.listen((e) {
          Datagram? dg = udpSocket?.receive();
          if (dg != null) {
            last_sender_host = dg.address.host;
            String string_received = AsciiCodec().decode(dg.data);
            if (string_received[string_received.length - 1] == '\n') {
              string_received = string_received.substring(0, string_received.length - 1);
            }
            //subtract id
            var str_splited = string_received.split('*');
            if (str_splited.length == 2) {
              String id = str_splited[0];
              string_received = str_splited[1];
              requests[id]?.complete(string_received);
            }

            print("received ${string_received}"); //dg.address.host

          }
        }, onError: (dg) {
          print("received error: ${dg}"); //dg.address.host
          found_devices = [];
          udpSocket = null;

          // CreateSocket();
        });
>>>>>>> 6a1544a0c624afc7d005fd05dd7b3c319ded1c17
      },
    ).onError((error, stackTrace) {
      found_devices = [];

      Utils.setTimeOut(1000, udpCreateSocket);
    });
  }

  void wsConnect(String device_ip) {
    if (wsChannel != null) wsChannel!.sink.close();

    wsChannel = WebSocketChannel.connect(
      Uri.parse('ws://' + device_ip + ':7072'),
    );
    wsChannel!.stream.listen((stringReceived) {
      if (stringReceived[stringReceived.length - 1] == '\n') {
        stringReceived = stringReceived.substring(0, stringReceived.length - 1);
      }
      //subtract id
      var str_splited = stringReceived.split('*');
      if (str_splited.length == 2) {
        String id = str_splited[0];
        stringReceived = str_splited[1];
        wsRequests[id]?.complete(stringReceived);
      }
    });
  }

  Future<String> ws_send_request(String request) {
    final requestId = uuid.v1();

    wsRequests[requestId] = new WsTimedRequest(requestId, request);

    return wsRequests[requestId]!.start();
  }

  static void ws_send_text(String text) {
    if (wsChannel != null)
      wsChannel!.sink.add(text);
    else
      throw Exception("not connected");
  }

  ConnectionManager() {
    udpCreateSocket();
  }
  // Initializing a stream controller
  // ignore: close_sinks
  StreamController<Device> discover_stream_controller = StreamController<Device>.broadcast();

  Future<String> findDeviceIp(String serial) async {
    Completer<String> completer = new Completer<String>();

    sendDiscoverSignal(false);

    // Setting up a subscriber to listen for any events sent on the stream
    StreamSubscription<Device> subscriber = discover_stream_controller.stream.listen((Device data) {
      if (data.serial == serial) {
        completer.complete(data.ip);
      }
    });

    new Future.delayed(const Duration(milliseconds: 1000), () {
      if (!completer.isCompleted) {
        completer.completeError("device ip for serial " + serial + " was not found! timed out");
        subscriber.cancel();
      }
    });

    String ip = await completer.future;
    subscriber.cancel();
    return ip;
  }

  //sends discover packet, many devices may respond to this, handle is in socket creation
  void sendDiscoverSignal(bool flush_prev_list) {
    if (flush_prev_list) found_devices = [];

    if (udpSocket == null) {
      // createSocket();
      return;
    }
    BroadCast('_DISCOVER');
  }

  Future<String> BroadCast(String request) {
    return udp_request(request, "255.255.255.255");
  }

  Future<void> CheckConnectivityToDevice(Device d) async {
    if (d.accessibility == DeviceAccessibility.InAccessible) {
      //try to make local connection, if fail, try remote
      // bool wifi_available = await Connectivity().checkConnectivity() == ConnectivityResult.wifi;
      // if (wifi_available) {
      try {
        d.ip = await findDeviceIp(d.serial);
        wsConnect(d.ip);
        d.accessibility = DeviceAccessibility.AccessibleLocal;
        return;
      } catch (e) {
        print("Device was not found locally");
        String response = await internet_request("", d.serial, 5);
        if (response == "a" || response == "b") {
          d.accessibility = DeviceAccessibility.AccessibleInternet;
          d.ip = "103.215.221.180";
          print("Device found via internet.");
          return;
        } else {
          print("Device did not have connection to internet.");
        }
      }
      // }
      //couldn't get device in local netowrk, maybe we can connect to internet

    }
    if (d.accessibility == DeviceAccessibility.AccessibleInternet) {
      //try to  connect locally if possible
      if (await Connectivity().checkConnectivity() == ConnectivityResult.wifi) {
        try {
          d.ip = await findDeviceIp(d.serial);
          wsConnect(d.ip);
          d.accessibility = DeviceAccessibility.AccessibleLocal;
          return;
        } catch (e) {}
      }
      // or check if internet still connected
      try {
        final String response = await internet_request("", d.serial, 5);
        if (response == "a" || response == "b") {
          return;
        } else {
          //server said no connection to the device
          d.accessibility = DeviceAccessibility.InAccessible;
        }
      } catch (e) {
        d.accessibility = DeviceAccessibility.InAccessible;
      }
    }
    if (d.accessibility == DeviceAccessibility.AccessibleLocal) {
      //check if connection is stable
      try {
        if (wsChannel == null || wsChannel!.closeCode != null) {
          //socket destroyed for some reson...
          print("WS Socket was destroyed on local device ${d.serial} re creating ws");
          wsConnect(d.ip);
        }
        var answer = await udp_request('_PING', d.ip);

        if (d.serial == answer) {
          d.accessibility = DeviceAccessibility.AccessibleLocal;
        } else {
          d.accessibility = DeviceAccessibility.InAccessible;
        }
      } catch (e) {
        d.accessibility = DeviceAccessibility.InAccessible;
      }
    }
  }

  void handleFailures(String msg, [context]) {
    if (context != null) {
      Utils.show_error_dialog(context, "Something went wrong.", msg, null);
    }
    throw Exception(msg);
  }

  void handle_timeout(context) {
    Utils.show_error_dialog(context, "Something went wrong.", "Probably air conditioner is offline; Request has failed after 3 retries.", null);
    throw Exception('timedout');
  }

  String removeSpecialChars(String str) => str.replaceAll("?", "");

  //get request, timeout&context -> show error dialog , timeout without context -> trigger device offline, WILL complete the Futrue with error
  Future<String> getRequest(int number, [context]) async {
    Device _device = SavedDevicesChangeNotifier.getSelectedDevice()!;
    if (_device.accessibility == DeviceAccessibility.AccessibleLocal) {
      if (wsChannel == null || wsChannel!.closeCode != null) //closed or destroyed?
      {
        handleFailures('no ws socket for device, cant get {$number}', context);
      }
      var numberStr = number.toString().padLeft(3, '0');
      String result = "";
      try {
        result = await ws_send_request("get" + numberStr);
      } catch (e) {
        if (e == "timeout") handle_timeout(context);
      }
      result = removeSpecialChars(result);
      return result;
    } else if (_device.accessibility == DeviceAccessibility.AccessibleInternet) {
      final String serial = _device.serial;
      var numberStr = number.toString().padLeft(3, '0');

      String result = "";
      try {
        result = await internet_request("get" + numberStr, serial);
      } catch (e) {
        if (e == "timeout") handle_timeout(context);
      }
      result = removeSpecialChars(result);
      return result;
    } else {
      //error: device offline
      handleFailures('device offline, cant get ${number}', context);
      return ""; //won't reach this line
    }
  }

  Future<bool> setRequest(int number, String value, [context]) async {
    Device _device = SavedDevicesChangeNotifier.getSelectedDevice()!;
    if (_device.accessibility == DeviceAccessibility.AccessibleLocal) {
      if (wsChannel == null || wsChannel!.closeCode != null) //closed or destroyed?
      {
        handleFailures('no ws socket for device, cant set {$number}', context);
      }
      var numberStr = number.toString().padLeft(3, '0');

      String result = "";
      try {
        result = await ws_send_request("set" + numberStr + ":" + value);
      } catch (e) {
        if (e == "timeout") handle_timeout(context);
      }

      return (result.toLowerCase() == "ok");
    } else if (_device.accessibility == DeviceAccessibility.AccessibleInternet) {
      final String serial = _device.serial;
      var numberStr = number.toString().padLeft(3, '0');
      String result = "";
      try {
        result = await internet_request("set" + numberStr + ":" + value, serial);
      } catch (e) {
        if (e == "timeout") handle_timeout(context);
      }
      result = removeSpecialChars(result);
      return (result.toLowerCase() == "ok");
    } else {
      //error: device offline
      handleFailures('device offline, cant set ${number}', context);
      return false; //won't reach this line
    }
  }

  Future<String> udp_request(String request_data, String ip) {
    final requestId = uuid.v1();
    String finalRequest = requestId + "/" + request_data;
    udpRequests[requestId] = new UdpTimedRequest(requestId, finalRequest, ip);
    return udpRequests[requestId]!.start();
  }

  static void udp_send_text(String request_data, String ip) {
    InternetAddress DESTINATION_ADDRESS = InternetAddress(ip);
    List<int> data = AsciiCodec().encode(request_data);
    if (udpSocket == null) {
      throw Exception("udp socket was null, failure sending: ${request_data} to ip: ${ip}");
    }
    udpSocket!.send(data, DESTINATION_ADDRESS, 9315);
  }

  static Future<String> internet_request(String request_data, String serial, [int request_type = 3]) {
    final requestId = uuid.v1();
    internetRequests[requestId] = new InternetTimedRequest(requestId, request_type, request_data, serial);
    return internetRequests[requestId]!.start();
  }

  //internet
  static const String server_url = "http://103.215.221.180:3000";
  static Future<void> internet_http_request(int request_type, String data, String serial) async {
    //returns exception if fails
    AsciiCodec().encode(data);

    String stringReceived = (await http.post(Uri.parse(server_url),
            headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'Request-Type': request_type.toString(), 'Device-Serial': serial},
            body: data))
        .body;

    if (stringReceived.length > 0 && stringReceived[stringReceived.length - 1] == '\n') {
      stringReceived = stringReceived.substring(0, stringReceived.length - 1);
    }
    //subtract id
    var str_splited = stringReceived.split('*');
    if (str_splited.length == 2) {
      String id = str_splited[0];
      stringReceived = str_splited[1];
      internetRequests[id]!.complete(stringReceived);
    }
  }

  // //this line wont be reached, if it dose, means the requst was something we dont understand, no answer
  // return new Completer<String>().future;
  static String DeviceName = "";
  static String Device_Serial_Num = "";
  static String Device_Model = "";
  static String Device_Fan_Power = "";
  static String Power_Box_Serial_Num = "";
  static String GSM_Modem_Serial_Num = "";
  static String Temp_Sensor_Serial_Num_0 = "";
  static String Temp_Sensor_Serial_Num_1 = "";
  static String Temp_Sensor_Serial_Num_2 = "";
  static String Temp_Sensor_Serial_Num_3 = "";
  static String Temp_Sensor_Serial_Num_4 = "";
  static String Temp_Sensor_Serial_Num_5 = "";
  static String Temp_Sensor_Serial_Num_6 = "";
  static String Temp_Sensor_Serial_Num_7 = "";
  static String Temp_Sensor_Serial_Num_8 = "";
  static String Temp_Sensor_Serial_Num_9 = "";
  static String Mobile_Name_0 = "";
  static String Mobile_Name_1 = "";
  static String Mobile_Name_2 = "";
  static String Mobile_Name_3 = "";
  static String Mobile_Name_4 = "";
  static String Mobile_Name_5 = "";
  static String Mobile_Model_0 = "";
  static String Mobile_Model_1 = "";
  static String Mobile_Model_2 = "";
  static String Mobile_Model_3 = "";
  static String Mobile_Model_4 = "";
  static String Mobile_Model_5 = "";
  static String Mobile_IMEI_0 = "";
  static String Mobile_IMEI_1 = "";
  static String Mobile_IMEI_2 = "";
  static String Mobile_IMEI_3 = "";
  static String Mobile_IMEI_4 = "";
  static String Mobile_IMEI_5 = "";
  static String Elevation = "";
  static String Pressure = "";
  static String Pressure_change = "";
  static String Min_Valid_Output_Fan_Speed = "";
  static String Max_Valid_Output_Fan_Speed = "";
  static String Real_Output_Fan_Power = "";
  static String Output_Fan_Available_Flag = "";
  static String Min_Valid_Input_Fan_Speed_Day = "";
  static String Min_Valid_Input_Fan_Speed_Night = "";
  static String Max_Valid_Input_Fan_Speed_Day = "";
  static String Max_Valid_Input_Fan_Speed_Night = "";
  static String Input_Fan_Power = "";
  static String Input_Fan_Available_Flag = "";
  static String Favourite_Room_Temp_Day_ = "";
  static String Room_Temp_Sensitivity_Day = "";
  static String Cooler_Start_Temp_Day = "";
  static String Cooler_Stop_Temp_Day = "";
  static String Heater_Start_Temp_Day = "";
  static String Heater_Stop_Temp_Day = "";
  static String Favourite_Room_Temp_Night = "";
  static String Room_Temp_Sensitivity_Night = "";
  static String Cooler_Start_Temp_Night = "";
  static String Cooler_Stop_Temp_Night = "";
  static String Heater_Start_Temp_Night = "";
  static String Heater_Stop_Temp_Night = "";
  static String Humidity_Controller = "";
  static String Max_Day_Humidity = "";
  static String Min_Day_Humidity = "";
  static String Max_Night_Humidity = "";
  static String Min_Night_Humidity = "";
  static String IAQ_Flag = "";
  static String Max_Day_IAQ = "";
  static String Min_Day_IAQ = "";
  static String Max_Night_IAQ = "";
  static String Min_Night_IAQ = "";
  static String CO2_Flag = "";
  static String Max_Day_CO2 = "";
  static String Min_Day_CO2 = "";
  static String Max_Night_CO2 = "";
  static String Min_Night_CO2 = "";
  static String Min_Day_Lux = "";
  static String Max_Night_Lux = "";
  static String License_Type = "";
  static String Increase_Fan_Power_License = "";
  static String Increase_Connected_Mobile_License = "";
  static String Real_Room_Temp_0 = "";
  static String Real_Room_Temp_1 = "";
  static String Real_Room_Temp_2 = "";
  static String Real_Room_Temp_3 = "";
  static String Real_Room_Temp_4 = "";
  static String Real_Room_Temp_5 = "";
  static String Real_Room_Temp_6 = "";
  static String Real_Room_Temp_7 = "";
  static String Real_Room_Temp_8 = "";
  static String Real_Room_Temp_9 = "";
  static String Real_Outdoor_Temp = "";
  static String Real_Negative_Pressure_ = "";
  static String Real_Humidity = "";
  static String Real_IAQ = "";
  static String Real_CO2 = "";
  static String Real_Light_Level = "";
  static String Real_Input_Fan_Speed = "";
  static String Real_Output_Fan_Speed = "";
  static String Cooler_Status = "";
  static String Heater_Status = "";
  static String Air_Purifier_Status = "";
  static String Humidity_Controller_Status = "";
  static String Mobile_Number_0 = "";
  static String Mobile_Number_1 = "";
  static String Mobile_Number_2 = "";
  static String Mobile_Number_3 = "";
  static String Mobile_Number_4 = "";
  static String Mobile_Number_5 = "";
  static String GSM_Signal_Power = "";
  static String GSM_SIM_Number = "";
  static String GSM_SIM_Balance = "";
  static String SMS_Priorities_State = "0000000";
  static String Access_To_Internet_State = "";
  static String Cooler_Controller_Day_Mode = "";
  static String Cooler_Controller_Night_Mod = "";
  static String Heater_Controller_Day_Mode = "";
  static String Heater_Controller_Night_Mode = "";
  static String Humidity_Controller_Day_Mode = "";
  static String Humidity_Controller_Night_Mode = "";
  static String Air_Purifier_Controller_Day_Mode = "";
  static String Air_Purifier_Controller_Night_Mode = "";
  //internet
  static String DEVICE_WIFI_TO_CONNECT_NAME = "";
  static String DEVICE_WIFI_TO_CONNECT_PASS = "";
  static String DEVICE_CONNECT_TO_INTERNET = "";
}
