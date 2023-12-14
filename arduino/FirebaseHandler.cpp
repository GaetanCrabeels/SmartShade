#include "FirebaseHandler.h"

const char* FIREBASE_HOST = "smartshade-8442c.firebaseio.com";
const char* FIREBASE_AUTH = "KCRPqBD2hwTYlAdhjhEtKTWLOuRKX2xwTMdO5A4z";

void setupFirebase() {
  Serial.begin(9600);
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Firebase.reconnectWiFi(true);
}

void handleFirebaseData() {
  if (Firebase.getString("/house/house_id_1/shutter_temperature_delta")) {
    if (Firebase.failed()) {
      Serial.println("Failed to fetch data");
    } else {
      Serial.println(Firebase.getString());
    }
    delay(10000); // Read data every 10 seconds
  }
}
