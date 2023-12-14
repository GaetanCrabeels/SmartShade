import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/screens/user_page.dart';

void main() {
  testWidgets('UserPage Widget Test', (WidgetTester tester) async {
    // Initialize Firebase
    await Firebase.initializeApp();

    // Create a fake instance of FirebaseFirestore
    final firestore = FakeFirebaseFirestore();

    // Set up initial data in Firestore
    await firestore.collection('users').doc('test_user').set({
      'houseId': 'house_id_1',
    });

    firestore.collection('houses').doc('house_id_1').set({
      'shutter_temperature_delta': 0,
    });

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: UserPage(user_name: 'test_user', firestore: firestore),
      ),
    );

    // Wait for the widget to settle.
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verify that UserPage is displayed
    expect(find.byType(UserPage), findsOneWidget);

    // You can add more specific verifications based on your UI structure
    expect(find.text('User Page'), findsOneWidget);
    expect(find.text('Activation du mode de différence de temperature :'),
        findsOneWidget);
    expect(find.text('Choix de l\'heure :'), findsOneWidget);
  });
}
