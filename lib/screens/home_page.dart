import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  String? _houseTemp;
  String? _outsideTemp;
  int numberOfOpenedShutters = 0;

  String? _userId;
  late String _houseId;
  late List<Map<String, dynamic>> shutterList = [];

  void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  Future<void> _fetchTemperature() async {
    try {
      DateTime dateToday = DateTime.now();
      String date = dateToday.toString().substring(0, 10);
      late String apiEndpoint =
          'https://agromet.be/fr/agromet/api/v3/get_pameseb_hourly/tsa/18/$date/$date/';
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
  void _setShuttersState(String houseId, bool open) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('shutters')
          .where('houseId', isEqualTo: houseId)
          .where('shutter_open', isEqualTo: !open)
          .get();

      snapshot.docs.forEach((doc) {
        doc.reference.update({'shutter_open': open});
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error setting shutter state: $error');
      }
    }
  }

  void _setOneShutterState(String shutterId, bool open) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
          .instance
          .collection('shutters')
          .doc(shutterId)
          .get();

      if (doc.exists) {
        doc.reference.update({'shutter_open': open});
      } else {
        if (kDebugMode) {
          print('Shutter document not found for id: $shutterId');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error setting shutter state: $error');
      }
    }
  }

// Usage:
  void _setShuttersOpen(String houseId) async {
    _setShuttersState(houseId, true);
  }

  void _setShuttersClose(String houseId) async {
    _setShuttersState(houseId, false);
  }

  // function to get the shutter id from the database
  CollectionReference shutters =
      FirebaseFirestore.instance.collection('shutters');
  String shutterId = 'shutter_id_1';

  Future<int> getOpenedShuttersCount(String houseId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('shutters')
          .where('houseId', isEqualTo: houseId)
          .where('shutter_open', isEqualTo: true)
          .get();

      return snapshot.size;
    } catch (error) {
      print('Error fetching opened shutters: $error');
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> fetchShutterInfo(String houseId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('shutters')
          .where('houseId', isEqualTo: houseId)
          .get();

      List<Map<String, dynamic>> shutterInfoList = snapshot.docs.map((shutter) {
        return {
          'shutter_name': shutter['shutter_name'] ?? 'N/A',
          'shutter_open': shutter['shutter_open'] ?? false,
          'shutter_id': shutter.id,
        };
      }).toList();

      return shutterInfoList;
    } catch (error) {
      print('Error fetching shutter information: $error');
      return [];
    }
  }

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
              getOpenedShuttersCount(_houseId).then((count) {
                setState(() {
                  numberOfOpenedShutters = count;
                });
              });

              fetchShutterInfo(_houseId).then((shutterInfoList) {
                setState(() {
                  shutterList = shutterInfoList;
                });
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildCard(
                      'Température maison',
                      const Icon(Icons.house, size: 100),
                      _houseTemp ?? 'N/A',
                      Colors.green[700]!),
                  buildCard(
                      'Température extérieure',
                      const Icon(Icons.wb_sunny_outlined, size: 100),
                      _outsideTemp ?? 'N/A',
                      Colors.blue[400]!),
                ],
              ),

              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _toggleLoading();
                        _setShuttersState(_houseId, true);
                        Future.delayed(const Duration(seconds: 2), () {
                          _toggleLoading();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ouverture des volets terminée'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          getOpenedShuttersCount(_houseId).then((count) {
                            setState(() {
                              numberOfOpenedShutters = count;
                            });
                          });
                          fetchShutterInfo(_houseId).then((shutterInfoList) {
                            setState(() {
                              shutterList = shutterInfoList;
                            });
                          });
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        fixedSize: const Size(150, 50),
                      ),
                      child: const Text('Ouvrir',
                          style: TextStyle(fontSize: 20, color: Colors.black)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                        onPressed: () {
                          _toggleLoading();
                          _setShuttersState(_houseId, false);
                          Future.delayed(const Duration(seconds: 2), () {
                            _toggleLoading();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fermeture des volets terminée'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            getOpenedShuttersCount(_houseId).then((count) {
                              setState(() {
                                numberOfOpenedShutters = count;
                              });
                            });
                            fetchShutterInfo(_houseId).then((shutterInfoList) {
                              setState(() {
                                shutterList = shutterInfoList;
                              });
                            });
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          fixedSize: const Size(150, 50),
                        ),
                        child: const Text('Fermer',
                            style:
                                TextStyle(fontSize: 20, color: Colors.white))),
                  ],
                ),
              ),
              const Divider(
                height: 32,
                thickness: 2,
                color: Colors.black,
                indent: 20,
                endIndent: 20,
              ),
              Text('Nombre de volets ouverts : $numberOfOpenedShutters',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              // Display the shutters
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: shutterList.map((shutter) {
                      return buildShutterCard(
                        shutter['shutter_name'],
                        shutter['shutter_open'],
                        shutter['shutter_id'],
                      );
                    }).toList(),
                  ),
                ),
              )
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
        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildCard(String title, Widget icon, String value, Color colorChosen) {
    return Card(
      elevation: 3,
      color: colorChosen,
      child: SizedBox(
        width: 180,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              icon,
              const SizedBox(height: 16),
              Text(
                '$value°C',
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildShutterCard(String shutterName, bool isOpen, String shutterId) {
    Color cardColor = isOpen ? Colors.green : Colors.red;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(2),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                shutterName,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              Text(
                isOpen ? 'Ouvert' : 'Fermé',
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
              ElevatedButton(
                onPressed: () {
                  _toggleLoading();
                  isOpen
                      ? _setOneShutterState(shutterId, false)
                      : _setOneShutterState(shutterId, true);
                  Future.delayed(const Duration(seconds: 2), () {
                    _toggleLoading();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isOpen
                              ? 'Fermeture du volet terminée'
                              : 'Ouverture du volet terminée',
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    getOpenedShuttersCount(_houseId).then((count) {
                      setState(() {
                        numberOfOpenedShutters = count;
                      });
                    });
                    fetchShutterInfo(_houseId).then((shutterInfoList) {
                      setState(() {
                        shutterList = shutterInfoList;
                      });
                    });
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: cardColor, // Match the card color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  isOpen ? 'Fermer' : 'Ouvrir',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
