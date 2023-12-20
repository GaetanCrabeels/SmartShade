#include "LightSensor.h"

LightSensor::LightSensor(int ldrPin, int pirPin, FirebaseData &fbdo) {
    this->ldrPin = ldrPin;
    this->pirPin = pirPin;
    this->fbdo = &fbdo;

    pinMode(pirPin, INPUT);
}

void LightSensor::readData() {
    // Lecture de la valeur analogique de la LDR
    ldrValue = analogRead(ldrPin);

    // Lecture de l'état du capteur PIR
    pirState = digitalRead(pirPin);
}

void LightSensor::sendDataToFirebase(const String &path) {
    // Envoi des données à Firebase
    Firebase.setFloat(*fbdo, path + "/ldr_value", ldrValue);
    Firebase.setInt(*fbdo, path + "/pir_state", pirState);
}

int LightSensor::getLDRValue() const {
    return ldrValue;
}

int LightSensor::getPIRState() const {
    return pirState;
}
