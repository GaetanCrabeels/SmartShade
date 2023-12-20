#include <DHT.h>
#include "FirebaseHandler.h"
#include "WifiConfig.h"
#include "LightSensor.h"

#define DHTPIN 8  // Broche à laquelle est connecté le capteur DHT11
#define DHTTYPE DHT11  // Type de capteur (DHT11 pour le DHT11)
#define LDR_PIN A1  // Broche analogique pour la photorésistance LDR
#define PIR_PIN 3   // Broche digitale pour le capteur PIR SR505

DHT dht(DHTPIN, DHTTYPE);
FirebaseData fbdo;
LightSensor lightSensor(LDR_PIN, PIR_PIN, fbdo);

void setup() {
  Serial.begin(9600);
  connectWiFi();
}

void loop() {
  lightSensor.readData();

  // Affichage des données
  Serial.print("Luminosité (LDR) : ");
  Serial.println(lightSensor.getLDRValue());

  if (lightSensor.getPIRState() == HIGH) {
    Serial.println("Mouvement détecté (PIR) !");
  } else {
    Serial.println("Aucun mouvement détecté (PIR).");
  }

  // Lecture de l'humidité et de la température du DHT11
  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();

  Serial.print("Humidité : ");
  Serial.print(humidity);
  Serial.print(" %\t");
  Serial.print("Température : ");
  Serial.print(temperature);
  Serial.println(" °C");

  // Envoi des données à Firebase
  String firebasePath = "sensor_data/light_sensor";
  lightSensor.sendDataToFirebase(firebasePath);

  delay(3000); // Attendez une seconde avant de vérifier à nouveau
}
