import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/reusable.dart';
import 'package:flutter_application_1/widgets/bottom_navigation_bar.dart';
import 'package:flutter_application_1/utils/password_utils.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _userNameTextController = TextEditingController();

  String? _houseId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Sign Up'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            reusableTextField("Enter Username", Icons.person_outline, false,
                _userNameTextController, context),
            const SizedBox(
              height: 20,
            ),
            reusableTextField("Enter Email ID", Icons.email_outlined, false,
                _emailTextController, context),
            const SizedBox(
              height: 20,
            ),
            reusableTextField("Enter Password", Icons.lock_outline, true,
                _passwordTextController, context),
            const SizedBox(
              height: 20,
            ),
            signInsignUpButton(context, false, () async {
              try {
                final salt = generateSalt();
                final hashedPassword =
                    await hashPassword(_passwordTextController.text, salt);
                UserCredential userCredential =
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: _emailTextController.text,
                  password: hashedPassword,
                );

                final db = FirebaseFirestore.instance;
                final localContext = context; // Capturer le contexte localement

                DocumentReference houseRef = await db.collection("houses").add({
                  'house_name': 'My House',
                  'house_temperature': 20,
                  'shutter_temperature_delta_bool': false,
                  'shutter_temperature_delta': 2,
                  'shutter_hour_bool': false,
                  'shutter_hour_open': 08.00,
                  'shutter_hour_close': 20.00,
                });

                setState(() {
                  _houseId = houseRef.id;
                });

                db.collection("users").doc(userCredential.user?.uid).set({
                  'fullName': _userNameTextController.text,
                  'email': _emailTextController.text,
                  'accountCreated': FieldValue.serverTimestamp(),
                  'Password': hashedPassword,
                  'salt': salt,
                  'houseId': _houseId,
                }).onError((e, _) {
                  if (kDebugMode) {
                    print("Error writing document: $e");
                  }
                  ScaffoldMessenger.of(localContext).showSnackBar(
                    const SnackBar(
                      content: Text('Error writing document'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                });

                if (kDebugMode) {
                  print("Created New Account");
                }

                Navigator.of(localContext).pushReplacement<void, dynamic>(
                  MaterialPageRoute(
                      builder: (context) => const BottomNavigationBarWidget()),
                );
              } on FirebaseAuthException {
                if (kDebugMode) {
                  print("Error creating account");
                }
                // Gérer les erreurs d'authentification ici
              }
            }),
          ],
        ),
      ),
    );
  }
}
