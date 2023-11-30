import 'package:flutter/material.dart';
import 'bottom_navigation_bar.dart'; // Importez la barre de navigation inférieure
import 'package:flutter_application_1/firebase_options.dart';
import 'widgets/bottom_navigation_bar.dart';
import 'screens/home_page.dart'; // Importez la page d'accueil
import 'screens/settings_page.dart'; // Importez la page de réglages
import 'package:firebase_core/firebase_core.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon App Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BottomNavigationBarWidget(), // Utilisez la barre de navigation
    );
  }
}
