import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../theme/colors.dart';
import '../pagesAdmin/admin_order_details_page.dart';

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
          final filteredOrders = orders;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 16),
              ...filteredOrders.map((order) {
                final formattedDate = DateFormat(
                  'dd/MM/yyyy à HH:mm',
                ).format(order.timestamp);
                return GestureDetector(
                  onTap: () async {
                    final orderDoc =
                        await FirebaseFirestore.instance
                            .collection('orders')
                            .doc(order.id)
                            .get();

                    if (!orderDoc.exists) return;

                    final data = orderDoc.data()!;
                    data['id'] = order.id;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminOrderDetailsPage(orderData: data),
                      ),
                    );
                  },
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
