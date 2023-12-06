import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class Graphics extends StatefulWidget {
  const Graphics({super.key});

  @override
  _GraphicsState createState() => _GraphicsState();
}

class WeatherData {
  final String mtime;
  final double tsa;
  final double hra;
  final double plu;
  final double vvt;

  WeatherData({
    required this.mtime,
    required this.tsa,
    required this.hra,
    required this.plu,
    required this.vvt,
  });
}

class _GraphicsState extends State<Graphics> {
  String weatherDataText = 'Cliquez sur le bouton pour mettre à jour les données';
  String? selectedStation;
  List<Map<String, String>> sidToPoste = [];
  bool useLocation = false;

  static const apiUrl =
      'https://agromet.be/fr/agromet/api/v3/get_pameseb_hourly_prev/tsa,plu,hra,ens,vvt';
  static const token = '253bb380830eb71192fdb2d3af85f23849fb7e7e';

  bool _isDataLoaded = false;

  List<Widget> dataWidgets = []; // Ajout de la liste dataWidgets

  @override
  void initState() {
    super.initState();
    _fetchSidToPoste(); // Chargez la liste des stations au démarrage
  }

  Future<void> _fetchSidToPoste() async {
    if (_isDataLoaded) {
      return; // Évitez de recharger les données
    }

    if (useLocation) {
      await _getCurrentLocation();
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
        sidToPoste.insert(0, {
          'SID': '0',
          'Poste': 'Veuillez choisir une station',
          'longitude': '0',
          'latitude': '0'
        });
        _isDataLoaded = true; // Marquez les données comme chargées
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
      final longitude = station['longitude'];
      final latitude = station['latitude'];

      if (sid != null && poste != null) {
        result.add({
          'SID': sid,
          'Poste': poste,
          'longitude': longitude,
          'latitude': latitude
        });
      }
    }

    return result;
  }

  Future<void> _getCurrentLocation() async {
    Position position =
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

    double userLatitude = position.latitude;
    double userLongitude = position.longitude;

    double closestDistance = double.infinity;
    String? closestStation;

    for (final station in sidToPoste) {
      final stationLatitude = double.tryParse(station['latitude']!);
      final stationLongitude = double.tryParse(station['longitude']!);

      if (stationLatitude != null && stationLongitude != null) {
        final distance = Geolocator.distanceBetween(
          userLatitude,
          userLongitude,
          stationLatitude,
          stationLongitude,
        );
        if (distance < closestDistance) {
          closestDistance = distance;
          closestStation = station['SID'];
        }
      }
    }

    if (closestStation != null) {
      setState(() {
        selectedStation = closestStation;
      });
    }
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

        if (responseJson.containsKey('results') && responseJson['results'] is List) {
          final List<dynamic> results = responseJson['results'];
          final List<WeatherData> weatherDataList = [];

          for (final result in results) {
            final mtime = result['mtime'];
            print(mtime);
            final tsa = double.tryParse(result['tsa']);
            final hra = double.tryParse(result['hra']);
            final plu = double.tryParse(result['plu']);
            final vvt = double.tryParse(result['vvt']);

            if (mtime != null && tsa != null && hra != null && plu != null && vvt != null) {
              weatherDataList.add(WeatherData(
                mtime: mtime,
                tsa: tsa,
                hra: hra,
                plu: plu,
                vvt: vvt,
              ));
            }
          }

          // Afficher les données dans un tableau
          dataWidgets = weatherDataList.map((data) { // Mettre à jour dataWidgets
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Date et Heure: ${data.mtime}'),
                Text('Température (°C): ${data.tsa.toStringAsFixed(2)}'),
                Text('Précipitations (mm): ${data.plu.toStringAsFixed(2)}'),
                Text('Humidité relative (%): ${data.hra.toStringAsFixed(2)}'),
                Text('Vitesse du vent (m/s): ${data.vvt.toStringAsFixed(2)}'),
                const SizedBox(height: 16.0),
              ],
            );
          }).toList();

          setState(() {
            weatherDataText = '';
          });
        } else {
          setState(() {
            weatherDataText = 'Réponse API mal formée : Pas de clé "results" ou pas de liste de résultats valide.';
          });
        }
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
              SwitchListTile(
                title: const Text('Utiliser ma localisation'),
                value: useLocation,
                onChanged: (value) {
                  setState(() {
                    useLocation = value;
                    if (value) {
                      _getCurrentLocation(); // Appeler _getCurrentLocation lorsque useLocation est vrai
                    }
                  });
                },
              ),
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
              Column(
                children: dataWidgets, // Afficher les données ici
              ),
            ],
          ),
        ),
      ),
    );
  }
}
