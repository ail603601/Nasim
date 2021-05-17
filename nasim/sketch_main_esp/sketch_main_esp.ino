

/* Create a WiFi access point and provide a web server on it. */
#include <EEPROM.h>

#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <WiFiUdp.h>

#include "eep_interface.h"

#define TEST_MODE 1


char device_initialized[] = "0";

//globlal table
char DeviceName[] = "0000000000";
char Device_Serial_Num[] = "0000000000";
char Device_Model[] = "0000000000";
char Device_Fan_Power[] = "0123";
char Power_Box_Serial_Num[] = "0000000000";
char GSM_Modem_Serial_Num[] = "0000000000";
char Temp_Sensor_Serial_Num_0[] = "0000000000";
char Temp_Sensor_Serial_Num_1[] = "0000000000";
char Temp_Sensor_Serial_Num_2[] = "0000000000";
char Temp_Sensor_Serial_Num_3[] = "0000000000";
char Temp_Sensor_Serial_Num_4[] = "0000000000";
char Temp_Sensor_Serial_Num_5[] = "0000000000";
char Temp_Sensor_Serial_Num_6[] = "0000000000";
char Temp_Sensor_Serial_Num_7[] = "0000000000";
char Temp_Sensor_Serial_Num_8[] = "0000000000";
char Temp_Sensor_Serial_Num_9[] = "0000000000";
char Mobile_Name_0[] = "0000000000";
char Mobile_Name_1[] = "0000000000";
char Mobile_Name_2[] = "0000000000";
char Mobile_Name_3[] = "0000000000";
char Mobile_Name_4[] = "0000000000";
char Mobile_Name_5[] = "0000000000";
char Mobile_Model_0[] = "X";
char Mobile_Model_1[] = "X";
char Mobile_Model_2[] = "X";
char Mobile_Model_3[] = "X";
char Mobile_Model_4[] = "X";
char Mobile_Model_5[] = "X";
char Mobile_IMEI_0[] = "X";
char Mobile_IMEI_1[] = "X";
char Mobile_IMEI_2[] = "X";
char Mobile_IMEI_3[] = "X";
char Mobile_IMEI_4[] = "X";
char Mobile_IMEI_5[] = "X";
char Elevation[] = "12345";
char Pressure[] = "12345";
char Pressure_change[] = "1234";
char Min_Valid_Output_Fan_Speed[] = "000";
char Max_Valid_Output_Fan_Speed[] = "000";
char Real_Output_Fan_Power[] = "0000";
char Output_Fan_Available_Flag[] = "0";
char Min_Valid_Input_Fan_Speed_Day[] = "000";
char Min_Valid_Input_Fan_Speed_Night[] = "000";
char Max_Valid_Input_Fan_Speed_Day[] = "000";
char Max_Valid_Input_Fan_Speed_Night[] = "000";
char Input_Fan_Power[] = "0000";
char Input_Fan_Available_Flag[] = "0";
char Favourite_Room_Temp_Day_[] = "+000";  //alamat far
char Room_Temp_Sensitivity_Day[] = "00";   //float
char Cooler_Start_Temp_Day[] = "+000";     //alamat far
char Cooler_Stop_Temp_Day[] = "+000";      //alamat far
char Heater_Start_Temp_Day[] = "+000";     //alamat far
char Heater_Stop_Temp_Day[] = "+000";      //alamat far
char Favourite_Room_Temp_Night[] = "+000"; //alamat far
char Room_Temp_Sensitivity_Night[] = "00"; //float
char Cooler_Start_Temp_Night[] = "+000";   //alamat far
char Cooler_Stop_Temp_Night[] = "+000";    //alamat far
char Heater_Start_Temp_Night[] = "+000";   //alamat far
char Heater_Stop_Temp_Night[] = "+000";    //alamat far
char Humidity_Controller[] = "0";
char Max_Day_Humidity[] = "000";
char Min_Day_Humidity[] = "000";
char Max_Night_Humidity[] = "000";
char Min_Night_Humidity[] = "000";
char IAQ_Flag[] = "0";
char Max_Day_IAQ[] = "0000";
char Min_Day_IAQ[] = "0000";
char Max_Night_IAQ[] = "0000";
char Min_Night_IAQ[] = "0000";
char CO2_Flag[] = "0";
char Max_Day_CO2[] = "0000";
char Min_Day_CO2[] = "0000";
char Max_Night_CO2[] = "0000";
char Min_Night_CO2[] = "0000";
char Min_Day_Lux[] = "0000";
char Max_Night_Lux[] = "0000";
char License_Type[] = "0";
char Increase_Fan_Power_License[] = "0000000000";
char Increase_Connected_Mobile_License[] = "0000000000";
char Real_Room_Temp_0[] = "+000";  //alamat far
char Real_Room_Temp_1[] = "+000";  //alamat far
char Real_Room_Temp_2[] = "+000";  //alamat far
char Real_Room_Temp_3[] = "+000";  //alamat far
char Real_Room_Temp_4[] = "+000";  //alamat far
char Real_Room_Temp_5[] = "+000";  //alamat far
char Real_Room_Temp_6[] = "+000";  //alamat far
char Real_Room_Temp_7[] = "+000";  //alamat far
char Real_Room_Temp_8[] = "+000";  //alamat far
char Real_Room_Temp_9[] = "+000";  //alamat far
char Real_Outdoor_Temp[] = "+000"; //alamat far
char Real_Negative_Pressure_[] = "0000";
char Real_Humidity[] = "000";
char Real_IAQ[] = "0000";
char Real_CO2[] = "0000";
char Real_Light_Level[] = "0000";
char Real_Input_Fan_Speed[] = "000";
char Real_Output_Fan_Speed[] = "000";
char Cooler_Status[] = "0";
char Heater_Status[] = "0";
char Air_Purifier_Status[] = "0";
char Humidity_Controller_Status[] = "0";
char Mobile_Number_0[] = "0000000000";
char Mobile_Number_1[] = "0000000000";
char Mobile_Number_2[] = "0000000000";
char Mobile_Number_3[] = "0000000000";
char Mobile_Number_4[] = "0000000000";
char Mobile_Number_5[] = "0000000000";
char GSM_Signal_Power[] = "000";
char GSM_SIM_Number[] = "0000000000";
char GSM_SIM_Balance[] = "1234567";
char SMS_Priorities_State[] = "0000000";
char Access_To_Internet_State[] = "0";
char Cooler_Controller_Day_Mode[] = "0";
char Cooler_Controller_Night_Mod[] = "0";
char Heater_Controller_Day_Mode[] = "0";
char Heater_Controller_Night_Mode[] = "0";
char Humidity_Controller_Day_Mode[] = "0";
char Humidity_Controller_Night_Mode[] = "0";
char Air_Purifier_Controller_Day_Mode[] = "0";
char Air_Purifier_Controller_Night_Mode[] = "0";

