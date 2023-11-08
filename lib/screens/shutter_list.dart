import 'package:flutter/material.dart';

class ShutterList extends StatefulWidget {
  const ShutterList({Key? key}) : super(key: key);

  @override
  _ShutterListState createState() => _ShutterListState();
}

class _ShutterListState extends State<ShutterList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des volets'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: List.generate(20, (index) {
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle button press
                },
                child: Text('Volet ${index + 1}'),
              ),
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Handle FloatingActionButton press
        },
        backgroundColor: Colors.blue,
        label: const Text('Ajout d\'un volet'),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
