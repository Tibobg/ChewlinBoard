import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../theme/colors.dart';

class AdminOrder {
  final String id;
  final String name;
  final String address;
  final String status;
  final double price;
  final String? imageUrl;
  final DateTime timestamp;

  AdminOrder({
    required this.id,
    required this.name,
    required this.address,
    required this.status,
    required this.price,
    this.imageUrl,
    required this.timestamp,
  });
}

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  String? selectedStatus;

  Future<List<AdminOrder>> fetchOrders() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('orders')
            .orderBy('timestamp', descending: true)
            .get();

    final futures = snapshot.docs.map((doc) async {
      final data = doc.data();
      final skateboardId = data['skateboardId'];

      String? imageUrl;
      if (skateboardId != null) {
        final boardDoc =
            await FirebaseFirestore.instance
                .collection('skateboards')
                .doc(skateboardId)
                .get();
        imageUrl = boardDoc.data()?['imageUrl'];
      }

      return AdminOrder(
        id: doc.id,
        name: data['name'] ?? 'Inconnu',
        address: data['address'] ?? 'Adresse inconnue',
        status: data['status'] ?? 'payée',
        price: (data['price'] ?? 0).toDouble(),
        imageUrl: imageUrl,
        timestamp: (data['timestamp'] as Timestamp).toDate(),
      );
    });

    return await Future.wait(futures);
  }

  void showOrderDetails(BuildContext context, AdminOrder order) {
    String selectedStatus = order.status;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Commande de ${order.name}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.beige,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Adresse : ${order.address}',
                style: const TextStyle(color: AppColors.beige),
              ),
              const SizedBox(height: 10),
              Text(
                'Prix : ${order.price} €',
                style: const TextStyle(color: AppColors.beige),
              ),
              const SizedBox(height: 15),
              const Text('Statut :', style: TextStyle(color: AppColors.beige)),
              const SizedBox(height: 5),
              DropdownButton<String>(
                value: selectedStatus,
                dropdownColor: AppColors.black,
                style: const TextStyle(color: AppColors.beige),
                items: const [
                  DropdownMenuItem(value: 'payée', child: Text('💰 Payée')),
                  DropdownMenuItem(
                    value: 'préparée',
                    child: Text('📦 Préparée'),
                  ),
                  DropdownMenuItem(
                    value: 'expédiée',
                    child: Text('🚚 Expédiée'),
                  ),
                  DropdownMenuItem(value: 'livrée', child: Text('📬 Livrée')),
                ],
                onChanged: (newStatus) async {
                  if (newStatus != null) {
                    await FirebaseFirestore.instance
                        .collection('orders')
                        .doc(order.id)
                        .update({'status': newStatus});
                    Navigator.pop(context);
                    setState(() {});
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Commandes',
          style: TextStyle(
            fontFamily: 'ReginaBlack',
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.beige,
      ),
      body: FutureBuilder<List<AdminOrder>>(
        future: fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.green),
            );
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erreur de chargement'));
          }

          final orders = snapshot.data!;
          final filteredOrders =
              selectedStatus == null
                  ? orders
                  : orders.where((o) => o.status == selectedStatus).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButton<String?>(
                value: selectedStatus,
                hint: const Text(
                  'Filtrer par statut',
                  style: TextStyle(color: AppColors.beige),
                ),
                dropdownColor: AppColors.black,
                iconEnabledColor: AppColors.beige,
                style: const TextStyle(color: AppColors.beige),
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: null, child: Text('Tous')),
                  DropdownMenuItem(value: 'payée', child: Text('💰 Payée')),
                  DropdownMenuItem(
                    value: 'préparée',
                    child: Text('📦 Préparée'),
                  ),
                  DropdownMenuItem(
                    value: 'expédiée',
                    child: Text('🚚 Expédiée'),
                  ),
                  DropdownMenuItem(value: 'livrée', child: Text('📬 Livrée')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              ...filteredOrders.map((order) {
                final formattedDate = DateFormat(
                  'dd/MM/yyyy à HH:mm',
                ).format(order.timestamp);
                return Container(
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
                            order.imageUrl != null
                                ? Image.network(
                                  order.imageUrl!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                )
                                : Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.image_not_supported),
                                ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.name,
                              style: const TextStyle(
                                color: AppColors.beige,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Text(
                              'Statut : ${order.status}',
                              style: const TextStyle(
                                color: AppColors.beige,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Text(
                              'Prix : ${order.price} €',
                              style: const TextStyle(
                                color: AppColors.beige,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Text(
                              'Commandé le : $formattedDate',
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
                        icon: const Icon(
                          Icons.more_vert,
                          color: AppColors.beige,
                        ),
                        onPressed: () => showOrderDetails(context, order),
                      ),
                    ],
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
