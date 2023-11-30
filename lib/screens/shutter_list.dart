import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ShutterListPage extends StatelessWidget {
  const ShutterListPage({super.key});

  @override
<<<<<<< Updated upstream
  // ignore: library_private_types_in_public_api
  _ShutterListState createState() => _ShutterListState();
}

class _ShutterListState extends State<ShutterList> {
  @override
=======
>>>>>>> Stashed changes
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shutters Linked to House 1'),
      ),
      body: const ShutterList(houseId: 'house_id_1'),
    );
  }
}

class ShutterList extends StatelessWidget {
  final String houseId;

  const ShutterList({super.key, required this.houseId});

  @override
  Widget build(BuildContext context) {
    CollectionReference shutters =
        FirebaseFirestore.instance.collection('shutters');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des volets'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: shutters.where('house_id', isEqualTo: houseId).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Text('No shutters found for House 1');
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic>? shutterData =
                  document.data() as Map<String, dynamic>?;
              String shutterName = shutterData?['shutter_name'];

              return ElevatedButton(
                onPressed: () {
                  // Handle button press for this shutter
                },
                child: Text(shutterName),
              );
            }).toList(),
          );
        },
      ),
<<<<<<< Updated upstream
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text('Volet ${index + 1}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Colors.blue,
        label: const Text('Ajout d\'un volet'),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
=======
>>>>>>> Stashed changes
    );
  }
}
