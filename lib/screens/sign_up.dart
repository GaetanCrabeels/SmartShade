import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/reusable.dart';
import 'package:flutter_application_1/screens/home_page.dart';
import 'package:flutter_application_1/widgets/bottom_navigation_bar.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _userNameTextController = TextEditingController();

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
                UserCredential userCredential =
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: _emailTextController.text,
                  password: _passwordTextController.text,
                );

                final db = FirebaseFirestore.instance;
                final localContext = context; // Capturer le contexte localement

                db.collection("users").doc(userCredential.user?.uid).set({
                  'fullName': _userNameTextController.text,
                  'email': _emailTextController.text,
                  'accountCreated': Timestamp.now(),
                  'Password': _passwordTextController.text,
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
              } on FirebaseAuthException catch (e) {
                if (kDebugMode) {
                  print("Error creating account: $e");
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
