import 'package:flutter/material.dart';
import 'widgets/bottom_navigation_bar.dart  '; // Importez la barre de navigation inférieure

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
      home:
          const BottomNavigationBarWidget(), // Utilisez la barre de navigation
    );
  }
}
