import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/utils/password_utils.dart';
import 'package:flutter_application_1/widgets/bottom_navigation_bar.dart';
import 'package:flutter_application_1/widgets/reusable.dart';
import 'sign_up.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key});

  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  Future<void> _signInWithEmailAndPassword(BuildContext context) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _emailTextController.text)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final DocumentSnapshot userSnapshot = querySnapshot.docs.first;

        final String storedSalt = userSnapshot['salt'];
        final String storedHashedPassword = userSnapshot['Password'];

        final String hashedPassword =
            await hashPassword(_passwordTextController.text, storedSalt);

        if (hashedPassword == storedHashedPassword) {
          final UserCredential userCredential =
              await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailTextController.text.trim(),
            password: hashedPassword,
          );
          User? user = userCredential.user;

          Future.delayed(const Duration(seconds: 1), () {
            Navigator.of(context).pushReplacement<void, dynamic>(
              MaterialPageRoute(
                  builder: (context) => const BottomNavigationBarWidget()),
            );
          });
        } else {
          // Passwords do not match
          displayErrorMessage(context, 'Mot de passe incorrect.');
        }
      } else {
        // User not found in Firestore
        displayErrorMessage(
            context, 'Aucun utilisateur trouvé avec cette adresse e-mail.');
      }
    } catch (e) {
      print('Error : $e');
      // Handle other authentication errors
      displayErrorMessage(context, e);
    }
  }

  void displayErrorMessage(BuildContext context, dynamic e) {
    String errorMessage = 'Erreur de connexion';
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Aucun utilisateur trouvé avec cette adresse e-mail.';
          break;
        case 'wrong-password':
          errorMessage = 'Mot de passe incorrect.';
          break;
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        duration: const Duration(seconds: 3),
      ),
    );

    print('Email: $_emailTextController, Password: $_passwordTextController');

    // Affiche l'erreur dans la console
    print('Erreur de connexion : $e');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            reusableTextField("Enter Email ID", Icons.email_outlined, false,
                _emailTextController, context),
            const SizedBox(
              height: 20,
            ),
            reusableTextField("Enter Password", Icons.lock_outline, true,
                _passwordTextController, context),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Appeler la fonction de connexion avec les informations de l'utilisateur
                _signInWithEmailAndPassword(context);
              },
              child: const Text('Se connecter'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Naviguer vers la page d'inscription (sign_up.dart)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUp()),
                );
              },
              child: const Text("Pas encore inscrit ? S'inscrire"),
            ),
          ],
        ),
      ),
    );
  }
}
