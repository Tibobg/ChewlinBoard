import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:flutter/material.dart';
import '../pages/auth/login_page.dart'; // ajuste le chemin si nécessaire

class AdminProjectPage extends StatelessWidget {
  const AdminProjectPage({super.key});

  void _logout(BuildContext context) async {
    await firebaseAuth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: const Center(child: Text('Page de gestion des projets')),
    );
  }
}
