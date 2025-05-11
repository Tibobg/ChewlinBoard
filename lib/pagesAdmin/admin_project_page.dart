import 'package:flutter/material.dart';

class AdminProjectPage extends StatelessWidget {
  const AdminProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Projets')),
      body: const Center(child: Text('Page de gestion des projets')),
    );
  }
}
