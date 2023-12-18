import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/bottom_navigation_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/main.dart'; // Import your app's main.dart file
import 'package:flutter_application_1/screens/user_page.dart';

void main() {
  late MockGoogleSignIn googleSignIn;

  setUp(() {
    googleSignIn = MockGoogleSignIn();
  });

  Future<void> setupFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }

  testWidgets('UserPage Widget Test', (WidgetTester tester) async {
    await setupFirebase();

    // Mock data and dependencies
    final firestore = FakeFirebaseFirestore();
    final signInAccount = await googleSignIn.signIn();
    final signInAuthentication = await signInAccount!.authentication;

    await firestore.collection('users').doc('test_user').set({
      'houseId': 'house_id_1',
    });

    firestore.collection('houses').doc('house_id_1').set({
      'shutter_temperature_delta': 0,
    });

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home:
            BottomNavigationBarWidget(), // Make sure this widget leads to UserPage
        routes: {
          '/user': (context) =>
              UserPage(user_name: 'test_user', firestore: firestore),
        },
      ),
    );

    // Wait for the navigation animation to complete.
    await tester.pumpAndSettle();

    // Verify that UserPage is not yet displayed
    expect(find.byType(UserPage), findsNothing);

    // Tap on the user icon in the bottom navigation bar to navigate to UserPage
    await tester.tap(find.bySemanticsLabel('Utilisateur'));
    await tester.pumpAndSettle();

    // Verify that UserPage is displayed
    expect(find.byType(UserPage), findsOneWidget);
  });
}
