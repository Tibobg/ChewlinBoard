import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'admin_chat_page.dart';

class AdminMessagePage extends StatelessWidget {
  const AdminMessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final messagesRef = FirebaseFirestore.instance.collection('messages');

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.beige),
        centerTitle: true,
        title: Text(
          "Discussions",
          style: TextStyle(
            color: AppColors.beige,
            fontFamily: 'ReginaBlack',
            fontSize: 24,
          ),
        ),
      ),
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
              final chatId = doc.id;

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

                  return StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('messages')
                            .doc(chatId)
                            .collection('messages')
                            .where('senderId', isEqualTo: userUid)
                            .where('isRead', isEqualTo: false)
                            .snapshots(),
                    builder: (context, unreadSnapshot) {
                      final hasUnread =
                          unreadSnapshot.hasData &&
                          unreadSnapshot.data!.docs.isNotEmpty;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              photoUrl != null ? NetworkImage(photoUrl) : null,
                          backgroundColor: AppColors.green.withOpacity(0.2),
                          child:
                              photoUrl == null
                                  ? Text(
                                    pseudo[0].toUpperCase(),
                                    style: TextStyle(color: AppColors.black),
                                  )
                                  : null,
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                pseudo,
                                style: TextStyle(
                                  fontWeight:
                                      hasUnread
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  color: AppColors.beige,
                                  fontFamily: 'Roboto',
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (hasUnread)
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.beige.withOpacity(0.7),
                          ),
                        ),
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
          );
        },
      ),
    );
  }
}
