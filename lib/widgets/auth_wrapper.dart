import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/login/login_screen.dart';
import '../screens/home/home_screen.dart';
import 'ziyarah_loader.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ZiyarahLoader(message: 'Loading...');
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is signed in
          return HomeScreen(user: snapshot.data!);
        }

        // User is not signed in
        return const LoginScreen();
      },
    );
  }
} 