import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void initState() {
    super.initState();

    CollectionReference houses =
        FirebaseFirestore.instance.collection('houses');
    String houseId = 'house_id_1';

    houses.doc(houseId).get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        if (kDebugMode) {
          print('Document data: ${documentSnapshot.data()}');
        }
        setState(() {
          _degreeDiff = documentSnapshot['shutter_temperature_delta'];
        });
      } else {
        if (kDebugMode) {
          print('Document does not exist on the database');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Create a reference to the "users" collection
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Page'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: users
            .doc(widget.user_name)
            .get(), // Retrieve the document with the user's ID
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            //return const CircularProgressIndicator(); // Display a loading indicator while fetching data
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Text(
                'No data found'); // Handle the case where the document doesn't exist
          }

          // Access the user's data and display it
          //Map<String, dynamic> userData =
          //  snapshot.data!.data() as Map<String, dynamic>;
          //String userName = userData['user_name'];

          return Column(
            children: [
              const Text('Mode d\'utilisation des volets: '),
              //Text('User Name: $userName'), // Display the user's name
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

      CollectionReference houses =
          FirebaseFirestore.instance.collection('houses');

      String houseId = 'house_id_1';

      houses.doc(houseId).update({
        'shutter_temperature_delta': _degreeDiff,
      });
    });
  }

  void _decrementNumber() {
    setState(() {
      _degreeDiff--;

      CollectionReference houses =
          FirebaseFirestore.instance.collection('houses');

      String houseId = 'house_id_1';

      houses.doc(houseId).update({
        'shutter_temperature_delta': _degreeDiff,
      });
    });
  }
}
