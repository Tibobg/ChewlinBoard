import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/colors.dart';

class UserOrderDetailsPage extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const UserOrderDetailsPage({super.key, required this.orderData});

  @override
  State<UserOrderDetailsPage> createState() => _UserOrderDetailsPageState();
}

class _UserOrderDetailsPageState extends State<UserOrderDetailsPage> {
  Map<String, dynamic>? boardData;
  late TextEditingController nameController;
  late TextEditingController addressController;
  late TextEditingController priceController;
  bool loading = true;

  @override
  void initState() {
    super.initState();
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
      final doc = await firestore.collection('skateboards').doc(boardId).get();
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

  Widget buildReadOnlyField({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        readOnly: true,
        enabled: false,
        style: const TextStyle(color: AppColors.beige),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.beige),
          disabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.green),
          ),
        ),
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
          'Ma commande',
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
                          height: 450,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 20),
                    buildReadOnlyField(
                      label: "Nom",
                      controller: nameController,
                    ),
                    buildReadOnlyField(
                      label: "Adresse",
                      controller: addressController,
                    ),
                    buildReadOnlyField(
                      label: "Prix (€)",
                      controller: priceController,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Date : $formattedDate",
                      style: const TextStyle(color: AppColors.beige),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Statut : ${widget.orderData['status'] ?? 'Inconnu'}",
                      style: const TextStyle(
                        color: AppColors.beige,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
