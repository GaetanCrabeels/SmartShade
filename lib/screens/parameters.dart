import 'package:flutter/material.dart';
import 'fermeture_tempo.dart';

class Parameters extends StatefulWidget {
  const Parameters({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ParametersState createState() => _ParametersState();
}

class _ParametersState extends State<Parameters> {
  bool _isDarkModeEnabled = false;
  double _fontSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parameters'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SwitchListTile(
              title: const Text('Dark mode'),
              value: _isDarkModeEnabled,
              onChanged: (value) {
                setState(() {
                  _isDarkModeEnabled = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            const Text('Font size'),
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
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FermetureTempoScreen()),
                );
              },
              child: Text('Menu gestion des capteurs'),
            ),
          ],
        ),
      ),
    );
  }
}