#ifndef APSSID
#define APSSID "BREEZE Air Conditioner2"
#define APPSK "thereisnospoon"
#endif
#define BAUD_SERIAL 9600

#define SERIAL_NUMBER 12345678

/* Set these to your desired credentials. */
const char *ssid = APSSID;
const char *password = APPSK;
IPAddress local_IP(192, 168, 4, 22);
IPAddress gateway(192, 168, 4, 9);
IPAddress subnet(255, 255, 255, 0);
unsigned int localPort = 9315; // local port to listen on

// buffers for receiving and sending data
char packetBuffer[UDP_TX_PACKET_MAX_SIZE + 1]; //buffer to hold incoming packet,

char DiscoverBuffer[] = "_INFO,NasimAirCondtioner,12345678"; // a string to send back when discver requested

WiFiUDP Udp;

bool iterate_cmp(char *c1, char *c2)
{
  register int ctr = 0;
  while (1)
  {
    if (c1[ctr] == c2[ctr])
    {
      ctr++;

      if (c1[ctr] == 0 || c2[ctr] == 0)
      {
        return true;
      }
    }
    else
    {
      return false;
    }
  }
}
bool is_line_break_present(char *data, int len)
{
  while (1)
  {
    len--;
    char c = data[len];
    if (c == '\n')
      return true;
    else if (c == 0)
      return false;
    else if (len == 0)
      return false;
  }
  return false;
}
char index_of_char(char c, char *str, int len)
{
  int i = 0;
  while (1)
  {
    if (str[i] == c)
      return i;
    else if (str[i] == 0)
      return 0;
    else if (len == i)
      return 0;

    i++;
  }
}
#if TEST_MODE
  const int timeout = 5000000 / 5; //like 15 sec
  #else
  const int timeout = 80000; //like 10 sec
#endif
void flush(){
  while(Serial.available() > 0) {
    char t = Serial.read();
  }
    Serial.flush();

}

bool micro_request_ok(char *prefix, char *request)
{
 flush();

  Serial.write(prefix, strlen(prefix));
  Serial.write(request, strlen(request));
  Serial.write('\n');

  int timeout_ctr = 0;

  while (1)
  {
    timeout_ctr++;
    size_t len = (size_t)Serial.available();
    if (len)
    {
      uint8_t sbuf[50];
      size_t serial_got = Serial.readBytes(sbuf, len);
      while (!is_line_break_present((char *)sbuf, serial_got))
      {
        serial_got += Serial.readBytes((char *)sbuf + serial_got, len);
      }
      sbuf[serial_got] = 0;

#if TEST_MODE
      Serial.write("\nReceived: ");
      Serial.write(sbuf, serial_got);
      Serial.write("\n");
#endif

      int index = index_of_char('_', (char *)sbuf, serial_got);
      bool is_ok = sbuf[index + 1] == 'O' && sbuf[index + 2] == 'K';
      if (is_ok)
      {

#if TEST_MODE
        Serial.write("Request succeed!\n");
#endif
        return true;
      }
      else
      {
#if TEST_MODE
        Serial.write("Request failed (NOK)!\n");
#endif
        return false;
      }
    }
    else if (timeout_ctr > timeout)
    {
#if TEST_MODE
      Serial.write("timed out\n");
#endif

      return false;
    }
  }
}

void micro_get_requiest(char *get_cmd, char *destination)
{
flush();
  Serial.write(get_cmd, strlen(get_cmd));
  Serial.write('\n');

  int timeout_ctr = 0;
  while (1)
  {
    timeout_ctr++;
    size_t len = (size_t)Serial.available();
    if (len)
    {
      uint8_t sbuf[50];
      size_t serial_got = Serial.readBytes(sbuf, len);
      while (!is_line_break_present((char *)sbuf, serial_got))
      {
        serial_got += Serial.readBytes((char *)sbuf + serial_got, len);
      }
      sbuf[serial_got] = 0;

#if TEST_MODE
      Serial.write("\nReceived: ");
      Serial.write(sbuf, serial_got);
      Serial.write("\n");
#endif

      int index = index_of_char('_', (char *)sbuf, serial_got);

#if TEST_MODE
      Serial.write("current get request answered => ");
      Serial.write((char *)&sbuf[index+1]);
      Serial.write("\n");
#endif

      strcpy(destination, (char *)&sbuf[index+1]);
      return;
    }
    else if (timeout_ctr > timeout)
    {
#if TEST_MODE
      Serial.write("current get request timed out, answered by last chached data\n");
#endif

      return;
    }
  }
}
void setup()
{
  EEPROM.begin(512);
  Serial.begin(BAUD_SERIAL);
  delay(500);
  //first clean
  if (read_eep(FLASH_CLEANED_1TIME) != 1234)
  {
    eep_clear();
    save_eep(FLASH_CLEANED_1TIME, 1234);
  }
  if (read_eep(DEVICE_INITIALIZED) != 1)
  {
    device_initialized[0] = '0';
  }

  WiFi.softAPConfig(local_IP, gateway, subnet);
  WiFi.setAutoConnect(false);
  WiFi.setAutoReconnect(false);
  WiFi.softAP(ssid);

  delay(1000);

  Udp.begin(localPort);
}
//char incomingPacket[255];  // buffer for incoming packets

int last_target_index = 0;
#define MAX_TARGETS_COUTN 20
char targets_ip[MAX_TARGETS_COUTN][18];
char targets_name[MAX_TARGETS_COUTN][18];

void send_error(char error_code)
{
  char error_msg[] = "!X";
  error_msg[1] = error_code;
  send(error_msg);
}

char incoming_id[45];
void send(char *data)
{
  Udp.beginPacket(Udp.remoteIP(), Udp.remotePort());
  Udp.write(incoming_id);
  Udp.write('*');
  Udp.write(data);
  Udp.endPacket();
}
void send(bool result_request)
{
  Udp.beginPacket(Udp.remoteIP(), Udp.remotePort());
  Udp.write(incoming_id);
  Udp.write('*');
  Udp.write(result_request == true ? "OK" : "NOK");
  Udp.endPacket();
}

