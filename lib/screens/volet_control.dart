import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';

class VoletControlPage extends StatefulWidget {
  @override
  _VoletControlPageState createState() => _VoletControlPageState();
}

class _VoletControlPageState extends State<VoletControlPage> {
  bool voletsFermes = false;

  void basculerVolets() {
    setState(() {
      voletsFermes = !voletsFermes;
    });
  }

  @override
  void initState() {
    super.initState();
    // Ajouter un écouteur pour le capteur de luminosité
    gyroscopeEvents.listen((GyroscopeEvent event) {
      // Utiliser event.x, event.y, event.z pour obtenir les valeurs du capteur
      double luminosite = event.y;

      // Simuler une condition où les volets se ferment automatiquement si la luminosité est élevée
      if (luminosite > 5.0) {
        voletsFermes = true;
      } else {
        voletsFermes = false;
      }

      // Mettre à jour l'interface utilisateur
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contrôle des Volets'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            voletsFermes ? Icons.panorama_fish_eye : Icons.clear,
            size: 100,
            color: voletsFermes ? Colors.red : Colors.green,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: basculerVolets,
            child: Text(voletsFermes ? 'Ouvrir les volets' : 'Fermer les volets'),
          ),
        ],
      ),
    );
  }
}
