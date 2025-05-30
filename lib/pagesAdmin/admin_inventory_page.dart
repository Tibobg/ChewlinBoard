import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/colors.dart';

class AdminInventoryPage extends StatefulWidget {
  const AdminInventoryPage({super.key});

  @override
  State<AdminInventoryPage> createState() => _AdminInventoryPageState();
}

class _AdminInventoryPageState extends State<AdminInventoryPage> {
  String selectedFilter = 'all';

  Query getFilteredQuery() {
    final collection = FirebaseFirestore.instance.collection('skateboards');
    switch (selectedFilter) {
      case 'newest':
        return collection.orderBy('createdAt', descending: true);
      case 'oldest':
        return collection.orderBy('createdAt', descending: false);
      case 'titleAsc':
        return collection.orderBy('title', descending: false);
      case 'titleDesc':
        return collection.orderBy('title', descending: true);
      default:
        return collection.orderBy('createdAt', descending: true);
    }
  }

  bool shouldKeepDocument(Map<String, dynamic> data) {
    if (selectedFilter == 'available') return data['isSold'] == false;
    if (selectedFilter == 'sold') return data['isSold'] == true;
    return true;
  }

  Future<void> toggleSoldStatus(String id, bool currentStatus) async {
    await FirebaseFirestore.instance.collection('skateboards').doc(id).update({
      'isSold': !currentStatus,
    });
  }

  void showEditModal(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    final nameController = TextEditingController(
      text: data['name'] ?? data['skateboardName'] ?? '',
    );
    final priceController = TextEditingController(
      text: (data['price'] ?? '').toString(),
    );
    final imageUrl = data['imageUrl'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => Padding(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Modifier la planche",
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.beige,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: AppColors.beige),
                    decoration: const InputDecoration(
                      labelText: 'Nom',
                      labelStyle: TextStyle(color: AppColors.beige),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.beige),
                      ),
                    ),
                  ),
                  TextField(
                    controller: priceController,
                    style: const TextStyle(color: AppColors.beige),
                    decoration: const InputDecoration(
                      labelText: 'Prix (€ ou texte)',
                      labelStyle: TextStyle(color: AppColors.beige),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.beige),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(imageUrl, height: 120),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                    ),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('skateboards')
                          .doc(docId)
                          .update({
                            'name': nameController.text.trim(),
                            'price': priceController.text.trim(),
                          });
                      Navigator.pop(ctx);
                      setState(() {});
                    },
                    child: const Text(
                      "Enregistrer",
                      style: TextStyle(color: AppColors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Inventaire',
          style: TextStyle(
            fontFamily: 'ReginaBlack',
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.beige,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getFilteredQuery().snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.green),
            );
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erreur de chargement'));
          }

          final boards =
              snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return shouldKeepDocument(data);
              }).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButton<String>(
                value: selectedFilter,
                dropdownColor: AppColors.black,
                iconEnabledColor: AppColors.beige,
                style: const TextStyle(color: AppColors.beige),
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('Tous')),
                  DropdownMenuItem(
                    value: 'available',
                    child: Text('Disponibles'),
                  ),
                  DropdownMenuItem(value: 'sold', child: Text('Vendus')),
                  DropdownMenuItem(
                    value: 'titleAsc',
                    child: Text('Plus anciens'),
                  ),
                  DropdownMenuItem(
                    value: 'titleDesc',
                    child: Text('Plus récents'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedFilter = value!;
                  });
                },
              ),
              const SizedBox(height: 12),
              ...boards.map((doc) {
                final board = doc.data() as Map<String, dynamic>;
                final docId = doc.id;
                final name =
                    board['name'] ??
                    board['skateboardName'] ??
                    board['title'] ??
                    'Sans nom';
                final price = board['price'] ?? '???';
                final isSold = board['isSold'] == true;
                final imageUrl = board['imageUrl'];

                return GestureDetector(
                  onTap: () => showEditModal(context, docId, board),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [AppColors.green, AppColors.black],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child:
                              imageUrl != null
                                  ? Image.network(
                                    imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                  : Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey.shade300,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                    ),
                                  ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: AppColors.beige,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Text(
                                'Prix : $price €',
                                style: const TextStyle(
                                  color: AppColors.beige,
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Text(
                                isSold
                                    ? 'État : 🟥 Vendu'
                                    : 'État : 🟩 Disponible',
                                style: const TextStyle(
                                  color: AppColors.beige,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isSold ? Icons.undo : Icons.check_circle,
                            color: AppColors.beige,
                          ),
                          onPressed: () => toggleSoldStatus(docId, isSold),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
