import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AdminChatPage extends StatefulWidget {
  final String userUid;
  final String pseudo;

  const AdminChatPage({super.key, required this.userUid, required this.pseudo});

  @override
  State<AdminChatPage> createState() => _AdminChatPageState();
}

class _AdminChatPageState extends State<AdminChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    final chatId =
        widget.userUid.compareTo(currentUid) < 0
            ? '${widget.userUid}_$currentUid'
            : '${currentUid}_${widget.userUid}';

    final messagesRef = FirebaseFirestore.instance
        .collection('messages')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: Text(widget.pseudo)),
      body: SafeArea(
        child: Column(
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
                      final text = message['text'];
                      final imageUrl = message['imageUrl'];
                      final senderId = message['senderId'];
                      final isAdmin = senderId == currentUid;

                      return Align(
                        alignment:
                            isAdmin
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 10,
                          ),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                                isAdmin ? Colors.green[100] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:
                              imageUrl != null
                                  ? Image.network(imageUrl, width: 200)
                                  : Text(text ?? ''),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo, color: Colors.black),
                    tooltip: 'Importer une image',
                    onPressed: () async {
                      final picked = await _picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 70,
                      );

                      if (picked != null) {
                        final file = File(picked.path);
                        final fileName =
                            DateTime.now().millisecondsSinceEpoch.toString();
                        final storageRef = FirebaseStorage.instance.ref().child(
                          'chat_images/$chatId/$fileName.jpg',
                        );

                        await storageRef.putFile(file);
                        final imageUrl = await storageRef.getDownloadURL();

                        await _sendMessage(
                          chatId: chatId,
                          senderId: currentUid,
                          text: null,
                          imageUrl: imageUrl,
                        );
                      }
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Écris ta réponse...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () async {
                      final text = _messageController.text.trim();
                      if (text.isNotEmpty) {
                        await _sendMessage(
                          chatId: chatId,
                          senderId: currentUid,
                          text: text,
                          imageUrl: null,
                        );
                        _messageController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage({
    required String chatId,
    required String senderId,
    String? text,
    String? imageUrl,
  }) async {
    final messageData = {
      'senderId': senderId,
      'text': text,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };

    final docRef = FirebaseFirestore.instance
        .collection('messages')
        .doc(chatId);

    await docRef.collection('messages').add(messageData);

    final preview = text ?? 'Image';
    await docRef.set({
      'participants': [senderId, widget.userUid],
      'lastMessage': preview,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
