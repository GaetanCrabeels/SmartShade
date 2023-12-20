import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'home_page.dart';
import 'dart:async';

class UserPage extends StatefulWidget {
  final String user_name;
  final FirebaseFirestore firestore;

  const UserPage({Key? key, required this.user_name, required this.firestore})
      : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int _degreeDiff = 0;
  String? _userId;
  late String _houseId = '0';
  late bool useTemperatureDelta = false;
  late bool useHour = false;
  late double _hourOpening = 0;
  late double _hourClosing = 0;
  late String printHourOpening = '';
  late String printHourClosing = '';
  late bool useLightMode = false;
  late String selectedLightLevel = 'Matin';
  late double lightThreshold;
  late double externalLightValue; // Nouvelle variable pour la luminosité externe
  final Map<String, double> lightLevels = {
    'Matin': 5000.0,
    'Soir': 150.0,
    'Nuit': 15.0,
  };

  CollectionReference houses = FirebaseFirestore.instance.collection('houses');

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
    }

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
                _degreeDiff = houseSnapshot['shutter_temperature_delta'];
                useTemperatureDelta =
                houseSnapshot['shutter_temperature_delta_bool'];
                useHour = houseSnapshot['shutter_hour_bool'];
                _hourOpening = houseSnapshot['shutter_hour_open'];
                _hourClosing = houseSnapshot['shutter_hour_close'];

                printHourOpening = convertToHourMinute(_hourOpening);
                printHourClosing = convertToHourMinute(_hourClosing);

                useLightMode = houseSnapshot['use_light_mode'] ?? false;
                selectedLightLevel =
                    houseSnapshot['selected_light_level'] ?? 'Matin';
                lightThreshold = houseSnapshot['light_threshold'] ?? 0.0;
              });
            } else {
              if (kDebugMode) {
                print('Document does not exist in the database');
              }
            }
          });
        });
      }
    });

    // Appel à la fonction pour récupérer la luminosité externe
    Timer.periodic(Duration(seconds: 30), (Timer t) => getExternalLightData());
  }

    // Fonction pour récupérer la luminosité externe depuis Firebase
  void getExternalLightData() {
    FirebaseFirestore.instance
        .collection('sensor_data')
        .doc('light_sensor')
        .get()
        .then((DocumentSnapshot sensorSnapshot) {
      if (sensorSnapshot.exists) {
        setState(() {
          externalLightValue = sensorSnapshot['ldr_value'];
        });
      }
    }).catchError((error) {
      if (kDebugMode) {
        print('Error getting sensor data: $error');
      }
    });
  }

  void checkLightAndAct() {
    if (useLightMode && externalLightValue < lightThreshold) {
      // Appeler la fonction pour fermer tous les volets
      //_setShuttersClose(_houseId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Page'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: houses.doc(_houseId).get(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {}

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            Future.delayed(const Duration(seconds: 2), () {
              return const Text('House not found');
            });
          }

          return Column(
            children: [
              buildSwitchCard(
                title: 'Activation du mode de différence de température : ',
                value: useTemperatureDelta,
                onChanged: (value) {
                  _updateTemperatureDelta(value);
                },
              ),
              buildSwitchCard(
                title: 'Choix de l\'heure : ',
                value: useHour,
                onChanged: (value) {
                  _updateHour(value);
                },
              ),
              buildSwitchCard(
                title: 'Activation du mode de luminosité : ',
                value: useLightMode,
                onChanged: (value) {
                  _updateLightMode(value);
                },
              ),
              if (useTemperatureDelta)
                buildCard(
                  title: 'Degré de différence pour ouverture et fermeture',
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildElevatedButton(_decrementNumber, Icons.remove),
                      const SizedBox(width: 16),
                      Text(
                        '$_degreeDiff',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 16),
                      buildElevatedButton(_incrementNumber, Icons.add),
                    ],
                  ),
                ),
              if (useHour)
                buildTimeSelectionCard(
                  title: 'Heure d\'ouverture des volets : ',
                  onPressed: () => _selectTime(context, true),
                  content: Text(printHourOpening),
                ),
              if (useHour)
                buildTimeSelectionCard(
                  title: 'Heure de fermeture des volets : ',
                  onPressed: () => _selectTime(context, false),
                  content: Text(printHourClosing),
                ),
              if (useLightMode)
                buildLightLevelSelectionCard(
                  title: 'Choix du niveau de luminosité : ',
                  onPressed: () => _selectLightLevel(context),
                  content: Text(selectedLightLevel),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget buildSwitchCard({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCard({
    required String title,
    required Widget content,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget buildTimeSelectionCard({
    required String title,
    required VoidCallback onPressed,
    required Widget content,
  }) {
    return buildCard(
      title: title,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 48),
            ),
            child: content,
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget buildLightLevelSelectionCard({
    required String title,
    required VoidCallback onPressed,
    required Widget content,
  }) {
    return buildCard(
      title: title,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 48),
            ),
            child: content,
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  String convertToHourMinute(double value) {
    final hour = value.toInt();
    final minute = ((value - hour) * 60).toInt();
    return '$hour:$minute';
  }

  void _updateHour(bool value) {
    setState(() {
      useHour = value;
      useTemperatureDelta = false;

      houses.doc(_houseId).update({
        'shutter_hour_bool': value,
        'shutter_temperature_delta_bool': false,
      }).then((_) {
        printHourOpening = convertToHourMinute(_hourOpening);
        printHourClosing = convertToHourMinute(_hourClosing);
      }).catchError((error) {
        if (kDebugMode) {
          print('Error updating document: $error');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating document'),
            duration: Duration(seconds: 2),
          ),
        );
      });
    });
  }

  Future<void> _selectTime(BuildContext context, bool isOpening) async {
    final initialTime = TimeOfDay(
      hour: isOpening ? _hourOpening.toInt() : _hourClosing.toInt(),
      minute: isOpening
          ? ((_hourOpening - _hourOpening.toInt()) * 60).round()
          : ((_hourClosing - _hourClosing.toInt()) * 60).round(),
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        if (isOpening) {
          _hourOpening = picked.hour.toDouble() + picked.minute.toDouble() / 60;
        } else {
          _hourClosing = picked.hour.toDouble() + picked.minute.toDouble() / 60;
        }

        // Update the printed hour strings
        printHourOpening = convertToHourMinute(_hourOpening);
        printHourClosing = convertToHourMinute(_hourClosing);
      });

      houses.doc(_houseId).update({
        'shutter_hour_open': _hourOpening,
        'shutter_hour_close': _hourClosing,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Value updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }).catchError((error) {
        if (kDebugMode) {
          print('Error updating document: $error');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating document'),
            duration: Duration(seconds: 2),
          ),
        );
      });
    }
  }

  void _updateTemperatureDelta(bool value) {
    setState(() {
      useTemperatureDelta = value;
      useHour = false;

      houses
          .doc(_houseId)
          .update({
        'shutter_temperature_delta_bool': value,
        'shutter_hour_bool': false,
      })
          .then((_) {})
          .catchError((error) {
        if (kDebugMode) {
          print('Error updating document: $error');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating document'),
            duration: Duration(seconds: 2),
          ),
        );
      });
    });
  }

  void _incrementNumber() {
    setState(() {
      _degreeDiff++;

      houses.doc(_houseId).update({
        'shutter_temperature_delta': _degreeDiff,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Value updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }).catchError((error) {
        if (kDebugMode) {
          print('Error updating document: $error');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating document'),
            duration: Duration(seconds: 2),
          ),
        );
      });
    });
  }

  void _decrementNumber() {
    setState(() {
      _degreeDiff--;

      houses.doc(_houseId).update({
        'shutter_temperature_delta': _degreeDiff,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Value updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }).catchError((error) {
        if (kDebugMode) {
          print('Error updating document: $error');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating document'),
            duration: Duration(seconds: 2),
          ),
        );
      });
    });
  }

  void _updateLightMode(bool value) {
    setState(() {
      useLightMode = value;

      houses.doc(_houseId).update({
        'use_light_mode': value,
      }).then((_) {}).catchError((error) {
        if (kDebugMode) {
          print('Error updating document: $error');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating document'),
            duration: Duration(seconds: 2),
          ),
        );
      });
    });
  }

  void _selectLightLevel(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Selectionnez un moment de la journée'),
          content: Column(
            children: [
              ElevatedButton(
                onPressed: () => _updateSelectedLightLevel('Matin'),
                child: Text('Matin'),
              ),
              ElevatedButton(
                onPressed: () => _updateSelectedLightLevel('Soir'),
                child: Text('Soir'),
              ),
              ElevatedButton(
                onPressed: () => _updateSelectedLightLevel('Nuit'),
                child: Text('Nuit'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateSelectedLightLevel(String level) {
    setState(() {
      selectedLightLevel = level;
      lightThreshold = lightLevels[level] ?? 0.0;

      houses.doc(_houseId).update({
        'selected_light_level': level,
        'light_threshold': lightThreshold,
      }).then((_) {
        Navigator.pop(context); // Ferme le dialogue
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Niveau de luminosité mis à jour avec succès'),
            duration: Duration(seconds: 2),
          ),
        );
      }).catchError((error) {
        if (kDebugMode) {
          print('Erreur de mise à jour du document: $error');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur de mise à jour du document'),
            duration: Duration(seconds: 2),
          ),
        );
      });
    });
  }


  Widget buildElevatedButton(VoidCallback onPressed, IconData icon) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Icon(icon),
    );
  }
}
