import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/colors.dart';

class AdminOrderDetailsPage extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const AdminOrderDetailsPage({super.key, required this.orderData});

  @override
  State<AdminOrderDetailsPage> createState() => _AdminOrderDetailsPageState();
}

class _AdminOrderDetailsPageState extends State<AdminOrderDetailsPage> {
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

  Future<void> updateField(String field, dynamic value) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderData['id'])
        .update({field: value});
  }

  Future<void> sendStatusMessage(String status) async {
    final userId = widget.orderData['userId'];
    if (userId == null) return;

    // Rechercher le bon chat dans la collection "messages"
    final query =
        await FirebaseFirestore.instance
            .collection('messages')
            .where('participants', arrayContains: userId)
            .get();

    if (query.docs.isEmpty) return;

    final chatId = query.docs.first.id;

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
          'senderId': 'admin',
          'text': messageText,
          'timestamp': Timestamp.now(),
          'seen': false,
        });

    // Met à jour le champ "lastMessage" dans le chat principal
    await FirebaseFirestore.instance.collection('messages').doc(chatId).update({
      'lastMessage': messageText,
      'updatedAt': Timestamp.now(),
    });
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
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.beige),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.green),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.green, width: 2),
          ),
        ),
        onSubmitted: (value) {
          updateField(field, value);
        },
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
        title: const Text(
          'Détails commande',
          style: TextStyle(fontFamily: 'ReginaBlack', color: AppColors.beige),
        ),
        actions: [
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
                          height: 280,
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
                            setState(() {
                              selectedStatus = newValue;
                            });
                          }
                        },
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
