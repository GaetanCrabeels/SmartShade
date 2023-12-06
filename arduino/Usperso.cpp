#include <Arduino_JSON.h>

int apiTemp = 0;

void loop()
{
    float temperature = 0;  // Declare temperature outside the if block

    if (Firebase.ready() && (millis() - dataMillis > 60000 || dataMillis == 0))
    {
        dataMillis = millis();
        taskCompleted = true;
        documentCounter++;

        FirebaseJson content;

        // Lecture des données depuis le capteur DHT
        temperature = dht.readTemperature();  // Assign value to temperature

        content.set("fields/temperature/doubleValue", String(temperature));
        content.set("fields/humidity/doubleValue", String(dht.readHumidity()));

        // info is the collection id, countries is the document id in collection info.
        String documentPath = "shutters/shutter_id_1/data";

        Serial.print("Create document... ");

        if (Firebase.Firestore.createDocument(&fbdo, FIREBASE_PROJECT_ID, "" /* databaseId can be (default) or empty */, documentPath.c_str(), content.raw()))
            Serial.printf("ok\n%s\n\n", fbdo.payload().c_str());
        else
            Serial.println(fbdo.errorReason());

        // Read the shutter temperature delta from Firestore
        // info is the collection id, countries is the document id in collection info.
        String documentPathRead = "houses/house_id_1/shutter_temperature_delta";

        Serial.print("Reading document... ");

        // Use the getDocument function to read data from the specified documentPath
        if (Firebase.Firestore.getDocument(&fbdo, FIREBASE_PROJECT_ID, "" /* databaseId can be (default) or empty */, documentPathRead.c_str()))
        {
            Serial.println("ok");

            // Parse the JSON payload to extract and print the integer value
            FirebaseJsonData jsonData;
            FirebaseJson *json = &fbdo.jsonObject();

            // Extract the integer value
            if (json->get(jsonData, "fields/shutter_temperature_delta/integerValue"))
            {
                int shutterTemperatureDelta = jsonData.to<int>();
                Serial.printf("Shutter Temperature Delta: %d\n", shutterTemperatureDelta);

                // Now you can use shutterTemperatureDelta as an integer in your Arduino code
            }
        }
        else
        {
            Serial.println(fbdo.errorReason());
        }

        String apiURL = "https://agromet.be/fr/agromet/api/v3/get_pameseb_hourly/tsa/18/2023-11-26/2023-11-26/";
        String apiResponse = httpGETRequest(apiURL);

        // Parse the JSON response
        JSONVar responseObject = JSON.parse(apiResponse);

        // Check if parsing was successful
        if (JSON.typeof(responseObject) == "undefined")
        {
            Serial.println("Failed to parse JSON response from API");
        }
        else
        {
            // Extract the tsa value from the last result
            int resultCount = responseObject["results"].length();
            if (resultCount > 0)
            {
                JSONVar lastResult = responseObject["results"][resultCount - 1];
                apiTemp = lastResult["tsa"];
                Serial.printf("API Temperature: %d\n", apiTemp);
            }
            else
            {
                Serial.println("No results in the API response");
            }
        }

        int tempDifference = abs(apiTemp - static_cast<int>(temperature));
        if (tempDifference > shutterTemperatureDelta)
        {
            Serial.println("Temperature difference exceeds threshold. Taking action...");
        }
        else
        {
            Serial.println("Temperature difference is within the threshold.");
        }

        delay(2000);
    }
}

String httpGETRequest(const String &url)
{
    // Implement your HTTP GET request logic here, depending on your hardware and network setup.
    // You may use libraries like ArduinoHttpClient or other methods suitable for your board.

    // For simplicity, let's assume you have a function named performHTTPGetRequest.
    // Make sure to implement this function according to your needs.
    return performHTTPGetRequest(url);
}
