import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserChatPage extends StatefulWidget {
  final String userUid;

  const UserChatPage({super.key, required this.userUid});

  @override
  State<UserChatPage> createState() => _UserChatPageState();
}

class _UserChatPageState extends State<UserChatPage> {
  final TextEditingController _controller = TextEditingController();
  final String adminUid = 'wjGx853IYFTe2hrtNxrSvTKc23h1';
  String? _replyToMessage;
  late final String chatId;

  @override
  void initState() {
    super.initState();

    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    chatId =
        widget.userUid.compareTo(adminUid) < 0
            ? '${widget.userUid}_$adminUid'
            : '${adminUid}_${widget.userUid}';

    FirebaseFirestore.instance.collection('users').doc(currentUid).set({
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    _markMessagesAsRead(chatId, currentUid);
  }

  Future<void> _markMessagesAsRead(String conversationId, String userId) async {
    final queryAll =
        await FirebaseFirestore.instance
            .collection('messages')
            .doc(conversationId)
            .collection('messages')
            .get();

    print('🔥 DEBUG : Tous les messages de $conversationId :');
    for (final doc in queryAll.docs) {
      final data = doc.data();
      print(
        '→ ${doc.id} | senderId: ${data['senderId']} | isRead: ${data['isRead']}',
      );
    }

    final unreadQuery =
        await FirebaseFirestore.instance
            .collection('messages')
            .doc(conversationId)
            .collection('messages')
            .where('senderId', isNotEqualTo: userId)
            .where('isRead', isEqualTo: false)
            .get();

    print('🟡 Messages à marquer comme lus : ${unreadQuery.docs.length}');

    for (final doc in unreadQuery.docs) {
      await doc.reference.update({'isRead': true});
      print('✅ ${doc.id} mis à jour en isRead: true');
    }
  }

  Future<void> _sendTextMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await _sendMessage(text: text);
    _controller.clear();
    setState(() {
      _replyToMessage = null;
    });
  }

  Future<void> _pickAndSendImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child('chat_images/$fileName');
      final uploadTask = await ref.putFile(file);

      if (uploadTask.state == TaskState.success) {
        final imageUrl = await ref.getDownloadURL();
        await _sendMessage(imageUrl: imageUrl);
        setState(() {
          _replyToMessage = null;
        });
      }
    }
  }

  Future<void> _sendMessage({String? text, String? imageUrl}) async {
    final senderId = FirebaseAuth.instance.currentUser!.uid;
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
      'participants': [widget.userUid, adminUid],
      'lastMessage': text ?? '📷 Image',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    final messagesRef = FirebaseFirestore.instance
        .collection('messages')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.beige),
          centerTitle: true,
          title: Text(
            'Chat avec Chewlin',
            style: TextStyle(
              color: AppColors.beige,
              fontFamily: 'ReginaBlack',
              fontSize: 20,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
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
                      final isUser = senderId == widget.userUid;
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
                            isUser
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
                                isUser
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
                                constraints: const BoxConstraints(
                                  maxWidth: 280,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isUser
                                          ? AppColors.green
                                          : AppColors.black.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.green,
                                    width: isUser ? 0 : 1,
                                  ),
                                ),
                                child:
                                    imageUrl != null
                                        ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
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
                          hintText: 'Écrire votre message...',
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
                      onPressed: _pickAndSendImage,
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: AppColors.beige),
                      onPressed: _sendTextMessage,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
