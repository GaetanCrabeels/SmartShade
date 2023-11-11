import 'package:flutter/material.dart';
import 'volet_control.dart';

class Parameters extends StatefulWidget {
  const Parameters({Key? key}) : super(key: key);

  @override
  _ParametersState createState() => _ParametersState();
}

class _ParametersState extends State<Parameters> {
  bool _isDarkModeEnabled = false;
  double _fontSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: const Text('Mode sombre'),
            value: _isDarkModeEnabled,
            onChanged: (value) {
              setState(() {
                _isDarkModeEnabled = value;
              });
            },
          ),
          ListTile(
            title: const Text('Gestion des capteurs lumineux'),
            onTap: () {
              // Accéder à la page VoletControlPage (utilisation de VoletApp ici)
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VoletApp()),
              );
            },
          ),
          const SizedBox(height: 16.0),
          const Text('Taille de police'),
          Slider(
            value: _fontSize,
            min: 12.0,
            max: 24.0,
            divisions: 6,
            onChanged: (value) {
              setState(() {
                _fontSize = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
