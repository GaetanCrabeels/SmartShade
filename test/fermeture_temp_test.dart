import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_application_1/screens/fermeture_tempo.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:flutter_application_1/widgets/bottom_navigation_bar.dart';
import 'package:flutter_application_1/screens/parameters.dart';

void main() {
  late MockGoogleSignIn googleSignIn;

  setUp(() {
    googleSignIn = MockGoogleSignIn();
  });

  Future<void> setupFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }

  testWidgets('FermetureTempoScreen UI Test', (WidgetTester tester) async {
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
          '/parametres': (context) => UserProfilePage(),
        },
      ),
    );

    await tester.pumpAndSettle();

    // tap sur l'icône "Parametres" dans la barre de navigation inférieure pour accéder à la page de paramètres
    await tester.tap(find.bySemanticsLabel('Parametres'));
    await tester.pumpAndSettle();

    // tap sur le bouton "Menu gestion des capteurs" pour accéder à la page FermetureTempoScreen
    await tester.tap(find.text('Menu gestion des capteurs'));
    await tester.pumpAndSettle();

    // vérifie que FermetureTempoScreen est correctement affichée
    expect(find.byType(FermetureTempoScreen), findsOneWidget);
    print('FermetureTempoScreen is displayed successfully');
  });

  test('sendCommand Test', () async {
    // configure l'état initial de la base de données
    final firestore = FakeFirebaseFirestore();
    await firestore
        .collection('commandeCapteurs')
        .doc('etat')
        .set({'valeur': 1});

    // crée une instance de FermetureTempoScreen
    final fermetureTempoScreen = FermetureTempoScreen();

    await fermetureTempoScreen.sendCommand(0);

    final querySnapshot =
        await firestore.collection('commandeCapteurs').doc('etat').get();

    // vérifie si valeur mis à jour
    expect(querySnapshot.exists, true);
    expect(querySnapshot['valeur'], 0);
    print('Captor desactivate');

    await fermetureTempoScreen.sendCommand(1);

    // vérifie si valeur mis à jour
    expect(querySnapshot.exists, true);
    expect(querySnapshot['valeur'], 1);
    print('Captor activate');
  });
}
