import 'package:flutter/material.dart';

class ShutterList extends StatefulWidget {
  const ShutterList({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ShutterListState createState() => _ShutterListState();
}

class _ShutterListState extends State<ShutterList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des volets'),
      ),
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
    );
  }
}
