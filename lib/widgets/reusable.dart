import 'package:flutter/material.dart';

Widget reusableTextField(String hintText, IconData icon, bool isPassword,
    TextEditingController controller, BuildContext context) {
  return TextField(
    controller: controller,
    obscureText: isPassword,
    decoration: InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(icon),
    ),
  );
}

Widget signInsignUpButton(BuildContext context, bool isLoading, VoidCallback onPressed) {
  return ElevatedButton(
    onPressed: isLoading ? null : onPressed,
    child: const Text('Sign Up'),
  );
}
