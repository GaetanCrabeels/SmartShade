import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FermetureTempoScreen extends StatelessWidget {
  const FermetureTempoScreen({Key? key}) : super(key: key);

  Future<void> sendCommand(String command) async {
    try {
      await FirebaseFirestore.instance
          .collection('commandeCapteurs')
          .doc('etat')
          .set({'valeur': command});
      print('Commande envoyée avec succès');
    } catch (e) {
      print('Erreur : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fermeture Temporaire'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                sendCommand('1');
              },
              child: const Text('Activer les capteurs de luminosité'),
            ),
            ElevatedButton(
              onPressed: () {
                sendCommand('0');
              },
              child: const Text('Désactiver les capteurs de luminosité'),
            ),
          ],
        ),
      ),
    );
  }
}
