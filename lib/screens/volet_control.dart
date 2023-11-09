import 'package:flutter/material.dart';
import 'package:light/light.dart';

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

    // Créer une instance du capteur de lumière
    Light light = Light();
    
    // Ajouter un écouteur pour le capteur de lumière
    light.lightSensorEvents.listen((LightEvent event) {
      // Utiliser event.light pour obtenir la luminosité en lux
      double luminosite = event.light;

      // Simuler une condition où les volets se ferment automatiquement si la luminosité est élevée
      if (luminosite > 100.0) {
        voletsFermes = true;
      } else {
        voletsFermes = false;
      }

      // Mettre à jour l'interface utilisateur
      setState(() {});
    });

    // Commencer l'écoute du capteur de lumière
    light.startSensing();
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

  @override
  void dispose() {
    // Arrêter l'écoute du capteur de lumière lorsque la page est fermée
    Light().stopSensing();
    super.dispose();
  }
}

