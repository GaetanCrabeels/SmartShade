#ifndef ApiHandler_h
#define ApiHandler_h

#include <ArduinoJson.h>
#include <ESP8266WiFi.h>
#include <WiFiClientSecureBearSSL.h>

const char* apiKey = "253bb380830eb71192fdb2d3af85f23849fb7e7e"; //Api token
const char* apiUrl = "https://agromet.be/fr/agromet/api/v3/get_pameseb_hourly_prev/tsa";

String fetchDataFromAPI();

#endif
