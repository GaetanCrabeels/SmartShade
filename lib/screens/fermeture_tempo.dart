import 'package:flutter/material.dart';

class FermetureTempoScreen extends StatefulWidget {
  const FermetureTempoScreen({Key? key}) : super(key: key);

  @override
  _FermetureTempoScreenState createState() => _FermetureTempoScreenState();
}

class _FermetureTempoScreenState extends State<FermetureTempoScreen> {
  bool _autoModeEnabled = true;

  void _toggleAutoMode() {
    // ici pour ajouter la logique pour activer/désactiver les capteurs
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
            Switch(
              value: _autoModeEnabled,
              onChanged: (value) {
                setState(() {
                  _autoModeEnabled = value;
                  _toggleAutoMode();
                });
              },
            ),
            Text(
              _autoModeEnabled
                  ? 'Mode Automatique Activé'
                  : 'Mode Automatique Désactivé',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
