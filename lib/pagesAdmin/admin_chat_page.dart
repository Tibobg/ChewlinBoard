import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/colors.dart';

class AdminChatPage extends StatefulWidget {
  final String userUid;
  final String pseudo;

  const AdminChatPage({super.key, required this.userUid, required this.pseudo});

  @override
  State<AdminChatPage> createState() => _AdminChatPageState();
}

class _AdminChatPageState extends State<AdminChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _replyToMessage;

  @override
  void initState() {
    super.initState();
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance.collection('users').doc(currentUid).set({
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final chatId =
        widget.userUid.compareTo(currentUid) < 0
            ? '${widget.userUid}_$currentUid'
            : '${currentUid}_${widget.userUid}';

    _markMessagesAsRead(chatId, currentUid);
  }

  Future<void> _markMessagesAsRead(String conversationId, String userId) async {
    final query =
        await FirebaseFirestore.instance
            .collection('messages')
            .doc(conversationId)
            .collection('messages')
            .where('senderId', isNotEqualTo: userId)
            .where('isRead', isEqualTo: false)
            .get();

    for (final doc in query.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  Future<void> _sendTextMessage(String chatId, String senderId) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await _sendMessage(chatId: chatId, senderId: senderId, text: text);
    _controller.clear();
    setState(() {
      _replyToMessage = null;
    });
  }

  Future<void> _pickAndSendImage(String chatId, String senderId) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child('chat_images/$fileName');
      final uploadTask = await ref.putFile(file);

      if (uploadTask.state == TaskState.success) {
        final imageUrl = await ref.getDownloadURL();
        await _sendMessage(
          chatId: chatId,
          senderId: senderId,
          imageUrl: imageUrl,
        );
        setState(() {
          _replyToMessage = null;
        });
      }
    }
  }

  Future<void> _sendMessage({
    required String chatId,
    required String senderId,
    String? text,
    String? imageUrl,
  }) async {
    final messageData = {
      'senderId': senderId,
      'text': text ?? '',
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
      'replyTo': _replyToMessage,
    };

    final docRef = FirebaseFirestore.instance
        .collection('messages')
        .doc(chatId);
    await docRef.collection('messages').add(messageData);

    await docRef.set({
      'participants': [senderId, widget.userUid],
      'lastMessage': text ?? '📷 Image',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await FirebaseFirestore.instance.collection('users').doc(senderId).update({
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

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
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.beige),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              widget.pseudo,
              style: TextStyle(
                color: AppColors.beige,
                fontFamily: 'ReginaBlack',
                fontSize: 20,
              ),
            ),
            StreamBuilder<DocumentSnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.userUid)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                final data = snapshot.data!.data() as Map<String, dynamic>;
                final lastSeen = data['lastSeen'] as Timestamp?;
                final now = DateTime.now();
                String status = '';
                if (lastSeen != null) {
                  final diff = now.difference(lastSeen.toDate());
                  if (diff.inMinutes < 1)
                    status = 'En ligne';
                  else if (diff.inMinutes < 60)
                    status = 'Actif il y a ${diff.inMinutes} min';
                  else if (diff.inHours < 24)
                    status = 'Actif il y a ${diff.inHours} h';
                  else {
                    final date = lastSeen.toDate();
                    status =
                        'Actif le ${date.day}/${date.month} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
                  }
                }
                return Text(
                  status,
                  style: TextStyle(
                    color: AppColors.beige.withOpacity(0.5),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                );
              },
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
                  physics: const BouncingScrollPhysics(),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final data = message.data() as Map<String, dynamic>;
                    final text = data['text'] ?? '';
                    final imageUrl = data['imageUrl'];
                    final senderId = data['senderId'];
                    final isAdmin = senderId == currentUid;
                    final timestamp =
                        (data['createdAt'] as Timestamp?)?.toDate();
                    final isRead =
                        data.containsKey('isRead') ? data['isRead'] : false;
                    final replyTo = data['replyTo'];

                    bool sameSenderAsPrevious = false;
                    if (index < messages.length - 1) {
                      final previousSender =
                          (messages[index + 1].data()
                              as Map<String, dynamic>)['senderId'];
                      sameSenderAsPrevious = previousSender == senderId;
                    }

                    return Align(
                      alignment:
                          isAdmin
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                      child: GestureDetector(
                        onLongPress: () {
                          setState(() {
                            _replyToMessage = text;
                          });
                        },
                        child: Column(
                          crossAxisAlignment:
                              isAdmin
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                          children: [
                            if (replyTo != null && replyTo.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  bottom: 4,
                                ),
                                child: Text(
                                  '↪ $replyTo',
                                  style: TextStyle(
                                    color: AppColors.beige.withOpacity(0.5),
                                    fontStyle: FontStyle.italic,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            Container(
                              margin: EdgeInsets.only(
                                top: sameSenderAsPrevious ? 2 : 10,
                                bottom: 2,
                                left: 12,
                                right: 12,
                              ),
                              padding: const EdgeInsets.all(12),
                              constraints: const BoxConstraints(maxWidth: 280),
                              decoration: BoxDecoration(
                                color:
                                    isAdmin
                                        ? AppColors.green
                                        : AppColors.black.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.green,
                                  width: isAdmin ? 0 : 1,
                                ),
                              ),
                              child:
                                  imageUrl != null
                                      ? ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.network(
                                          imageUrl,
                                          width: 200,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                      : Text(
                                        text,
                                        style: TextStyle(
                                          color: AppColors.beige,
                                          fontFamily: 'Roboto',
                                          fontSize: 14,
                                        ),
                                      ),
                            ),
                            if (index == 0 && timestamp != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  bottom: 4,
                                ),
                                child: Text(
                                  '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')} - ${isRead ? "Lu" : "Envoyé"}',
                                  style: TextStyle(
                                    color: AppColors.beige.withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_replyToMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Réponse à : $_replyToMessage',
                      style: TextStyle(
                        color: AppColors.beige,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.beige),
                    onPressed: () {
                      setState(() {
                        _replyToMessage = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.green),
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(
                        color: AppColors.beige,
                        fontFamily: 'Roboto',
                      ),
                      decoration: InputDecoration(
                        hintText: 'Écris ta réponse...',
                        hintStyle: TextStyle(
                          color: AppColors.beige.withOpacity(0.5),
                          fontFamily: 'Roboto',
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.image, color: AppColors.beige),
                    onPressed: () => _pickAndSendImage(chatId, currentUid),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: AppColors.beige),
                    onPressed: () => _sendTextMessage(chatId, currentUid),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
