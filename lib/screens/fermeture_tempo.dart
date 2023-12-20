import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FermetureTempoScreen extends StatelessWidget {
  const FermetureTempoScreen({Key? key}) : super(key: key);

//Methode asynchrone qui envoie commande a firestore
  Future<void> sendCommand(int command) async {
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

//methode qui crée une page avec 2 bouton, activé et désactivé
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Option capteurs de luminosité'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                sendCommand(1);
              },
              child: const Text('Activer les capteurs de luminosité'),
            ),
            ElevatedButton(
              onPressed: () {
                sendCommand(0);
              },
              child: const Text('Désactiver les capteurs de luminosité'),
            ),
          ],
        ),
      ),
    );
  }
}