void process_get_request(int table_id)
{
  switch (table_id)
  {

  case 0:
    micro_get_requiest("!A??", DeviceName);
    send(DeviceName);
    break;
  case 1:
    micro_get_requiest("!B??", Device_Serial_Num);
    send(Device_Serial_Num);
    break;
  case 2:
    micro_get_requiest("!C??", Device_Model);
    send(Device_Model);
    break;
  case 3:
    micro_get_requiest("!D??", Device_Fan_Power);
    send(Device_Fan_Power);
    break;
  case 4:
    micro_get_requiest("!E??", Power_Box_Serial_Num);
    send(Power_Box_Serial_Num);
    break;
  case 5:
    micro_get_requiest("!F??", GSM_Modem_Serial_Num);
    send(GSM_Modem_Serial_Num);
    break;
  case 6:
    micro_get_requiest("!G0??", Temp_Sensor_Serial_Num_0);
    send(Temp_Sensor_Serial_Num_0);
    break;
  case 7:
    micro_get_requiest("!G1??", Temp_Sensor_Serial_Num_1);
    send(Temp_Sensor_Serial_Num_1);
    break;
  case 8:
    micro_get_requiest("!G2??", Temp_Sensor_Serial_Num_2);
    send(Temp_Sensor_Serial_Num_2);
    break;
  case 9:
    micro_get_requiest("!G3??", Temp_Sensor_Serial_Num_3);
    send(Temp_Sensor_Serial_Num_3);
    break;
  case 10:
    micro_get_requiest("!G4??", Temp_Sensor_Serial_Num_4);
    send(Temp_Sensor_Serial_Num_4);
    break;
  case 11:
    micro_get_requiest("!G5??", Temp_Sensor_Serial_Num_5);
    send(Temp_Sensor_Serial_Num_5);
    break;
  case 12:
    micro_get_requiest("!G6??", Temp_Sensor_Serial_Num_6);
    send(Temp_Sensor_Serial_Num_6);
    break;
  case 13:
    micro_get_requiest("!G7??", Temp_Sensor_Serial_Num_7);
    send(Temp_Sensor_Serial_Num_7);
    break;
  case 14:
    micro_get_requiest("!G8??", Temp_Sensor_Serial_Num_8);
    send(Temp_Sensor_Serial_Num_8);
    break;
  case 15:
    micro_get_requiest("!G9??", Temp_Sensor_Serial_Num_9);
    send(Temp_Sensor_Serial_Num_9);
    break;
  case 16:
    micro_get_requiest("!H0??", Mobile_Name_0);
    send(Mobile_Name_0);
    break;
  case 17:
    micro_get_requiest("!H1??", Mobile_Name_1);
    send(Mobile_Name_1);
    break;
  case 18:
    micro_get_requiest("!H2??", Mobile_Name_2);
    send(Mobile_Name_2);
    break;
  case 19:
    micro_get_requiest("!H3??", Mobile_Name_3);
    send(Mobile_Name_3);
    break;
  case 20:
    micro_get_requiest("!H4??", Mobile_Name_4);
    send(Mobile_Name_4);
    break;
  case 21:
    micro_get_requiest("!H5??", Mobile_Name_5);
    send(Mobile_Name_5);
    break;
  case 22:
    send(Mobile_Model_0);
    break;
  case 23:
    send(Mobile_Model_1);
    break;
  case 24:
    send(Mobile_Model_2);
    break;
  case 25:
    send(Mobile_Model_3);
    break;
  case 26:
    send(Mobile_Model_4);
    break;
  case 27:
    send(Mobile_Model_5);
    break;
  case 28:
    send(Mobile_IMEI_0);
    break;
  case 29:
    send(Mobile_IMEI_1);
    break;
  case 30:
    send(Mobile_IMEI_2);
    break;
  case 31:
    send(Mobile_IMEI_3);
    break;
  case 32:
    send(Mobile_IMEI_4);
    break;
  case 33:
    send(Mobile_IMEI_5);
    break;
  case 34:
    micro_get_requiest("!K??", Elevation);
    send(Elevation);
    break;
  case 35:
    micro_get_requiest("!L??", Pressure);
    send(Pressure);
    break;
  case 36:
    micro_get_requiest("!M??", Pressure_change);
    send(Pressure_change);
    break;
  case 37:
    micro_get_requiest("!N??", Min_Valid_Output_Fan_Speed);
    send(Min_Valid_Output_Fan_Speed);
    break;
  case 38:
    micro_get_requiest("!O??", Max_Valid_Output_Fan_Speed);
    send(Max_Valid_Output_Fan_Speed);
    break;
  case 39:
    micro_get_requiest("!P??", Real_Output_Fan_Power);
    send(Real_Output_Fan_Power);
    break;
  case 40:
    micro_get_requiest("!Q??", Output_Fan_Available_Flag);
    send(Output_Fan_Available_Flag);
    break;
  case 41:
    micro_get_requiest("!R??", Min_Valid_Input_Fan_Speed_Day);
    send(Min_Valid_Input_Fan_Speed_Day);
    break;
  case 42:
    micro_get_requiest("!S??", Min_Valid_Input_Fan_Speed_Night);
    send(Min_Valid_Input_Fan_Speed_Night);
    break;
  case 43:
    micro_get_requiest("!T??", Max_Valid_Input_Fan_Speed_Day);
    send(Max_Valid_Input_Fan_Speed_Day);
    break;
  case 44:
    micro_get_requiest("#A??", Max_Valid_Input_Fan_Speed_Night);
    send(Max_Valid_Input_Fan_Speed_Night);
    break;
  case 45:
    micro_get_requiest("#B??", Input_Fan_Power);
    send(Input_Fan_Power);
    break;
  case 46:
    micro_get_requiest("#C??", Input_Fan_Available_Flag);
    send(Input_Fan_Available_Flag);
    break;
  case 47:
    micro_get_requiest("#D??", Favourite_Room_Temp_Day_);
    send(Favourite_Room_Temp_Day_);
    break;
  case 48:
    micro_get_requiest("#E??", Room_Temp_Sensitivity_Day);
    send(Room_Temp_Sensitivity_Day);
    break;
  case 49:
    micro_get_requiest("#F??", Cooler_Start_Temp_Day);
    send(Cooler_Start_Temp_Day);
    break;
  case 50:
    micro_get_requiest("#G??", Cooler_Stop_Temp_Day);
    send(Cooler_Stop_Temp_Day);
    break;
  case 51:
    micro_get_requiest("#H??", Heater_Start_Temp_Day);
    send(Heater_Start_Temp_Day);
    break;
  case 52:
    micro_get_requiest("#I??", Heater_Stop_Temp_Day);
    send(Heater_Stop_Temp_Day);
    break;
  case 53:
    micro_get_requiest("#J??", Favourite_Room_Temp_Night);
    send(Favourite_Room_Temp_Night);
    break;
  case 54:
    micro_get_requiest("#K??", Room_Temp_Sensitivity_Night);
    send(Room_Temp_Sensitivity_Night);
    break;
  case 55:
    micro_get_requiest("#L??", Cooler_Start_Temp_Night);
    send(Cooler_Start_Temp_Night);
    break;
  case 56:
    micro_get_requiest("#N??", Cooler_Stop_Temp_Night);
    send(Cooler_Stop_Temp_Night);
    break;
  case 57:
    micro_get_requiest("#O??", Heater_Start_Temp_Night);
    send(Heater_Start_Temp_Night);
    break;
  case 58:
    micro_get_requiest("#P??", Heater_Stop_Temp_Night);
    send(Heater_Stop_Temp_Night);
    break;
  case 59:
    micro_get_requiest("#Q??", Humidity_Controller);
    send(Humidity_Controller);
    break;
  case 60:
    micro_get_requiest("#R??", Max_Day_Humidity);

    send(Max_Day_Humidity);
    break;
  case 61:
    micro_get_requiest("#S??", Min_Day_Humidity);
    send(Min_Day_Humidity);
    break;
  case 62:
    micro_get_requiest("#T??", Min_Day_Humidity);
    send(Max_Night_Humidity);
    break;
  case 63:
    micro_get_requiest("%A??", Min_Day_Humidity);
    send(Min_Night_Humidity);
    break;
  case 64:
    micro_get_requiest("%B??", IAQ_Flag);

    send(IAQ_Flag);
    break;
  case 65:
    micro_get_requiest("%C??", Max_Day_IAQ);

    send(Max_Day_IAQ);
    break;
  case 66:
    micro_get_requiest("%D??", Min_Day_IAQ);

    send(Min_Day_IAQ);
    break;
  case 67:
    micro_get_requiest("%E??", Min_Day_IAQ);
    send(Max_Night_IAQ);
    break;
  case 68:
    micro_get_requiest("%F??", Min_Night_IAQ);
    send(Min_Night_IAQ);
    break;
  case 69:
    micro_get_requiest("%H??", CO2_Flag);

    send(CO2_Flag);
    break;
  case 70:
    micro_get_requiest("%I??", Max_Day_CO2);
    send(Max_Day_CO2);
    break;
  case 71:
    micro_get_requiest("%J??", Min_Day_CO2);
    send(Min_Day_CO2);
    break;
  case 72:
    micro_get_requiest("%K??", Max_Night_CO2);
    send(Max_Night_CO2);
    break;
  case 73:
    micro_get_requiest("%L??", Min_Night_CO2);
    send(Min_Night_CO2);
    break;
  case 74:
    send(Min_Day_Lux);
    break;
  case 75:
    send(Max_Night_Lux);
    break;
  case 76:
    send(License_Type);
    break;
  case 77:
    send(Increase_Fan_Power_License);
    break;
  case 78:
    send(Increase_Connected_Mobile_License);
    break;
  case 79:
    micro_get_requiest("%P0??", Real_Room_Temp_0);
    send(Real_Room_Temp_0);
    break;
  case 80:
    micro_get_requiest("%P1??", Real_Room_Temp_1);
    send(Real_Room_Temp_1);
    break;
  case 81:
    micro_get_requiest("%P2??", Real_Room_Temp_2);
    send(Real_Room_Temp_2);
    break;
  case 82:
    micro_get_requiest("%P3??", Real_Room_Temp_3);
    send(Real_Room_Temp_3);
    break;
  case 83:
    micro_get_requiest("%P4??", Real_Room_Temp_4);
    send(Real_Room_Temp_4);
    break;
  case 84:
    micro_get_requiest("%P5??", Real_Room_Temp_5);
    send(Real_Room_Temp_5);
    break;
  case 85:
    micro_get_requiest("%P6??", Real_Room_Temp_6);
    send(Real_Room_Temp_6);
    break;
  case 86:
    micro_get_requiest("%P7??", Real_Room_Temp_7);
    send(Real_Room_Temp_7);
    break;
  case 87:
    micro_get_requiest("%P8??", Real_Room_Temp_8);
    send(Real_Room_Temp_8);
    break;
  case 88:
    micro_get_requiest("%P9??", Real_Room_Temp_9);
    send(Real_Room_Temp_9);
    break;
  case 89:
    micro_get_requiest("%Q??", Real_Outdoor_Temp);
    send(Real_Outdoor_Temp);
    break;
  case 90:
    micro_get_requiest("%R??", Real_Negative_Pressure_);

    send(Real_Negative_Pressure_);
    break;
  case 91:
    micro_get_requiest("%S??", Real_Negative_Pressure_);

    send(Real_Humidity);
    break;
  case 92:
    micro_get_requiest("%ST??", Real_IAQ);

    send(Real_IAQ);
    break;
  case 93:
    micro_get_requiest("*A??", Real_CO2);

    send(Real_CO2);
    break;
  case 94:
    micro_get_requiest("*B??", Real_Light_Level);

    send(Real_Light_Level);
    break;
  case 95:
    micro_get_requiest("*C??", Real_Input_Fan_Speed);

    send(Real_Input_Fan_Speed);
    break;
  case 96:
    micro_get_requiest("*D??", Real_Output_Fan_Speed);

    send(Real_Output_Fan_Speed);
    break;
  case 97:
    micro_get_requiest("*E??", Cooler_Status);

    send(Cooler_Status);
    break;
  case 98:
    micro_get_requiest("*F??", Heater_Status);

    send(Heater_Status);
    break;
  case 99:
    micro_get_requiest("*G??", Air_Purifier_Status);

    send(Air_Purifier_Status);
    break;
  case 100:
    micro_get_requiest("*H??", Humidity_Controller_Status);

    send(Humidity_Controller_Status);
    break;
  case 101:
    micro_get_requiest("*I0??", Mobile_Number_0);
    send(Mobile_Number_0);
    break;
  case 102:
    micro_get_requiest("*I1??", Mobile_Number_1);

    send(Mobile_Number_1);
    break;
  case 103:
    micro_get_requiest("*I2??", Mobile_Number_2);

    send(Mobile_Number_2);
    break;
  case 104:
    micro_get_requiest("*I3??", Mobile_Number_3);

    send(Mobile_Number_3);
    break;
  case 105:
    micro_get_requiest("*I4??", Mobile_Number_4);

    send(Mobile_Number_4);
    break;
  case 106:
    micro_get_requiest("*I5??", Mobile_Number_5);
    send(Mobile_Number_5);
    break;
  case 107:
    micro_get_requiest("*J??", GSM_Signal_Power);
    send(GSM_Signal_Power);
    break;
  case 108:
    micro_get_requiest("*K??", GSM_SIM_Number);

    send(GSM_SIM_Number);
    break;
  case 109:
    micro_get_requiest("*L??", GSM_SIM_Balance);
    send(GSM_SIM_Balance);
    break;
  case 110:
    micro_get_requiest("*M??", SMS_Priorities_State);
    send(SMS_Priorities_State);
    break;
  case 111:
    micro_get_requiest("*N??", SMS_Priorities_State);
    send(Access_To_Internet_State);
    break;
  case 112:
    micro_get_requiest("*O??", Cooler_Controller_Day_Mode);

    send(Cooler_Controller_Day_Mode);
    break;
  case 113:
    micro_get_requiest("*P??", Cooler_Controller_Day_Mode);

    send(Cooler_Controller_Night_Mod);
    break;
  case 114:
    micro_get_requiest("*Q??", Heater_Controller_Day_Mode);

    send(Heater_Controller_Day_Mode);
    break;
  case 115:
    micro_get_requiest("*R??", Heater_Controller_Night_Mode);

    send(Heater_Controller_Night_Mode);
    break;
  case 116:
    micro_get_requiest("*S??", Humidity_Controller_Day_Mode);

    send(Humidity_Controller_Day_Mode);
    break;
  case 117:
    micro_get_requiest("*T??", Humidity_Controller_Night_Mode);

    send(Humidity_Controller_Night_Mode);
    break;
  case 118:
    micro_get_requiest("*U??", Air_Purifier_Controller_Day_Mode);

    send(Air_Purifier_Controller_Day_Mode);
    break;
  case 119:
    micro_get_requiest("*V??", Air_Purifier_Controller_Night_Mode);
    send(Air_Purifier_Controller_Night_Mode);
    break;

  //self defiend
  case 120:
    //    char asf = ((char)last_target_index) + '0';
    //    send(&asf);
    break;

  case 121:
    send(device_initialized);
    break;

  default:
    break;
  }
}

