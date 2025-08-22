import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chewlin_board/core/firebase_refs.dart';
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
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  String? _replyToMessage;
  String? _editingMessageId;

  late final String chatId;

  @override
  void initState() {
    super.initState();
    final currentUid = firebaseAuth.currentUser!.uid;

    chatId =
        widget.userUid.compareTo(currentUid) < 0
            ? '${widget.userUid}_$currentUid'
            : '${currentUid}_${widget.userUid}';

    firestore.collection('users').doc(currentUid).set({
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    _markMessagesAsRead(chatId, currentUid);
  }

  Future<void> _markMessagesAsRead(String conversationId, String userId) async {
    final query =
        await firestore
            .collection('messages')
            .doc(conversationId)
            .collection('messages')
            .where('senderId', isNotEqualTo: userId)
            .where('isRead', isEqualTo: false)
            .get();

    for (final doc in query.docs) {
      await doc.reference.update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _sendTextMessage(String senderId) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (_editingMessageId != null) {
      await firestore
          .collection('messages')
          .doc(chatId)
          .collection('messages')
          .doc(_editingMessageId)
          .update({'text': text, 'isEdited': true});
      setState(() {
        _editingMessageId = null;
        _controller.clear();
      });
    } else {
      await _sendMessage(chatId: chatId, senderId: senderId, text: text);
      _controller.clear();
      setState(() {
        _replyToMessage = null;
      });
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    final docRef = firestore
        .collection('messages')
        .doc(chatId)
        .collection('messages')
        .doc(messageId);

    final doc = await docRef.get();
    final data = doc.data();

    if (data == null) return;

    final imageUrl = data['imageUrl'];

    if (imageUrl != null && imageUrl.toString().isNotEmpty) {
      try {
        final ref = storage.refFromURL(imageUrl);
        await ref.delete();
      } catch (e) {
        print('Erreur suppression image : $e');
      }
    }

    await docRef.update({
      'text': 'Message supprimé',
      'imageUrl': null,
      'isDeleted': true,
    });
  }

  void _showMessageOptions({
    required String messageId,
    required String text,
    required bool isCurrentUser,
    required bool hasImage,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Répondre'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _replyToMessage = text;
                });
              },
            ),
            if (isCurrentUser && text != 'Message supprimé' && !hasImage)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Modifier'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _editingMessageId = messageId;
                    _controller.text = text;
                  });
                },
              ),
            if (isCurrentUser)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Supprimer'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMessage(messageId);
                },
              ),
          ],
        );
      },
    );
  }

  Future<void> _pickAndSendImage(String senderId) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = storage.ref().child('chat_images/$fileName');
      final uploadTask = await ref.putFile(file);

      if (uploadTask.state == TaskState.success) {
        final imageUrl = await ref.getDownloadURL();

        final messageData = {
          'senderId': senderId,
          'imageUrl': imageUrl,
          'text': '',
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
          'replyTo': _replyToMessage,
        };

        final docRef = firestore.collection('messages').doc(chatId);
        await docRef.collection('messages').add(messageData);

        await docRef.set({
          'participants': [senderId, widget.userUid],
          'lastMessage': '📷 Image',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

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

    final docRef = firestore.collection('messages').doc(chatId);
    await docRef.collection('messages').add(messageData);

    await docRef.set({
      'participants': [senderId, widget.userUid],
      'lastMessage': text ?? '📷 Image',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await firestore.collection('users').doc(senderId).update({
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  String formatTime(DateTime date) {
    return '${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = firebaseAuth.currentUser!.uid;

    final messagesRef = firestore
        .collection('messages')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false);

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.beige),
        centerTitle: true,
        title: Text(
          widget.pseudo,
          style: TextStyle(
            color: AppColors.beige,
            fontFamily: 'ReginaBlack',
            fontSize: 20,
          ),
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
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(
                      _scrollController.position.maxScrollExtent,
                    );
                  }
                });
                DateTime? lastDate;

                return ListView.builder(
                  reverse: false,
                  controller: _scrollController,
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
                    final isRead = data['isRead'] == true;
                    final readAt = (data['readAt'] as Timestamp?)?.toDate();
                    final replyTo = data['replyTo'];

                    final showMeta = index == messages.length - 1;

                    final widgets = <Widget>[];

                    if (timestamp != null &&
                        (lastDate == null ||
                            !isSameDay(timestamp, lastDate!))) {
                      lastDate = timestamp;
                      widgets.add(
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: Text(
                              '${timestamp.day}/${timestamp.month}/${timestamp.year}',
                              style: TextStyle(
                                color: AppColors.beige.withOpacity(0.6),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    widgets.add(
                      Align(
                        alignment:
                            isAdmin
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                        child: GestureDetector(
                          onLongPress: () {
                            _showMessageOptions(
                              messageId: message.id,
                              text: text,
                              isCurrentUser: isAdmin,
                              hasImage: imageUrl != null,
                            );
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
                                margin: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 12,
                                ),
                                padding: const EdgeInsets.all(12),
                                constraints: const BoxConstraints(
                                  maxWidth: 280,
                                ),
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
                              if (data['isEdited'] == true)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                    top: 2,
                                  ),
                                  child: Text(
                                    'Modifié',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                      color: AppColors.beige.withOpacity(0.4),
                                    ),
                                  ),
                                ),

                              if (showMeta && timestamp != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 2,
                                  ),
                                  child: Text(
                                    isAdmin
                                        ? (isRead && readAt != null
                                            ? 'Vu à ${formatTime(readAt.toLocal())}'
                                            : '${formatTime(timestamp.toLocal())} - Envoyé')
                                        : 'Envoyé à ${formatTime(timestamp.toLocal())}',
                                    style: TextStyle(
                                      color: AppColors.beige.withOpacity(0.5),
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );

                    return Column(children: widgets);
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
                    onPressed: () => _pickAndSendImage(currentUid),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: AppColors.beige),
                    onPressed: () => _sendTextMessage(currentUid),
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
