#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <ArduinoJson.h>
#include <ESP8266HTTPClient.h>


#include <Servo.h>
#include <FB_Const.h>
#include <addons/TokenHelper.h>

const char *WIFI_SSID = "Gaga";
const char *WIFI_PASSWORD = "test123test";
const char *API_KEY = "AIzaSyDrAgeU7vAdLCipQh9IE4zLoaMAfoygAqs";
const char *FIREBASE_PROJECT_ID = "smartshade-8442c";
const char *USER_EMAIL = "gaetan0crabeels@gmail.com";
const char *USER_PASSWORD = "pongo1962";
#define SHUTTER_ID "shutter_id_1"
#define HOUSE_ID "house_id_1"
String documentPath = "shutters/"+String(SHUTTER_ID);
String documentPathDelta = "houses/"+String(HOUSE_ID);
const int lightThreshold = 500;  // Valeur seuil pour déclencher une action (ajustez selon vos besoins)


FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
Servo monServo;

void connectWiFi() {
  Serial.println("Connecting to WiFi...");
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  Serial.println();
  
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("Failed to connect to WiFi. Please check your credentials.");
    while (1) {
      delay(1000);
    }
  }

  Serial.println("Connected to WiFi");
}

void initializeFirebase() {
  config.api_key = API_KEY;
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;
  config.token_status_callback = tokenStatusCallback;
  Firebase.reconnectNetwork(true);
  fbdo.setBSSLBufferSize(4096, 1024);
  fbdo.setResponseSize(2048);
  Firebase.begin(&config, &auth);
}

void setup() {
  Serial.begin(115200);
  connectWiFi();
  initializeFirebase();
}
void rotateServo(int angle) {
  monServo.attach(2); // Broche de contrôle du servomoteur (ajustez selon votre configuration).
  monServo.write(angle);
  delay(500); // Attendre avant de passer à l'étape suivante (ajustez selon votre besoin).
}

void loop() {
  String mask = "";

  // Lire la valeur du booléen dans Firestore
  bool shutterOpen = false; // Initialise à false par défaut
  bool shutterMov = false;
  bool shutterDelta = false;
  String shutterOpenString = "";
  String shutterMovString = "";
  float temperature = NAN;
  float lastTsa = NAN;

  if(Firebase.Firestore.getDocument(&fbdo, FIREBASE_PROJECT_ID, "", documentPathDelta.c_str(), mask.c_str())) {
    Serial.printf("Firebase response: %s\n", fbdo.payload().c_str());

    // Analyser le JSON pour obtenir la valeur de shutter_open
    DynamicJsonDocument jsonDocument(1024);
    deserializeJson(jsonDocument, fbdo.payload());

    if (jsonDocument.containsKey("fields") && jsonDocument["fields"].containsKey("shutter_temperature_delta_bool")) {
      shutterDelta = jsonDocument["fields"]["shutter_temperature_delta_bool"]["booleanValue"];
      Serial.println(String(jsonDocument["fields"]["shutter_temperature_delta_bool"]["booleanValue"]));
    
      HttpClient http;
      String apiUrl = "https://agromet.be/fr/agromet/api/v3/get_pameseb_hourly/tsa/18/";

      char currentDate[11];
      snprintf(currentDate, sizeof(currentDate), "%04d-%02d-%02d", year(), month(), day());
      apiUrl += currentDate;
      apiUrl += "/";
      apiUrl += currentDate;
      apiUrl += "/";

      if (http.begin(apiUrl)) {
        int httpCode = http.GET();

        if(httpCode == HTTP_CODE_OK) {
          DynamicJsonDocument jsonDocumentApi(1024);
          deserializeJson(jsonDocumentApi, http.getString());

          if (jsonDocumentApi.containsKey("results")) {
          JsonArray resultsArray = jsonDocumentApi["results"].as<JsonArray>();
          if (resultsArray.size() > 0) {
            JsonObject lastResult = resultsArray[resultsArray.size() - 1];
            String lastTsa = lastResult["tsa"].as<String>();

            Serial.println("Last TSA value: " + lastTsa);
          }
        }
        http.end();
        } else {
          Serial.printf("HTTP code: %d\n", httpCode);
        }
      }

      while (isnan(temperature)) {
        temperature = dht.readTemperature();
        delay(500);
      }

      if (abs(lastTsa - temperature) > shutterDelta) {
        shutterMov = true;
      }
      else {
        shutterMov = false;
      }
    }
  }

  if (Firebase.Firestore.getDocument(&fbdo, FIREBASE_PROJECT_ID, "", documentPath.c_str(), mask.c_str())) {
    Serial.printf("Firebase response: %s\n", fbdo.payload().c_str());

    // Analyser le JSON pour obtenir la valeur de shutter_open
    DynamicJsonDocument jsonDocument(1024);
    deserializeJson(jsonDocument, fbdo.payload());



    // Vérifier si le champ shutter_open existe dans la réponse JSON
    if (jsonDocument.containsKey("fields") && jsonDocument["fields"].containsKey("shutter_open")) {
      shutterOpen = jsonDocument["fields"]["shutter_open"]["booleanValue"];
      Serial.println(String(jsonDocument["fields"]["shutter_open"]["booleanValue"]));

    }
    // Vérifier si le champ shutter_mov existe dans la réponse JSON
    if (jsonDocument.containsKey("fields") && jsonDocument["fields"].containsKey("shutter_mov")) {
      shutterMov = jsonDocument["fields"]["shutter_mov"]["booleanValue"];
      shutterMovString = String(shutterMov);
      Serial.println(String(jsonDocument["fields"]["shutter_mov"]["booleanValue"]));

    }
  }
  else {
    Serial.println("Erreur lors de la récupération du document Firebase");
    Serial.println(fbdo.errorReason());
    }

  // Contrôler le servomoteur en fonction des valeurs booléennes
  if (shutterMov) {
    Serial.println(shutterOpenString);
    Serial.println(shutterMovString);

    rotateServo(shutterOpen ? 180 : 0);
  }
  else {
    monServo.detach();
  }

  delay(1000); // Attendre une seconde (ajustez selon votre besoin).
}
