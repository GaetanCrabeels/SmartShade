import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/screens/user_page.dart';
import 'package:flutter_application_1/widgets/bottom_navigation_bar.dart';

void main() {
  late MockGoogleSignIn googleSignIn;

  setUp(() {
    googleSignIn = MockGoogleSignIn();
  });

  Future<void> setupFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }

  test('should return idToken and accessToken when authenticating', () async {
    final signInAccount = await googleSignIn.signIn();
    final signInAuthentication = await signInAccount!.authentication;

    expect(signInAuthentication, isNotNull);
    expect(googleSignIn.currentUser, isNotNull);
    expect(signInAuthentication.accessToken, isNotNull);
    expect(signInAuthentication.idToken, isNotNull);

    print('Authentication successful: '
        'idToken=${signInAuthentication.idToken}, '
        'accessToken=${signInAuthentication.accessToken}');
  });

  testWidgets('shows user page', (WidgetTester tester) async {
    await setupFirebase();

    final firestore = FakeFirebaseFirestore();
    final signInAccount = await googleSignIn.signIn();
    final signInAuthentication = await signInAccount!.authentication;

    await firestore.collection('users').doc('test_user').set({
      'houseId': 'house_id_1',
    });

    firestore.collection('houses').doc('house_id_1').set({
      'shutter_temperature_delta': 0,
    });

    await tester.pumpWidget(
      MaterialApp(
        title: 'Mon App Flutter',
        home: BottomNavigationBarWidget(),
        routes: {
          '/user': (context) =>
              UserPage(user_name: 'test_user', firestore: firestore),
        },
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(BottomNavigationBarWidget), findsOneWidget);

    // Tap on the user icon in the bottom navigation bar to navigate to UserPage
    await tester.tap(find.bySemanticsLabel('Utilisateur'));
    await tester.pumpAndSettle(const Duration(minutes: 15));

    // Verify that UserPage is displayed
    expect(find.byType(UserPage), findsOneWidget);

    print('UserPage is displayed successfully');
  });
}
