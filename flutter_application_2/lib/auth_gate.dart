import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key); // Key parameter for constructor

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while checking auth state
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()), // Remove const
          );
        } else if (snapshot.hasData) {
          // User is signed in
          return const HomeScreen(); // Remove const
        } else {
          // User is not signed in
          return const LoginScreen(); // Remove const
        }
      },
    );
  }
}
