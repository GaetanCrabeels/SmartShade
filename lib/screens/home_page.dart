import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  String? _houseTemp;
  String? _outsideTemp;

  String? _userId;
  late String _houseId;
  late String apiEndpoint =
      'https://agromet.be/fr/agromet/api/v3/get_pameseb_hourly/tsa/18/2023-11-26/2023-11-26/';

  void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  Future<void> _fetchTemperature() async {
    try {
      final response = await http.get(Uri.parse(apiEndpoint));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null) {
          final results = data['results'] as List;
          if (results.isNotEmpty) {
            final lastResult = results.last;
            final temperature = lastResult['tsa'];

            setState(() {
              _outsideTemp = temperature?.toString() ?? 'N/A';
            });
          } else {
            setState(() {
              _outsideTemp = 'N/A';
            });
          }
        } else {
          if (kDebugMode) {
            print('Results key not found in the response');
          }
        }
      } else {
        if (kDebugMode) {
          print('Failed to fetch temperature data: ${response.statusCode}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching temperature data: $error');
      }
    }
  }

  //Shutter state update function (open/close) in the database
  void _setShutterState(String shutterId, bool isOpen) {
    shutters.doc(shutterId).update({'shutter_open': isOpen});
  }

  // function to get the shutter id from the database
  CollectionReference shutters =
      FirebaseFirestore.instance.collection('shutters');
  String shutterId = 'shutter_id_1';

  @override
  void initState() {
    super.initState();

    _fetchTemperature();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _userId = user.uid;

        FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .get()
            .then((DocumentSnapshot userSnapshot) {
          if (userSnapshot.exists) {
            setState(() {
              _houseId = userSnapshot['houseId'];

              FirebaseFirestore.instance
                  .collection('houses')
                  .doc(_houseId)
                  .get()
                  .then((DocumentSnapshot houseSnapshot) {
                if (houseSnapshot.exists) {
                  setState(() {
                    _houseTemp = houseSnapshot['house_temperature']?.toString();
                  });
                } else {
                  if (kDebugMode) {
                    print('Document does not exist on the database');
                  }
                }
              });
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Accueil'),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Bonjour',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Icon(Icons.house, size: 100),
              Text('${_houseTemp ?? 'N/A'}°C',
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 16),
              const Icon(Icons.wb_sunny_outlined, size: 100),
              Text('${_outsideTemp ?? 'N/A'}°C',
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _toggleLoading();
                        _setShutterState(shutterId, true);
                        Future.delayed(const Duration(seconds: 5), () {
                          _toggleLoading();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ouverture des volets terminée'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        fixedSize: const Size(150, 50),
                      ),
                      child:
                          const Text('Ouvrir', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        _toggleLoading();
                        _setShutterState(shutterId, false);
                        Future.delayed(const Duration(seconds: 5), () {
                          _toggleLoading();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fermeture des volets terminée'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        fixedSize: const Size(150, 50),
                      ),
                      child:
                          const Text('Fermer', style: TextStyle(fontSize: 20)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}
