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
  static RawDatagramSocket? udpSocket;
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
        udpSocket!.broadcastEnabled = true;

        udpSocket!.listen((e) {
          Datagram? dg = udpSocket!.receive();
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
      },
    );
  }

  ConnectionManager() {
    CreateSocket();
    // timeoutTimer = Timer(Duration(milliseconds: 0), () {});
  }

  Future<void> sendDiscoverSignal() async {
    found_devices = [];

    if (udpSocket == null) {
      CreateSocket();
      return;
    }

    String result = await getRequest('_DISCOVER', "255.255.255.255");
    var arr = result.split(',');

    const String discover_symbol = "_INFO";
    if (arr[0] == discover_symbol) {
      //add device to list
      Device device = Device(wifiname: arr[1], name: arr[1], serial: arr[2], ip: last_sender_host, connectionState: ConnectionStatus.connected_close);
      if (!found_devices.contains(device)) {
        found_devices.add(device);
      } else {
        found_devices[found_devices.indexOf(device)].wifiname = device.name;
      }
      return;
    }
  }

  Future<int> pingDevice(Device d) async {
    if (udpSocket == null) {
      CreateSocket();
      return -1;
    }
    _pingtimer.reset();
    _pingtimer.start();

    var answer = await getRequest('_PING', d.ip);

    //Eleapsed time
    int res = _pingtimer.elapsedMilliseconds; //returns a Duration
    _pingtimer.stop();

    if (d.serial == answer) {
    } else {
      res = -1;
    }

    return res;
  }

  // late Timer timeoutTimer;
  // late Future<String> last_future;

  Future<String> getRequest_non0(String request, [ip]) async {
    String results = await getRequest(request, ip);

    while (results.startsWith('0')) {
      results = results.substring(1);
    }
    return results;
  }

  Future<String> getRequest(String request, [ip]) async {
    final requestId = uuid.v1();

    requests[requestId] = new TimedRequest(requestId, request, ip);

    execute(id: requestId, request_data: request, ip: ip);
    return requests[requestId]!.start();
  }

  Future<bool> set_request(int id, value) async {
    try {
      var id_str = id.toString().padLeft(3, '0');

      var result = await getRequest("set$id_str:$value");
      if (result != "OK") {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static void execute({id, request_data, ip}) {
    assert(SavedDevicesChangeNotifier.selected_device != null || ip != null);

    ip = ip ?? SavedDevicesChangeNotifier.selected_device!.ip;
    InternetAddress DESTINATION_ADDRESS = InternetAddress(ip);
    String discover_symbol = id + "/" + request_data;
    List<int> data = AsciiCodec().encode(discover_symbol);
    udpSocket!.send(data, DESTINATION_ADDRESS, 9315);
  }

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

  // void execute(cmd) {
  //   InternetAddress DESTINATION_ADDRESS = InternetAddress(SavedDevicesChangeNotifier.selected_device!.ip);
  //   List<int> data = AsciiCodec().encode(cmd);
  //   udpSocket.send(data, DESTINATION_ADDRESS, 8889);
  // }
}
