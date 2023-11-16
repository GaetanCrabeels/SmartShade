#ifndef FirebaseHandler_h
#define FirebaseHandler_h

#include <FirebaseArduino.h>

extern const char* FIREBASE_HOST;
extern const char* FIREBASE_AUTH;

void setupFirebase();
void handleFirebaseData();

#endif