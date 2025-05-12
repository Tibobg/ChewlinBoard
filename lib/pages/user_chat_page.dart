import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserChatPage extends StatefulWidget {
  final String userUid;

  const UserChatPage({super.key, required this.userUid});

  @override
  State<UserChatPage> createState() => _UserChatPageState();
}

class _UserChatPageState extends State<UserChatPage> {
  final TextEditingController _controller = TextEditingController();

  // Remplace ceci par TON vrai UID admin
  final String adminUid = 'wjGx853IYFTe2hrtNxrSvTKc23h1';

  @override
  Widget build(BuildContext context) {
    final chatId =
        widget.userUid.compareTo(adminUid) < 0
            ? '${widget.userUid}_$adminUid'
            : '${adminUid}_${widget.userUid}';

    final messagesRef = FirebaseFirestore.instance
        .collection('messages')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat avec le créateur'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/'); // ou autre route
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final text = message['text'] ?? '';
                    final senderId = message['senderId'];
                    final isUser = senderId == widget.userUid;

                    return Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(text),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Écris ton message...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;

                    final messageData = {
                      'senderId': widget.userUid,
                      'text': text,
                      'imageUrl': null,
                      'createdAt': FieldValue.serverTimestamp(),
                    };

                    final docRef = FirebaseFirestore.instance
                        .collection('messages')
                        .doc(chatId);

                    await docRef.collection('messages').add(messageData);

                    await docRef.set({
                      'participants': [widget.userUid, adminUid],
                      'lastMessage': text,
                      'updatedAt': FieldValue.serverTimestamp(),
                    }, SetOptions(merge: true));

                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
