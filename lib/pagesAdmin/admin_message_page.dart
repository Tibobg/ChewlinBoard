import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'admin_chat_page.dart'; // Assure-toi que ce fichier contient le chat complet

class AdminMessagePage extends StatelessWidget {
  const AdminMessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final messagesRef = FirebaseFirestore.instance.collection('messages');

    return Scaffold(
      appBar: AppBar(title: const Text("Discussions")),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            messagesRef
                .where('participants', arrayContains: currentUid)
                .orderBy('updatedAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Aucune discussion pour le moment."),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final participants = List<String>.from(doc['participants']);
              final userUid = participants.firstWhere(
                (uid) => uid != currentUid,
              );
              final lastMessage = doc['lastMessage'] ?? '';

              return FutureBuilder<DocumentSnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(userUid)
                        .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return const SizedBox.shrink();

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  final pseudo = userData['pseudo'] ?? 'Utilisateur';
                  final photoUrl = userData['photoUrl'];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          photoUrl != null ? NetworkImage(photoUrl) : null,
                      child: photoUrl == null ? Text(pseudo[0]) : null,
                    ),
                    title: Text(pseudo),
                    subtitle: Text(lastMessage),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => AdminChatPage(
                                userUid: userUid,
                                pseudo: pseudo,
                              ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
