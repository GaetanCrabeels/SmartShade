import 'dart:async';
import 'package:flutter/material.dart';
import 'package:light/light.dart';

class VoletControlPage extends StatefulWidget {
  const VoletControlPage({Key? key}) : super(key: key);

  @override
  _VoletControlPageState createState() => _VoletControlPageState();
}

class _VoletControlPageState extends State<VoletControlPage> {
  bool voletsFermes = false;
  bool ouvrirQuandSombre = true; // Choix par défaut : ouvrir les volets quand il fait sombre
  Light? _light;
  StreamSubscription<int>? _subscription;

  void onData(int luxValue) {
    // Utiliser luxValue pour obtenir la luminosité en lux
    double luminosite = luxValue.toDouble();

    // Définir une valeur de seuil pour déterminer s'il fait sombre ou clair
    double seuilLuminosite = 50.0;

    // Vérifier si la luminosité est inférieure au seuil pour déterminer s'il fait sombre
    bool faitSombre = luminosite < seuilLuminosite;

    // Mettre à jour l'interface utilisateur avec l'état de la luminosité
    setState(() {
      if (faitSombre) {
        voletsFermes = true; // Fermer les volets quand il fait sombre
      } else {
        voletsFermes = false; // Ouvrir les volets quand il fait clair
      }
    });
  }

  void startListening() {
    _light = Light();
    try {
      _subscription = _light?.lightSensorStream.listen(onData);
    } on LightException catch (exception) {
      print(exception);
    }
  }

  void stopListening() {
    _subscription?.cancel();
  }

  @override
  void initState() {
    super.initState();
    startListening();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contrôle des Volets'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            voletsFermes ? 'Volets fermés' : 'Volets ouverts',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: Text('Ouvrir quand il fait sombre'),
            value: ouvrirQuandSombre,
            onChanged: (value) {
              setState(() {
                ouvrirQuandSombre = value;
              });
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Exécuter l'action appropriée en fonction du choix de l'utilisateur
              if ((voletsFermes && ouvrirQuandSombre) || (!voletsFermes && !ouvrirQuandSombre)) {
                // Action à effectuer lorsque les volets sont fermés et on choisit d'ouvrir quand il fait sombre
                // OU
                // Action à effectuer lorsque les volets sont ouverts et on choisit de fermer quand il fait clair
                print("Exécuter l'action appropriée ici...");
                } else {
                print('Action opposée à effectuer ici...');
                }
                },
            child: Text(voletsFermes ? 'Ouvrir les volets' : 'Fermer les volets'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}


