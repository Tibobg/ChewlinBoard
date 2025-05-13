import 'package:chewlin_board/navigation/admin_nav_container.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../navigation/bottom_nav_container.dart';
import 'login_page.dart';
import 'splash_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<bool> isAdmin(User user) async {
    final idTokenResult = await user.getIdTokenResult(true);
    return idTokenResult.claims?['admin'] == true;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        if (snapshot.hasData) {
          return FutureBuilder<bool>(
            future: isAdmin(snapshot.data!),
            builder: (context, adminSnapshot) {
              if (!adminSnapshot.hasData) {
                return const SplashScreen();
              }
              if (adminSnapshot.data == true) {
                return const AdminNavContainer();
              } else {
                return const BottomNavContainer(); // la homepage utilisateur
              }
            },
          );
        }

        return const LoginPage();
      },
    );
  }
}
