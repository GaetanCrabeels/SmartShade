#ifndef LIGHT_SENSOR_H
#define LIGHT_SENSOR_H

#include <Arduino.h>
#include "FirebaseHandler.h"

class LightSensor {
public:
    LightSensor(int ldrPin, int pirPin, FirebaseData &fbdo);
    void readData();
    void sendDataToFirebase(const String &path);
    int getLDRValue() const;
    int getPIRState() const;

private:
    int ldrPin;
    int pirPin;
    int ldrValue;
    int pirState;
    FirebaseData *fbdo;
};

#endif
