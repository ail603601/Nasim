import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:core';

import 'package:nasim/Model/Device.dart';
import 'package:nasim/Model/timedrequest.dart';
import 'package:nasim/provider/SavedevicesChangeNofiter.dart';
import 'package:uuid/uuid.dart';
import 'package:nasim/utils.dart';
import '../enums.dart';

class ConnectionManager extends ChangeNotifier {
  List<Device> found_devices = [];
  late RawDatagramSocket udpSocket;
  static final Map<String, TimedRequest> requests = {};
  var uuid = Uuid();

  Completer<String>? futuremanager;
  final Stopwatch _pingtimer = Stopwatch();
  complete_read_future(string_received) {
    // try {
    futuremanager!.complete(string_received);
    // } catch (e) {}
  }

  var last_sender_host = "0.0.0.0";
  CreateSocket() {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 9315).then(
      (RawDatagramSocket _udpSocket) {
        udpSocket = _udpSocket;
        udpSocket.broadcastEnabled = true;

        udpSocket.listen((e) {
          Datagram? dg = udpSocket.receive();
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
          CreateSocket();
        });
      },
    );
  }

  ConnectionManager() {
    CreateSocket();
    timeoutTimer = Timer(Duration(milliseconds: 0), () {});
  }

  sendDiscoverSignal() async {
    String result = await getRequest('_DISCOVER', "255.255.255.255");
    var arr = result.split(',');

    const String discover_symbol = "_INFO";
    if (arr[0] == discover_symbol) {
      //add device to list
      Device device = Device(name: arr[1], serial: arr[2], ip: last_sender_host, connectionState: ConnectionStatus.connected_close);
      if (!found_devices.contains(device)) {
        found_devices.add(device);
      }
      return;
    }
  }

  Future<int> pingDevice(Device d) async {
    _pingtimer.reset();
    _pingtimer.start();

    var answer = await getRequest('_PING', d.ip);
    //Eleapsed time
    int res = _pingtimer.elapsedMilliseconds; //returns a Duration
    _pingtimer.stop();

    if ('timeout' == answer) {
      res = -1;
    }

    return res;
  }

  Future<bool> getRequestAutoCheck(String request, context) async {
    String result = await getRequest(request);
    if (result == "timeout") {
      return false;
    } else
      return true;
  }

  late Timer timeoutTimer;
  // late Future<String> last_future;
  Future<String> getRequest(String request, [ip]) async {
    final requestId = uuid.v1();

    requests[requestId] = new TimedRequest(requestId);

    execute(id: requestId, request_data: request, ip: ip);
    return requests[requestId]!.start();
  }

  Future<bool> set_request(int id, value) async {
    var result = await getRequest("set$id:$value");
    if (result != "OK") {
      return false;
    }
    return true;
  }

  void execute({id, request_data, ip}) {
    assert(SavedDevicesChangeNotifier.selected_device != null || ip != null);

    ip = ip ?? SavedDevicesChangeNotifier.selected_device!.ip;
    InternetAddress DESTINATION_ADDRESS = InternetAddress(ip);
    String discover_symbol = id + "/" + request_data;
    List<int> data = AsciiCodec().encode(discover_symbol);
    udpSocket.send(data, DESTINATION_ADDRESS, 9315);
  }

  static String DeviceName = "X";
  static String Device_Serial_Num = "X";
  static String Device_Model = "X";
  static String Device_Fan_Power = "X";
  static String Power_Box_Serial_Num = "X";
  static String GSM_Modem_Serial_Num = "X";
  static String Temp_Sensor_Serial_Num_10 = "X";
  static String Mobile_Name_6 = "X";
  static String Mobile_Model_6 = "X";
  static String Mobile_IMEI_6 = "X";
  static String Elevation = "X";
  static String Pressure = "X";
  static String Pressure_change = "X";
  static String Min_Valid_Output_Fan_Speed = "X";
  static String Max_Valid_Output_Fan_Speed = "X";
  static String Real_Output_Fan_Power = "X";
  static String Output_Fan_Available_Flag = "X";
  static String Min_Valid_Input_Fan_Speed_Day = "X";
  static String Min_Valid_Input_Fan_Speed_Night = "X";
  static String Max_Valid_Input_Fan_Speed_Day = "X";
  static String Max_Valid_Input_Fan_Speed_Night = "X";
  static String Input_Fan_Power = "X";
  static String Input_Fan_Available_Flag = "X";
  static String Favourite_Room_Temp_Day_ = "X";
  static String Room_Temp_Sensitivity_Day = "X";
  static String Cooler_Start_Temp_Day = "X";
  static String Cooler_Stop_Temp_Day = "X";
  static String Heater_Start_Temp_Day = "X";
  static String Heater_Stop_Temp_Day = "X";
  static String Favourite_Room_Temp_Night = "X";
  static String Room_Temp_Sensitivity_Night = "X";
  static String Cooler_Start_Temp_Night = "X";
  static String Cooler_Stop_Temp_Night = "X";
  static String Heater_Start_Temp_Night = "X";
  static String Heater_Stop_Temp_Night = "X";
  static String Humidity_Controller = "X";
  static String Max_Day_Humidity = "X";
  static String Min_Day_Humidity = "X";
  static String Max_Night_Humidity = "X";
  static String Min_Night_Humidity = "X";
  static String IAQ_Flag = "X";
  static String Max_Day_IAQ = "X";
  static String Min_Day_IAQ = "X";
  static String Max_Night_IAQ = "X";
  static String Min_Night_IAQ = "X";
  static String CO2_Flag = "X";
  static String Max_Day_CO2 = "X";
  static String Min_Day_CO2 = "X";
  static String Max_Night_CO2 = "X";
  static String Min_Night_CO2 = "X";
  static String Min_Day_Lux = "X";
  static String Max_Night_Lux = "X";
  static String License_Type = "X";
  static String Increase_Fan_Power_License = "X";
  static String Increase_Connected_Mobile_License = "X";
  static String Real_Room_Temp_9 = "X";
  static String Real_Outdoor_Temp = "X";
  static String Real_Negative_Pressure_ = "X";
  static String Real_Humidity = "X";
  static String Real_IAQ = "X";
  static String Real_CO2 = "X";
  static String Real_Light_Level = "X";
  static String Real_Input_Fan_Speed = "X";
  static String Real_Output_Fan_Speed = "X";
  static String Cooler_Status = "X";
  static String Heater_Status = "X";
  static String Air_Purifier_Status = "X";
  static String Humidity_Controller_Status = "X";
  static String Mobile_Number_6 = "X";
  static String GSM_Signal_Power = "X";
  static String GSM_SIM_Number = "X";
  static String GSM_SIM_Balance = "X";
  static String SMS_Priorities_State = "X";
  static String Access_To_Internet_State = "X";
  static String Cooler_Controller_Day_Mode = "X";
  static String Cooler_Controller_Night_Mod = "X";
  static String Heater_Controller_Day_Mode = "X";
  static String Heater_Controller_Night_Mode = "X";
  static String Humidity_Controller_Day_Mode = "X";
  static String Humidity_Controller_Night_Mode = "X";
  static String Air_Purifier_Controller_Day_Mode = "X";
  static String Air_Purifier_Controller_Night_Mode = "X";

  // void execute(cmd) {
  //   InternetAddress DESTINATION_ADDRESS = InternetAddress(SavedDevicesChangeNotifier.selected_device!.ip);
  //   List<int> data = AsciiCodec().encode(cmd);
  //   udpSocket.send(data, DESTINATION_ADDRESS, 8889);
  // }
}
