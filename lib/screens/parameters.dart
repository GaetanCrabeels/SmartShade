import 'package:flutter/material.dart';

class Parameters extends StatefulWidget {
  const Parameters({super.key});

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
        ],
      ),
    );
  }
}
