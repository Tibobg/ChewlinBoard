import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_chat_page.dart';

class MessagePage extends StatelessWidget {
  const MessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    // Redirige vers le chat dès que la page est affichée
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UserChatPage(userUid: currentUser!.uid),
        ),
      );
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
