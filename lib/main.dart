import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_bar.dart'; // Importez la barre de navigation inférieure
//import 'package:firebase_core/firebase_core.dart';

void main() {
  //WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
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
