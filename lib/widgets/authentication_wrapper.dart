import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'bottom_navigation_bar.dart'; // Import your BottomNavigationBarWidget
import '../screens/LoginPage.dart'; // Import your LoginPage

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Error fetching user');
        } else if (snapshot.hasData && snapshot.data != null) {
          return const BottomNavigationBarWidget();
        } else {
          // Return LoginPage if user is not authenticated
          return LoginPage();
        }
      },
    );
  }
}
