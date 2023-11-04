import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Graphics extends StatefulWidget {
  const Graphics({Key? key}) : super(key: key);

  @override
  _GraphicsState createState() => _GraphicsState();
}

class _GraphicsState extends State<Graphics> {
  String weatherDataText = 'Cliquez sur le bouton pour mettre à jour les données';
  String? selectedStation;
  List<Map<String, String>> sidToPoste = [];

  static const apiUrl = 'https://agromet.be/fr/agromet/api/v3/get_pameseb_hourly_prev/tsa,plu,hra';
  static const token = '253bb380830eb71192fdb2d3af85f23849fb7e7e';

  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _fetchSidToPoste(); // Chargez la liste des stations au démarrage

  }

  Future<void> _fetchSidToPoste() async {
    if (_isDataLoaded) {
      return; // Évitez de recharger les données
    }

    final url = Uri.parse('$apiUrl/all/1');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseJson = jsonDecode(response.body);
        sidToPoste = _extractSidToPoste(responseJson['references']['stations']);
        _isDataLoaded = true; // Marquez les données comme chargées
        sidToPoste.insert(0, {'SID': '0', 'Poste': 'Veuillez choisir une station'});

        setState(() {});
      }
    } catch (exception) {
      // Gérez l'erreur de requête ici
      // Par exemple, weatherDataText = 'Erreur lors de la requête API : $exception';
    }
    // Assurez-vous que le widget est mis à jour
    if (mounted) {
      setState(() {});
    }
  }

  List<Map<String, String>> _extractSidToPoste(List<dynamic> stations) {
    final List<Map<String, String>> result = [];

    for (final station in stations) {
      final sid = station['sid'];
      final poste = station['poste'];

      if (sid != null && poste != null) {
        result.add({'SID': sid, 'Poste': poste});
      }
    }

    return result;
  }

  Future<void> _fetchDataForSelectedStation() async {
    if (selectedStation == null) {
      return;
    }

    final url = Uri.parse('$apiUrl/$selectedStation/1');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseJson = jsonDecode(response.body);
        final prettyPrintedJson = JsonEncoder.withIndent('  ').convert(responseJson);
        _isDataLoaded = true; // Marquez les données comme chargées
        setState(() {
          weatherDataText = prettyPrintedJson;
        });
      } else {
        setState(() {
          weatherDataText = 'Erreur lors de la requête API : ${response.statusCode}';
        });
      }
    } catch (exception) {
      setState(() {
        weatherDataText = 'Erreur lors de la requête API : $exception';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Météo en Belgique'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              FutureBuilder<void>(
                future: _fetchSidToPoste(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return DropdownButton<String>(
                      value: selectedStation ?? '0', // Utilisez '0' comme valeur par défaut
                      items: sidToPoste.map((station) {
                        return DropdownMenuItem<String>(
                          value: station['SID']!,
                          child: Text(station['Poste']!),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          selectedStation = value;
                        });
                      },
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
        ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _fetchDataForSelectedStation();
                },
                child: const Text('Mettre à jour les données'),
              ),
              const SizedBox(height: 16.0),
              Text(
                weatherDataText,
                style: const TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}