char mstrcpy_container[30];
char *lengh_drop(char *dest, char *from)
{

  bool reached_end_from = false;
  int i = 0;
  while (dest[i] != 0)
  {
    if (from[i] == 0)
    {
      reached_end_from = true;
    }
    mstrcpy_container[i] = reached_end_from ? '0' : from[i];
    i++;
  }
  mstrcpy_container[i] = 0;
  return mstrcpy_container;
}

bool process_set_request(int table_id, char *val)
{
  switch (table_id)
  {

  case 0:
    if (micro_request_ok("(A",lengh_drop( DeviceName, val)))
    {
      strcpy(DeviceName, val);
      return true;
    }
    break;
  case 1:
    if (micro_request_ok("(B",lengh_drop(Device_Serial_Num , val)))
    {
      strcpy(Device_Serial_Num, val);
      return true;
    }
    break;
  case 2:
    if (micro_request_ok("(C",lengh_drop( Device_Model, val)))
    {
      strcpy(Device_Model, val);
      return true;
    }
    break;
  case 3:
    if (micro_request_ok("(D",lengh_drop( Device_Fan_Power, val)))
    {
      strcpy(Device_Fan_Power, val);
      return true;
    }
    break;
  case 4:
    if (micro_request_ok("(E", lengh_drop(Power_Box_Serial_Num,lengh_drop( Power_Box_Serial_Num, val))))
    {
      strcpy(Power_Box_Serial_Num, val);
      return true;
    }
    break;
  case 5:
    if (micro_request_ok("(F",lengh_drop( GSM_Modem_Serial_Num, val)))
    {
      strcpy(GSM_Modem_Serial_Num, val);
      return true;
    }
    break;
  case 6:
    if (micro_request_ok("(G0",lengh_drop(Temp_Sensor_Serial_Num_0 , val)))
    {
      strcpy(Temp_Sensor_Serial_Num_0, val);
      return true;
    }

    break;
  case 7:
    if (micro_request_ok("(G1",lengh_drop(Temp_Sensor_Serial_Num_1 , val)))
    {
      strcpy(Temp_Sensor_Serial_Num_1, val);
      return true;
    }

    break;
  case 8:
    if (micro_request_ok("(G2",lengh_drop( Temp_Sensor_Serial_Num_2, val)))
    {
      strcpy(Temp_Sensor_Serial_Num_2, val);
      return true;
    }

    break;
  case 9:
    if (micro_request_ok("(G3",lengh_drop(Temp_Sensor_Serial_Num_3 , val)))
    {
      strcpy(Temp_Sensor_Serial_Num_3, val);
      return true;
    }

    break;
  case 10:
    if (micro_request_ok("(G4",lengh_drop(Temp_Sensor_Serial_Num_4 , val)))
    {
      strcpy(Temp_Sensor_Serial_Num_4, val);
      return true;
    }
    break;
  case 11:
    if (micro_request_ok("(G5",lengh_drop(Temp_Sensor_Serial_Num_5 , val)))
    {
      strcpy(Temp_Sensor_Serial_Num_5, val);
      return true;
    }
    break;
  case 12:
    if (micro_request_ok("(G6",lengh_drop(Temp_Sensor_Serial_Num_6 , val)))
    {
      strcpy(Temp_Sensor_Serial_Num_6, val);
      return true;
    }

    break;
  case 13:
    if (micro_request_ok("(G7",lengh_drop( Temp_Sensor_Serial_Num_7, val)))
    {
      strcpy(Temp_Sensor_Serial_Num_7, val);
      return true;
    }

    break;
  case 14:
    if (micro_request_ok("(G8",lengh_drop(Temp_Sensor_Serial_Num_8 , val)))
    {
      strcpy(Temp_Sensor_Serial_Num_8, val);
      return true;
    }
    break;
  case 15:
    if (micro_request_ok("G9",lengh_drop( Temp_Sensor_Serial_Num_9, val)))
    {
      strcpy(Temp_Sensor_Serial_Num_9, val);
      return true;
    }

    break;
  case 16:
    if (micro_request_ok("(H0",lengh_drop( Mobile_Name_0, val)))
    {
      strcpy(Mobile_Name_0, val);
      return true;
    }
    break;
  case 17:
    if (micro_request_ok("(H1",lengh_drop(Mobile_Name_1 , val)))
    {
      strcpy(Mobile_Name_1, val);
      return true;
    }
    break;
  case 18:
    if (micro_request_ok("(H2",lengh_drop(Mobile_Name_2 , val)))
    {
      strcpy(Mobile_Name_2, val);
      return true;
    }
    break;
  case 19:
    if (micro_request_ok("(H3",lengh_drop(Mobile_Name_3 , val)))
    {
      strcpy(Mobile_Name_3, val);
      return true;
    }
    break;
  case 20:
    if (micro_request_ok("(H4",lengh_drop(Mobile_Name_4 , val)))
    {
      strcpy(Mobile_Name_4, val);
      return true;
    }
    break;
  case 21:
    if (micro_request_ok("H5",lengh_drop( Mobile_Name_5, val)))
    {
      strcpy(Mobile_Name_5, val);
      return true;
    }
    break;
  case 22:
    strcpy(Mobile_Model_0, val);
    break;
  case 23:
    strcpy(Mobile_Model_1, val);
    break;
  case 24:
    strcpy(Mobile_Model_2, val);
    break;
  case 25:
    strcpy(Mobile_Model_3, val);
    break;
  case 26:
    strcpy(Mobile_Model_4, val);
    break;
  case 27:
    strcpy(Mobile_Model_5, val);
    break;
  case 28:
    strcpy(Mobile_IMEI_0, val);
    break;
  case 29:
    strcpy(Mobile_IMEI_1, val);
    break;
  case 30:
    strcpy(Mobile_IMEI_2, val);
    break;
  case 31:
    strcpy(Mobile_IMEI_3, val);
    break;
  case 32:
    strcpy(Mobile_IMEI_4, val);
    break;
  case 33:
    strcpy(Mobile_IMEI_5, val);
    break;
  case 34:
    strcpy(Elevation, val); //invalid set
    break;
  case 35:
    strcpy(Pressure, val); //invalid set
    break;
  case 36:
    strcpy(Pressure_change, val); //invalid set
    break;
  case 37:
    if (micro_request_ok("(N",lengh_drop(Min_Valid_Output_Fan_Speed , val)))
    {
      strcpy(Min_Valid_Output_Fan_Speed, val);
      return true;
    }
    break;
  case 38:
    if (micro_request_ok("(O",lengh_drop( Max_Valid_Output_Fan_Speed, val)))
    {
      strcpy(Max_Valid_Output_Fan_Speed, val);
      return true;
    }
    break;
  case 39:
    strcpy(Real_Output_Fan_Power, val); //invalid set
    break;
  case 40:
    strcpy(Output_Fan_Available_Flag, val); //invalid set
    break;
  case 41:
    if (micro_request_ok("(R",lengh_drop(Min_Valid_Input_Fan_Speed_Day , val)))
    {
      strcpy(Min_Valid_Input_Fan_Speed_Day, val);
      return true;
    }
    break;
  case 42:
    if (micro_request_ok("(S",lengh_drop( Min_Valid_Input_Fan_Speed_Night, val)))
    {
      strcpy(Min_Valid_Input_Fan_Speed_Night, val);
      return true;
    }
    break;
  case 43:
    if (micro_request_ok("(T",lengh_drop( Max_Valid_Input_Fan_Speed_Day, val)))
    {
      strcpy(Max_Valid_Input_Fan_Speed_Day, val);
      return true;
    }
    break;
  case 44:
    if (micro_request_ok("@A",lengh_drop(Max_Valid_Input_Fan_Speed_Night , val)))
    {
      strcpy(Max_Valid_Input_Fan_Speed_Night, val);
      return true;
    }
    break;
  case 45:
    strcpy(Input_Fan_Power, val); //invalid set
    break;
  case 46:
    strcpy(Input_Fan_Available_Flag, val); //invalid set
    break;
  case 47:
    if (micro_request_ok("@D",lengh_drop(Favourite_Room_Temp_Day_ , val))) //alamat dar
    {
      strcpy(Favourite_Room_Temp_Day_, val);
      return true;
    }
    break;
  case 48:
    if (micro_request_ok("@E",lengh_drop( Room_Temp_Sensitivity_Day, val))) //float
    {
      strcpy(Room_Temp_Sensitivity_Day, val);
      return true;
    }
    break;
  case 49:
    if (micro_request_ok("@F",lengh_drop(Cooler_Start_Temp_Day , val))) //alamat dar
    {
      strcpy(Cooler_Start_Temp_Day, val);
      return true;
    }
    break;
  case 50:
    if (micro_request_ok("@G",lengh_drop(Cooler_Stop_Temp_Day , val))) //alamat dar
    {
      strcpy(Cooler_Stop_Temp_Day, val);
      return true;
    }
    break;
  case 51:
    if (micro_request_ok("@H",lengh_drop( Heater_Start_Temp_Day, val))) //alamat dar
    {
      strcpy(Heater_Start_Temp_Day, val);
      return true;
    }
    break;
  case 52:
    if (micro_request_ok("@I",lengh_drop(Heater_Stop_Temp_Day , val))) //alamat dar
    {
      strcpy(Heater_Stop_Temp_Day, val);
      return true;
    }
    break;
  case 53:
    if (micro_request_ok("@J",lengh_drop( Favourite_Room_Temp_Night, val))) //alamat dar
    {
      strcpy(Favourite_Room_Temp_Night, val);
      return true;
    }
    break;
  case 54:
    if (micro_request_ok("@K",lengh_drop( Room_Temp_Sensitivity_Night, val))) //float
    {
      strcpy(Room_Temp_Sensitivity_Night, val);
      return true;
    }
    break;
  case 55:
    if (micro_request_ok("@L",lengh_drop( Cooler_Start_Temp_Night, val))) //alamat dar
    {
      strcpy(Cooler_Start_Temp_Night, val);
      return true;
    }
    break;
  case 56:
    if (micro_request_ok("@M",lengh_drop( Cooler_Stop_Temp_Night, val))) //alamat dar
    {
      strcpy(Cooler_Stop_Temp_Night, val);
      return true;
    }
    break;
  case 57:
    if (micro_request_ok("@N",lengh_drop(Heater_Start_Temp_Night , val))) //alamat dar
    {
      strcpy(Heater_Start_Temp_Night, val);
      return true;
    }
    break;
  case 58:
    if (micro_request_ok("@O",lengh_drop( Heater_Stop_Temp_Night, val))) //alamat dar
    {
      strcpy(Heater_Stop_Temp_Night, val);
      return true;
    }
    break;
  case 59:
    if (micro_request_ok("@P",lengh_drop( Humidity_Controller, val)))
    {
      strcpy(Humidity_Controller, val);
      return true;
    }
    break;
  case 60:
    if (micro_request_ok("@Q",lengh_drop( Max_Day_Humidity, val)))
    {
      strcpy(Max_Day_Humidity, val);
      return true;
    }
    break;
  case 61:
    if (micro_request_ok("@R",lengh_drop(Min_Day_Humidity , val)))
    {
      strcpy(Min_Day_Humidity, val);
      return true;
    }
    break;
  case 62:
    if (micro_request_ok("@S",lengh_drop( Max_Night_Humidity, val)))
    {
      strcpy(Max_Night_Humidity, val);
      return true;
    }
    break;
  case 63:
    if (micro_request_ok("@T",lengh_drop(Min_Night_Humidity , val)))
    {
      strcpy(Min_Night_Humidity, val);
      return true;
    }
    break;
  case 64:
    if (micro_request_ok("$A",lengh_drop(IAQ_Flag , val)))
    {
      strcpy(IAQ_Flag, val);
      return true;
    }
    break;
  case 65:
    if (micro_request_ok("$B",lengh_drop(Max_Day_IAQ , val)))
    {
      strcpy(Max_Day_IAQ, val);
      return true;
    }
    break;
  case 66:
    if (micro_request_ok("$C",lengh_drop(Min_Day_IAQ , val)))
    {
      strcpy(Min_Day_IAQ, val);
      return true;
    }
    break;
  case 67:
    if (micro_request_ok("$D",lengh_drop( Max_Night_IAQ, val)))
    {
      strcpy(Max_Night_IAQ, val);
      return true;
    }
    break;
  case 68:
    if (micro_request_ok("$E",lengh_drop( Min_Night_IAQ, val)))
    {
      strcpy(Min_Night_IAQ, val);
      return true;
    }
    break;
  case 69:
    if (micro_request_ok("$F",lengh_drop(Min_Night_IAQ , val)))
    {
      strcpy(Min_Night_IAQ, val);
      return true;
    }
    break;
  case 70:
    if (micro_request_ok("$G",lengh_drop(Max_Day_CO2 , val)))
    {
      strcpy(Max_Day_CO2, val);
      return true;
    }
    break;
  case 71:
    if (micro_request_ok("$H",lengh_drop( Min_Day_CO2, val)))
    {
      strcpy(Min_Day_CO2, val);
      return true;
    }
    break;
  case 72:
    if (micro_request_ok("$I",lengh_drop( Max_Night_CO2, val)))
    {
      strcpy(Max_Night_CO2, val);
      return true;
    }
    break;
  case 73:
    if (micro_request_ok("$J",lengh_drop(Min_Night_CO2 , val)))
    {
      strcpy(Min_Night_CO2, val);
      return true;
    }
    break;
  case 74:
    if (micro_request_ok("$K",lengh_drop(Min_Day_Lux , val)))
    {
      strcpy(Min_Day_Lux, val);
      return true;
    }
    break;
  case 75:
    if (micro_request_ok("$L",lengh_drop( Max_Night_Lux, val)))
    {
      strcpy(Max_Night_Lux, val);
      return true;
    }
    break;
  case 76:
    if (micro_request_ok("$M",lengh_drop(License_Type , val)))
    {
      strcpy(License_Type, val);
      return true;
    }
    break;
  case 77:
    if (micro_request_ok("$N",lengh_drop(Increase_Fan_Power_License , val)))
    {
      strcpy(Increase_Fan_Power_License, val);
      return true;
    }
    break;
  case 78:
    if (micro_request_ok("$O",lengh_drop( Increase_Connected_Mobile_License, val)))
    {
      strcpy(Increase_Connected_Mobile_License, val);
      return true;
    }
    break;
  case 79:
    strcpy(Real_Room_Temp_0, val); //invalid set
    break;
  case 80:
    strcpy(Real_Room_Temp_1, val); //invalid set
    break;
  case 81:
    strcpy(Real_Room_Temp_2, val); //invalid set
    break;
  case 82:
    strcpy(Real_Room_Temp_3, val); //invalid set
    break;
  case 83:
    strcpy(Real_Room_Temp_4, val); //invalid set
    break;
  case 84:
    strcpy(Real_Room_Temp_5, val); //invalid set
    break;
  case 85:
    strcpy(Real_Room_Temp_6, val); //invalid set
    break;
  case 86:
    strcpy(Real_Room_Temp_7, val); //invalid set
    break;
  case 87:
    strcpy(Real_Room_Temp_8, val); //invalid set
    break;
  case 88:
    strcpy(Real_Room_Temp_9, val); //invalid set
    break;
  case 89:
    strcpy(Real_Outdoor_Temp, val); //invalid set
    break;
  case 90:
    strcpy(Real_Negative_Pressure_, val); //invalid set
    break;
  case 91:
    strcpy(Real_Humidity, val); //invalid set
    break;
  case 92:
    strcpy(Real_IAQ, val); //invalid set
    break;
  case 93:
    strcpy(Real_CO2, val); //invalid set
    break;
  case 94:
    strcpy(Real_Light_Level, val); //invalid set
    break;
  case 95:
    strcpy(Real_Input_Fan_Speed, val); //invalid set
    break;
  case 96:
    strcpy(Real_Output_Fan_Speed, val); //invalid set
    break;
  case 97:
    strcpy(Cooler_Status, val); //invalid set
    break;
  case 98:
    strcpy(Heater_Status, val); //invalid set
    break;
  case 99:
    strcpy(Air_Purifier_Status, val); //invalid set
    break;
  case 100:
    strcpy(Humidity_Controller_Status, val); //invalid set
    break;
  case 101:
    if (micro_request_ok("&I0",lengh_drop(Mobile_Number_0, val)))
    {
      strcpy(Mobile_Number_0, val);
      return true;
    }
    break;
  case 102:
    if (micro_request_ok("&I1",lengh_drop( Mobile_Number_1, val)))
    {
      strcpy(Mobile_Number_1, val);
      return true;
    }
    break;
  case 103:
    if (micro_request_ok("&I2",lengh_drop( Mobile_Number_2, val)))
    {
      strcpy(Mobile_Number_2, val);
      return true;
    }
    break;
  case 104:
    if (micro_request_ok("&I3",lengh_drop( Mobile_Number_3, val)))
    {
      strcpy(Mobile_Number_3, val);
      return true;
    }
    break;
  case 105:
    if (micro_request_ok("&I4",lengh_drop(Mobile_Number_4 , val)))
    {
      strcpy(Mobile_Number_4, val);
      return true;
    }
    break;
  case 106:
    if (micro_request_ok("&I5",lengh_drop(Mobile_Number_5 , val)))
    {
      strcpy(Mobile_Number_5, val);
      return true;
    }
    break;
  case 107:
    strcpy(GSM_Signal_Power, val); //invalid set
    break;
  case 108:
    if (micro_request_ok("&K",lengh_drop( GSM_SIM_Number, val)))
    {
      strcpy(GSM_SIM_Number, val);
      return true;
    }
    break;
  case 109:
    strcpy(GSM_SIM_Balance, val); //invalid set
    break;
  case 110:
    if (micro_request_ok("&M",lengh_drop( SMS_Priorities_State, val)))
    {
      strcpy(SMS_Priorities_State, val);
      return true;
    }
    break;
  case 111:
    if (micro_request_ok("&N",lengh_drop(Access_To_Internet_State , val)))
    {
      strcpy(Access_To_Internet_State, val);
      return true;
    }
    break;
  case 112:
    if (micro_request_ok("&O",lengh_drop(Cooler_Controller_Day_Mode , val)))
    {
      strcpy(Cooler_Controller_Day_Mode, val);
      return true;
    }
    break;
  case 113:
    if (micro_request_ok("&P",lengh_drop( Cooler_Controller_Night_Mod, val)))
    {
      strcpy(Cooler_Controller_Night_Mod, val);
      return true;
    }
    break;
  case 114:
    if (micro_request_ok("&Q",lengh_drop(Heater_Controller_Day_Mode , val)))
    {
      strcpy(Heater_Controller_Day_Mode, val);
      return true;
    }
    break;
  case 115:
    if (micro_request_ok("&R",lengh_drop(Heater_Controller_Night_Mode , val)))
    {
      strcpy(Heater_Controller_Night_Mode, val);
      return true;
    }
    break;
  case 116:
    if (micro_request_ok("&S",lengh_drop( Humidity_Controller_Day_Mode, val)))
    {
      strcpy(Humidity_Controller_Day_Mode, val);
      return true;
    }
    break;
  case 117:
    if (micro_request_ok("&T",lengh_drop(Humidity_Controller_Night_Mode , val)))
    {
      strcpy(Humidity_Controller_Night_Mode, val);
      return true;
    }
    break;
  case 118:
    if (micro_request_ok("&U",lengh_drop( Air_Purifier_Controller_Day_Mode, val)))
    {
      strcpy(Air_Purifier_Controller_Day_Mode, val);
      return true;
    }
    break;
  case 119:
    if (micro_request_ok("&V",lengh_drop(Air_Purifier_Controller_Night_Mode , val)))
    {
      strcpy(Air_Purifier_Controller_Night_Mode, val);
      return true;
    }
    break;
  case 121:
    // if (micro_request_ok("&",lengh_drop( , val)))
    //   {
    strcpy(device_initialized, val);
    return true;
    //   }
    break;

  default:
    break;
  }
  return false;
}
int subtrack_id(char *enitrepacket)
{
  int counter = 0;
  while (1)
  {
    if (enitrepacket[counter] == '/')
    {
      //end
      incoming_id[counter] = 0;
      break;
    }
    incoming_id[counter] = enitrepacket[counter];

    counter++;
  }
  return counter;
}

