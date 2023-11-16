#include "ApiHandler.h"

void fetchApiData() {
  WiFiClientSecure client;
  if (client.connect("agromet.be", 443)) {
    client.println("GET " + String(apiUrl) + " HTTPS/1.1");
    client.println("Host: agromet.be");
    client.println("Authorization: Bearer " + apiKey);
    client.println("Connection: close");
    client.println();

    while (client.connected()) {
      String line = client.readStringUntil('\n');
      if (line == "\r") {
        break;
      }
    }

    // Read and print the response
    while (client.available()) {
      String line = client.readStringUntil('\n');
      Serial.println(line);
    }

    client.stop();
  } else {
    Serial.println("Failed to connect to the API");
  }
}