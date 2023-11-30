import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'widgets/bottom_navigation_bar.dart'; // Importez la barre de navigation inférieure
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
