import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../navigation/bottom_nav_container.dart';
import 'login_page.dart';
import 'splash_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen(); // ← Utilisation de la nouvelle page
        }

        if (snapshot.hasData) {
          return const BottomNavContainer();
        }

        return const LoginPage();
      },
    );
  }
}
