import 'package:flutter/material.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interface Admin')),
      body: const Center(child: Text("Liste des discussions à venir ici")),
    );
  }
}
