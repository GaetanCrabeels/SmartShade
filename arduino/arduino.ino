#include <DHT.h>
#include "FirebaseHandler.h"
#include "WifiConfig.h"

  #define DHTPIN 8  // Broche à laquelle est connecté le capteur DHT11
  #define DHTTYPE DHT11  // Type de capteur (DHT11 pour le DHT11)

  int ldrPin = A1;  // Broche analogique pour la photorésistance LDR
  int pirPin = 3;   // Broche digitale pour le capteur PIR SR505

  DHT dht(DHTPIN, DHTTYPE);

  void setup() {
    pinMode(pirPin, INPUT); // Configurez la broche du capteur PIR comme une entrée
    Serial.begin(9600);    // Initialisez la communication série
  }

  void loop() {
    // Lecture de la valeur analogique de la LDR
    int ldrValue = analogRead(ldrPin);

    // Lecture de l'état du capteur PIR
    int motion = digitalRead(pirPin);

    // Lecture de l'humidité et de la température du DHT11
    float humidity = dht.readHumidity();
    float temperature = dht.readTemperature();

    // Affichage des données
    Serial.print("Luminosité (LDR) : ");
    Serial.println(ldrValue);

    if (motion == HIGH) {
      Serial.println("Mouvement détecté (PIR) !");
    } else {
      Serial.println("Aucun mouvement détecté (PIR).");
    }

    Serial.print("Humidité : ");
    Serial.print(humidity);
    Serial.print(" %\t");
    Serial.print("Température : ");
    Serial.print(temperature);
    Serial.println(" °C");

    delay(3000); // Attendez une seconde avant de vérifier à nouveau
  }