import 'package:flutter/material.dart';
import 'package:light/light.dart';

class VoletControlPage extends StatefulWidget {
  @override
  _VoletControlPageState createState() => _VoletControlPageState();
}

class _VoletControlPageState extends State<VoletControlPage> {
  bool voletsFermes = false;
  Light? _light;
  StreamSubscription<int>? _subscription;

  void onData(int luxValue) {
    // Utiliser luxValue pour obtenir la luminosité en lux
    double luminosite = luxValue.toDouble();

    // Simuler une condition où les volets se ferment automatiquement si la luminosité est élevée
    if (luminosite > 100.0) {
      voletsFermes = true;
    } else {
      voletsFermes = false;
    }

    // Mettre à jour l'interface utilisateur
    setState(() {});
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
            onPressed: () {},
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


