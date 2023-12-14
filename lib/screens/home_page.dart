import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  String? _houseTemp;

  bool _showAdvancedOptions = false; // Variable pour le Switch

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Acceuil'),
        actions: <Widget>[
          Switch(
            value: _showAdvancedOptions,
            onChanged: (bool value) {
              setState(() {
                _showAdvancedOptions = value;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // autres widget initials

          // Ajout des boutons conditionnels
          if (_showAdvancedOptions)
            ElevatedButton(
              child: Text('Programmation Automatique'),
              onPressed: () {/* Code pour programmation automatique */},
            ),
          if (_showAdvancedOptions)
            ElevatedButton(
              child: Text('Intégration avec Appareils Connectés'),
              onPressed: () {/* Code pour intégration appareils */},
            ),
          if (_showAdvancedOptions)
            ElevatedButton(
              child: Text('Conseils Écologiques et Bien-être'),
              onPressed: () {/* Code pour conseils écologiques */},
            ),
        ],
      ),
    );
  }
}
