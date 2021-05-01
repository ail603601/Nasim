import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';

import 'package:nasim/Model/Device.dart';

import '../enums.dart';

class ConnectionManager extends ChangeNotifier {
  List<Device> found_devices = [];
  late RawDatagramSocket udpSocket;

  var cb;

  ConnectionManager() {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 8889).then((RawDatagramSocket _udpSocket) {
      udpSocket = _udpSocket;
      udpSocket.broadcastEnabled = true;
      udpSocket.listen((e) {
        Datagram? dg = udpSocket.receive();
        if (dg != null) {
          const String discover_symbol = "NASIM_SERVER_INFO";
          if (dg.data.length >= discover_symbol.length) {
            if (listEquals(dg.data.sublist(0, discover_symbol.length), AsciiCodec().encode(discover_symbol)) == true) {
              var arr = AsciiCodec().decode(dg.data).split(',');
              //add device to list
              Device device = Device(name: arr[1], serial: arr[2], ip: dg.address.host, connectionState: ConnectionStatus.connected_close);
              if (!found_devices.contains(device)) {
                found_devices.add(device);
              }
            }
          }

          print("received ${dg}"); //dg.address.host

        }
      });
    });
  }

  sendDiscoverSignal() {
    InternetAddress DESTINATION_ADDRESS = InternetAddress("255.255.255.255");
    const String discover_symbol = "NASIM_SERVER_DISCOVER";
    List<int> data = AsciiCodec().encode(discover_symbol);
    udpSocket.send(data, DESTINATION_ADDRESS, 8889);
  }

  late Device target;
  setTargetDevice(Device d) {
    target = d;
  }

  // void ProccessReceiveCmd(String cmd) {
  //   var splited_cmd = cmd.split("_");
  //   if (splited_cmd[1] != "OK") {
  //     int index = int.parse(splited_cmd[0]);
  //     switch (index) {
  //       case 21:
  //         DeviceName = splited_cmd[1];
  //         break;
  //       case 22:
  //         Device_Serial_Num = splited_cmd[1];
  //         break;
  //       case :
  //       break;
  //               case :
  //       break;
  //               case :
  //       break;
  //               case :
  //       break;
  //               case :
  //       break;
  //               case :
  //       break;
  //               case :
  //       break;
  //               case :
  //       break;
  //               case :
  //       break;
  //               case :
  //       break;
  //               case :
  //       break;
  //               case :
  //       break;
  //               case :
  //       break;
  //               case :
  //       break;
  //               case :
  //       break;
  //               case :
  //       break;
  //               case :
  //       break;        case :
  //       break;
  //               case :
  //       break;
  //               case :
  //       break;
  //     }
  //   }
  // }

  var DeviceName;
  var Device_Serial_Num;
  var Device_Model;
  var Device_Fan_Power;
  var Power_Box_Serial_Num;
  var GSM_Modem_Serial_Num;
  var Temp_Sensor_Serial_Num_10;
  var Mobile_Name_6;
  var Mobile_Model_6;
  var Mobile_IMEI_6;
  var Elevation;
  var Pressure;
  var Pressure_change;
  var Min_Valid_Output_Fan_Speed;
  var Max_Valid_Output_Fan_Speed;
  var Real_Output_Fan_Power;
  var Output_Fan_Available_Flag;
  var Min_Valid_Input_Fan_Speed_Day;
  var Min_Valid_Input_Fan_Speed_Night;
  var Max_Valid_Input_Fan_Speed_Day;
  var Max_Valid_Input_Fan_Speed_Night;
  var Input_Fan_Power;
  var Input_Fan_Available_Flag;
  var Favourite_Room_Temp_Day_;
  var Room_Temp_Sensitivity_Day;
  var Cooler_Start_Temp_Day;
  var Cooler_Stop_Temp_Day;
  var Heater_Start_Temp_Day;
  var Heater_Stop_Temp_Day;
  var Favourite_Room_Temp_Night;
  var Room_Temp_Sensitivity_Night;
  var Cooler_Start_Temp_Night;
  var Cooler_Stop_Temp_Night;
  var Heater_Start_Temp_Night;
  var Heater_Stop_Temp_Night;
  var Humidity_Controller;
  var Max_Day_Humidity;
  var Min_Day_Humidity;
  var Max_Night_Humidity;
  var Min_Night_Humidity;
  var IAQ_Flag;
  var Max_Day_IAQ;
  var Min_Day_IAQ;
  var Max_Night_IAQ;
  var Min_Night_IAQ;
  var CO2_Flag;
  var Max_Day_CO2;
  var Min_Day_CO2;
  var Max_Night_CO2;
  var Min_Night_CO2;
  var Min_Day_Lux;
  var Max_Night_Lux;
  var License_Type;
  var Increase_Fan_Power_License;
  var Increase_Connected_Mobile_License;
  var Real_Room_Temp_9;
  var Real_Outdoor_Temp;
  var Real_Negative_Pressure_;
  var Real_Humidity;
  var Real_IAQ;
  var Real_CO2;
  var Real_Light_Level;
  var Real_Input_Fan_Speed;
  var Real_Output_Fan_Speed;
  var Cooler_Status;
  var Heater_Status;
  var Air_Purifier_Status;
  var Humidity_Controller_Status;
  var Mobile_Number_6;
  var GSM_Signal_Power;
  var GSM_SIM_Number;
  var GSM_SIM_Balance;
  var SMS_Priorities_State;
  var Access_To_Internet_State;
  var Cooler_Controller_Day_Mode;
  var Cooler_Controller_Night_Mod;
  var Heater_Controller_Day_Mode;
  var Heater_Controller_Night_Mode;
  var Humidity_Controller_Day_Mode;
  var Humidity_Controller_Night_Mode;
  var Air_Purifier_Controller_Day_Mode;
  var Air_Purifier_Controller_Night_Mode;

  void execute(cmd) {
    InternetAddress DESTINATION_ADDRESS = InternetAddress(target.ip);
    List<int> data = AsciiCodec().encode(cmd);
    udpSocket.send(data, DESTINATION_ADDRESS, 8889);
  }
}
