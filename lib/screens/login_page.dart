import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/database_service.dart';
import '../blocs/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: BlocBuilder<AuthBloc, AuthStatus>(
        builder: (context, authStatus) {
          if (authStatus == AuthStatus.authenticated) {
            return const Center(
              child: Text('User is already authenticated.'),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Semantics(
                    label: 'Email',
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                  ),
                  Semantics(
                    label: 'Password',
                    child: TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _signInWithEmailAndPassword,
                    child: BlocBuilder<AuthBloc, AuthStatus>(
                      builder: (context, authStatus) {
                        return authStatus == AuthStatus.authenticating
                            ? const CircularProgressIndicator()
                            : const Text('Sign In');
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _signInWithEmailAndPassword() async {
    try {
      print('Signing in with email and password...');
      // Authenticate user with email and password
      bool isAuthenticated = await _databaseService.authenticateUser(
        _emailController.text,
        _passwordController.text,
      );

      print('isAuthenticated: $isAuthenticated');

      if (isAuthenticated) {
        // Fetch user data from Firestore
        Map<String, dynamic>? userData =
            await _databaseService.getUserByEmail(_emailController.text);

        if (userData != null) {
          // Check user association with a house
          bool isUserAssociated =
              await _databaseService.isUserAssociatedWithHouse(
            _auth.currentUser!.uid, // Use the current user's UID
            'house_id_1', // Replace with the actual house ID
          );

          if (isUserAssociated) {
            // Authentication successful
            // Update authentication state
            BlocProvider.of<AuthBloc>(context).setUser(_auth.currentUser);
          } else {
            // User is not associated with the specified house
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('User is not associated with the specified house.'),
              ),
            );
          }
        }
      } else {
        // Incorrect email or password
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incorrect email or password'),
          ),
        );
      }
    } catch (e) {
      print('Error signing in: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing in: $e'),
        ),
      );

      // Reset the authentication status on error
      BlocProvider.of<AuthBloc>(context)
          .setAuthStatus(AuthStatus.unauthenticated);
    }
  }
}
