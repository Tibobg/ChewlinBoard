import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../navigation/bottom_nav_container.dart';

class UserChatPage extends StatefulWidget {
  const UserChatPage({super.key});

  @override
  State<UserChatPage> createState() => _UserChatPageState();
}

class _UserChatPageState extends State<UserChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String adminUid = 'wjGx853IYFTe2hrtNxrSvTKc23h1';
  String? _replyToMessage;
  String? _editingMessageId;
  late final String chatId;
  late final String currentUid;

  @override
  void initState() {
    super.initState();
    currentUid = FirebaseAuth.instance.currentUser!.uid;

    chatId =
        currentUid.compareTo(adminUid) < 0
            ? '${currentUid}_$adminUid'
            : '${adminUid}_$currentUid';

    FirebaseFirestore.instance.collection('users').doc(currentUid).set({
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    _markMessagesAsRead(chatId, currentUid);
  }

  Future<void> _markMessagesAsRead(String conversationId, String userId) async {
    final unreadQuery =
        await FirebaseFirestore.instance
            .collection('messages')
            .doc(conversationId)
            .collection('messages')
            .where('senderId', isNotEqualTo: userId)
            .where('isRead', isEqualTo: false)
            .get();

    for (final doc in unreadQuery.docs) {
      await doc.reference.update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _sendTextMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (_editingMessageId != null) {
      await FirebaseFirestore.instance
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
      await _sendMessage(text: text);
      _controller.clear();
      setState(() {
        _replyToMessage = null;
      });
    }
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

        final senderId = FirebaseAuth.instance.currentUser!.uid;

        final messageData = {
          'senderId': senderId,
          'imageUrl': imageUrl,
          'text': '',
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
          'replyTo': _replyToMessage,
        };

        final docRef = FirebaseFirestore.instance
            .collection('messages')
            .doc(chatId);
        await docRef.collection('messages').add(messageData);

        await docRef.set({
          'participants': [currentUid, senderId],
          'lastMessage': '📷 Image',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

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
      'participants': [currentUid, adminUid],
      'lastMessage': text ?? '📷 Image',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _deleteMessage(String messageId) async {
    final docRef = FirebaseFirestore.instance
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
        final ref = FirebaseStorage.instance.refFromURL(imageUrl);
        await ref.delete(); // suppression de l’image du Storage
      } catch (e) {
        print('Erreur lors de la suppression de l’image : $e');
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
            if (isCurrentUser && !hasImage && text != 'Message supprimé')
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

  String formatTime(DateTime date) {
    return '${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final messagesRef = FirebaseFirestore.instance
        .collection('messages')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false);

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const BottomNavContainer(initialIndex: 0),
          ),
        );
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
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const BottomNavContainer(initialIndex: 0),
                ),
              );
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
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(
                        _scrollController.position.maxScrollExtent,
                      );
                    }
                  });
                  DateTime? lastDate;

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: false,
                    physics: const BouncingScrollPhysics(),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final data = message.data() as Map<String, dynamic>;
                      final text = data['text'] ?? '';
                      final imageUrl = data['imageUrl'];
                      final senderId = data['senderId'];
                      final currentUid = FirebaseAuth.instance.currentUser!.uid;
                      final isUser = senderId == currentUid;
                      final isCurrentUser = senderId == currentUid;
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
                              isUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: GestureDetector(
                            onLongPress: () {
                              _showMessageOptions(
                                messageId: message.id,
                                text: text,
                                isCurrentUser: isCurrentUser,
                                hasImage: imageUrl != null,
                              );
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
                                      isCurrentUser
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
