import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_chat_page.dart';

class AdminOrderDetailsPage extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const AdminOrderDetailsPage({super.key, required this.orderData});

  @override
  State<AdminOrderDetailsPage> createState() => _AdminOrderDetailsPageState();
}

class _AdminOrderDetailsPageState extends State<AdminOrderDetailsPage> {
  String? userPseudo;
  Map<String, dynamic>? boardData;
  late TextEditingController nameController;
  late TextEditingController addressController;
  late TextEditingController priceController;
  String? selectedStatus;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.orderData['status'];
    nameController = TextEditingController(text: widget.orderData['name']);
    addressController = TextEditingController(
      text: widget.orderData['address'],
    );
    priceController = TextEditingController(
      text: widget.orderData['price'].toString(),
    );
    fetchBoard();
    fetchLatestOrder();
    fetchUserPseudo();
  }

  Future<void> _goToChat() async {
    final userId = widget.orderData['userId'];
    if (userId == null) return;

    final adminUid = FirebaseAuth.instance.currentUser!.uid;

    // initialise/merge le doc parent du chat (optionnel mais sûr)
    final chatId =
        userId.compareTo(adminUid) < 0
            ? '${userId}_$adminUid'
            : '${adminUid}_$userId';
    await FirebaseFirestore.instance.collection('messages').doc(chatId).set({
      'participants': [userId, adminUid],
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
                AdminChatPage(userUid: userId, pseudo: userPseudo ?? 'Client'),
      ),
    );
  }

  Future<void> fetchUserPseudo() async {
    final userId = widget.orderData['userId'];
    if (userId != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
      if (doc.exists) {
        setState(() {
          userPseudo = doc.data()?['pseudo'] ?? 'Utilisateur inconnu';
        });
      }
    }
  }

  Future<void> fetchBoard() async {
    final boardId = widget.orderData['skateboardId'];
    if (boardId != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('skateboards')
              .doc(boardId)
              .get();
      if (doc.exists) {
        setState(() {
          boardData = doc.data();
        });
      }
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> fetchLatestOrder() async {
    final orderId = widget.orderData['id'];
    final doc =
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        nameController.text = data['name'] ?? '';
        addressController.text = data['address'] ?? '';
        priceController.text = data['price'].toString();
        selectedStatus = data['status'] ?? selectedStatus;
      });
    }
  }

  Future<void> updateField(String field, dynamic value) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderData['id'])
        .update({field: value});
  }

  Future<void> sendStatusMessage(String status) async {
    final userId = widget.orderData['userId'];
    if (userId == null) return;

    final adminUid = FirebaseAuth.instance.currentUser!.uid;
    final chatId =
        userId.compareTo(adminUid) < 0
            ? '${userId}_$adminUid'
            : '${adminUid}_$userId';

    String messageText;
    switch (status) {
      case 'payée':
        messageText = "💰 Paiement confirmé pour votre commande.";
        break;
      case 'préparée':
        messageText = "🛠️ Votre planche est en cours de préparation.";
        break;
      case 'expédiée':
        messageText = "🚚 Votre planche a été expédiée.";
        break;
      case 'livrée':
        messageText =
            "📬 Votre commande a été livrée. Merci pour votre confiance !";
        break;
      default:
        return;
    }

    await FirebaseFirestore.instance
        .collection('messages')
        .doc(chatId)
        .collection('messages')
        .add({
          'senderId': adminUid,
          'text': messageText,
          'createdAt': Timestamp.now(),
          'isRead': false,
        });

    await FirebaseFirestore.instance.collection('messages').doc(chatId).set({
      'participants': [userId, adminUid],
      'lastMessage': messageText,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteOrder() async {
    final boardId = widget.orderData['skateboardId'];
    final orderId = widget.orderData['id'];

    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .delete();
      if (boardId != null) {
        await FirebaseFirestore.instance
            .collection('skateboards')
            .doc(boardId)
            .update({'isSold': false});
      }
      await sendCancelMessage();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Commande supprimée.")));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erreur : $e")));
      }
    }
  }

  Future<void> sendCancelMessage() async {
    final adminUid = FirebaseAuth.instance.currentUser!.uid;
    final userId = widget.orderData['userId'];

    final chatId =
        userId.compareTo(adminUid) < 0
            ? '${userId}_$adminUid'
            : '${adminUid}_$userId';
    final messageText = '❌ Votre commande a été annulée par Chewlin.';

    await FirebaseFirestore.instance
        .collection('messages')
        .doc(chatId)
        .collection('messages')
        .add({
          'senderId': adminUid,
          'text': messageText,
          'createdAt': Timestamp.now(),
          'isRead': false,
        });

    await FirebaseFirestore.instance.collection('messages').doc(chatId).set({
      'participants': [userId, adminUid],
      'lastMessage': messageText,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  Widget buildEditableField({
    required String label,
    required TextEditingController controller,
    required String field,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: AppColors.beige),
        decoration: const InputDecoration(
          labelStyle: TextStyle(color: AppColors.beige),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.green),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.green, width: 2),
          ),
        ).copyWith(labelText: label),
        onSubmitted: (value) => updateField(field, value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.orderData;
    final date = (order['timestamp'] as Timestamp?)?.toDate();
    final formattedDate =
        date != null ? DateFormat('dd/MM/yyyy HH:mm').format(date) : 'Inconnue';

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        centerTitle: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Détails commande',
              style: TextStyle(
                fontFamily: 'ReginaBlack',
                color: AppColors.beige,
              ),
            ),
            if (userPseudo != null)
              Text(
                '$userPseudo',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.beige,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Ouvrir la discussion',
            icon: const Icon(Icons.message, color: AppColors.beige),
            onPressed: _goToChat,
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.beige),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body:
          loading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.green),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (boardData != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          boardData!['imageUrl'] ?? '',
                          height: 450,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 20),
                    buildEditableField(
                      label: "Nom du client",
                      controller: nameController,
                      field: 'name',
                    ),
                    buildEditableField(
                      label: "Adresse",
                      controller: addressController,
                      field: 'address',
                    ),
                    buildEditableField(
                      label: "Prix (€)",
                      controller: priceController,
                      field: 'price',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Date : $formattedDate",
                      style: const TextStyle(color: AppColors.beige),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Statut de la commande :",
                      style: TextStyle(color: AppColors.beige, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        dropdownColor: AppColors.black,
                        value: selectedStatus,
                        isExpanded: true,
                        style: const TextStyle(color: AppColors.beige),
                        iconEnabledColor: AppColors.green,
                        underline: Container(),
                        items:
                            ['payée', 'préparée', 'expédiée', 'livrée']
                                .map(
                                  (status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  ),
                                )
                                .toList(),
                        onChanged: (newValue) async {
                          if (newValue != null) {
                            await updateField('status', newValue);
                            await sendStatusMessage(newValue);
                            setState(() => selectedStatus = newValue);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final updates = <String>[];
                          final orderId = widget.orderData['id'];
                          final userId = widget.orderData['userId'];
                          final adminUid =
                              FirebaseAuth.instance.currentUser!.uid;
                          final docRef = FirebaseFirestore.instance
                              .collection('orders')
                              .doc(orderId);

                          final currentData = await docRef.get().then(
                            (doc) => doc.data() ?? {},
                          );

                          if (nameController.text.trim() !=
                              currentData['name']) {
                            await updateField(
                              'name',
                              nameController.text.trim(),
                            );
                            updates.add('le nom');
                          }
                          if (addressController.text.trim() !=
                              currentData['address']) {
                            await updateField(
                              'address',
                              addressController.text.trim(),
                            );
                            updates.add('l’adresse');
                          }
                          if (priceController.text.trim() !=
                              currentData['price'].toString()) {
                            await updateField(
                              'price',
                              priceController.text.trim(),
                            );
                            updates.add('le prix');
                          }

                          if (updates.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Aucune modification détectée.'),
                              ),
                            );
                            return;
                          }

                          if (userId != null) {
                            final chatId =
                                userId.compareTo(adminUid) < 0
                                    ? '${userId}_$adminUid'
                                    : '${adminUid}_$userId';
                            final messageText =
                                updates.length == 1
                                    ? '📝 ${updates.first} de votre commande a été modifié par Chewlin.'
                                    : '📝 ${updates.join(', ')} de votre commande ont été modifiés par Chewlin.';

                            await FirebaseFirestore.instance
                                .collection('messages')
                                .doc(chatId)
                                .collection('messages')
                                .add({
                                  'senderId': adminUid,
                                  'text': messageText,
                                  'createdAt': Timestamp.now(),
                                  'isRead': false,
                                });

                            await FirebaseFirestore.instance
                                .collection('messages')
                                .doc(chatId)
                                .set({
                                  'participants': [userId, adminUid],
                                  'lastMessage': messageText,
                                  'updatedAt': Timestamp.now(),
                                }, SetOptions(merge: true));
                          }

                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Modifications enregistrées.'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text(
                          'Enregistrer les modifications',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: deleteOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        icon: const Icon(Icons.delete, color: Colors.white),
                        label: const Text(
                          'Supprimer la commande',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
