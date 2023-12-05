import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Utilisateur'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Page de profil de l\'utilisateur'),
            FutureBuilder<User?>(
              future: FirebaseAuth.instance.authStateChanges().first,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Erreur lors de la récupération de l\'utilisateur');
                } else if (snapshot.hasData) {
                  final User user = snapshot.data!;
                  return Column(
                    children: [
                      Text('UID de l\'utilisateur : ${user.uid}'),
                      ElevatedButton(
                        onPressed: () {
                          _showDeleteUserDialog(context);
                        },
                        child: Text('Supprimer le compte'),
                      ),
                    ],
                  );
                } else {
                  return const Text('Utilisateur non connecté');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Êtes-vous sûr de vouloir supprimer votre compte utilisateur ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                await _deleteCurrentUser(context);
              },
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCurrentUser(BuildContext context) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      try {
        // Déconnectez l'utilisateur
        await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).delete();

        await FirebaseAuth.instance.signOut();

        // Redirigez l'utilisateur vers l'écran de connexion
        Navigator.pushReplacementNamed(context, '/login');

      } catch (e) {
        print('Erreur lors de la déconnexion de l\'utilisateur : $e');
        // Gérer l'erreur, par exemple, afficher un message à l'utilisateur
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la déconnexion de l\'utilisateur'),
          ),
        );
      }
    }
  }
}
