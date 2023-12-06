import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/utils/password_utils.dart';
import 'package:flutter_application_1/widgets/bottom_navigation_bar.dart';
import 'sign_up.dart';

// ignore: must_be_immutable
class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  String email = ''; // Variable d'état pour l'adresse e-mail
  String password = ''; // Variable d'état pour le mot de passe

  Future<void> _signInWithEmailAndPassword(BuildContext context) async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userSnapshot.exists) {
        final String storedSalt = userSnapshot['salt'];
        final String storedHashedPassword = userSnapshot['Password'];

        final String hashedPassword = await hashPassword(password, storedSalt);

        if (hashedPassword == storedHashedPassword) {
          // La connexion a réussi, vous pouvez naviguer vers la page suivante (par exemple, HomePage)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const BottomNavigationBarWidget(),
            ),
          );
        } else {
          // La connexion a échoué, vous pouvez afficher un message d'erreur ou effectuer d'autres actions
          displayErrorMessage(context, 'Mot de passe incorrect.');
        }
      }
    } catch (e) {
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
            TextField(
              onChanged: (value) {
                // Mettez à jour votre variable d'email ici
                email = value;
              },
              decoration: const InputDecoration(labelText: 'Adresse e-mail'),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) {
                // Mettez à jour votre variable de mot de passe ici
                password = value;
              },
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
            ),
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