void loop()
{

  // if there's data available, read a packet
  int packetSize = Udp.parsePacket();

  if (packetSize)
  {
    //    Serial.printf("Received packet of size %d from %s:%d\n    (to %s:%d, free heap = %d B)\n",
    //                  packetSize,
    //                  Udp.remoteIP().toString().c_str(), Udp.remotePort(),
    //                  Udp.destinationIP().toString().c_str(), Udp.localPort(),
    //                  ESP.getFreeHeap()); ee09e6d0-ad74-11eb-9a7b-495ebcf498fd/NASIM_SERVER_DISCOVER

    // read the packet into packetBufffer
    int n = Udp.read(packetBuffer, UDP_TX_PACKET_MAX_SIZE);
    packetBuffer[n] = 0;
    char *packet_data = packetBuffer + subtrack_id(packetBuffer) + 1;

    if (strcmp(packet_data, "_DISCOVER") == 0)
    {
      //if we dont have it already
      // bool already_exist = false;
      // for (int i = 0; i < MAX_TARGETS_COUTN; i++)
      // {
      //   if (strcmp(targets_ip[i], Udp.remoteIP().toString().c_str()) == 0)
      //   {
      //     already_exist = true;
      //   }
      // }
      // if (!already_exist)
      // {
      //add it to list
      // strcpy(targets_ip[last_target_index], Udp.remoteIP().toString().c_str());
      // last_target_index++;
      // }

      //answering it
      send(DiscoverBuffer);
      return;
    }

    if (strcmp(packet_data, "_PING") == 0)
    {
      send("reply");
      return;
    }
    if (iterate_cmp("get", packet_data))
    {
      int number = atoi(&packet_data[3]);
      process_get_request(number);
    }
    if (iterate_cmp("set", packet_data))
    {
      char number_table[] = "000";
      number_table[0] = packet_data[3];
      number_table[1] = packet_data[4];
      number_table[2] = packet_data[5];

      int number = atoi(number_table);
      Serial.printf("set %d to %s => ", number, &packet_data[7]);

      send(process_set_request(number, &packet_data[7]));
      // send("OK");
      return;
    }

    // else
    // {
    //   //if we have registered this client, we answer
    //   bool already_exist = false;

    //   for (int i = 0; i < last_target_index; i++)
    //   {
    //     if (strcmp(targets_ip[i], Udp.remoteIP().toString().c_str()) == 0)
    //     {

    //       already_exist = true;
    //     }
    //   }
    //   if (already_exist)
    //   {
    //     Serial.write(packet_data, n);
    //   }
    // }
    //check UART for data
    //    {
    //            size_t len = (size_t)Serial.available();
    //            if (len) {
    //              uint8_t sbuf[len];
    //              size_t serial_got = Serial.readBytes(sbuf, len);
    //              // push UART data to all connected telnet clients
    //              for (int i = 0; i < last_target_index; i++)
    //              {
    //              Udp.beginPacket(targets_ip[i], 9315);
    //              Udp.write(sbuf,serial_got);
    //              Udp.endPacket();
    //              }
    //
    //
    //          }
    //    }
    //    Serial.println("Contents:");
    //    Serial.println(packetBuffer);
    //
    //    // send a reply, to the IP address and port that sent us the packet we received
    //    Udp.beginPacket(Udp.remoteIP(), Udp.remotePort());
    //    Udp.write(ReplyBuffer);
    //    Udp.endPacket();
  }
}
