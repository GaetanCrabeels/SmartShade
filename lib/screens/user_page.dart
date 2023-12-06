import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UserPage extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final String user_name;
  // ignore: non_constant_identifier_names
  const UserPage({super.key, required this.user_name});

  @override
  // ignore: library_private_types_in_public_api
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int _degreeDiff = 0;
  late String _userId;
  late String _houseId = '0';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Page'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: houses.doc(_houseId).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
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
              const Text('Mode d\'utilisation des volets: '),
              Container(
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.center,
                child: const Text(
                  'Degré de différence pour ouverture et fermeture',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _decrementNumber,
                      child: const Icon(Icons.remove),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '$_degreeDiff',
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _incrementNumber,
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
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
}
