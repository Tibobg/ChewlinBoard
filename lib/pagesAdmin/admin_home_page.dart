import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../theme/colors.dart';
import 'admin_chat_page.dart';
import 'admin_order_details_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  List<Map<String, dynamic>> newMessages = [];
  List<Map<String, dynamic>> newOrders = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchUpdates();
  }

  Future<void> fetchUpdates() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final messagesSnapshot =
        await FirebaseFirestore.instance.collection('messages').get();

    List<Map<String, dynamic>> unseen = [];

    for (var doc in messagesSnapshot.docs) {
      final data = doc.data();
      if (!data.containsKey('participants')) continue;

      final chatId = doc.id;
      final participants = List<String>.from(data['participants']);
      final otherUid = participants.firstWhere((uid) => uid != currentUid);

      final unreadSnap =
          await FirebaseFirestore.instance
              .collection('messages')
              .doc(chatId)
              .collection('messages')
              .where('senderId', isEqualTo: otherUid)
              .where('isRead', isEqualTo: false)
              .limit(1)
              .get();

      if (unreadSnap.docs.isNotEmpty) {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(otherUid)
                .get();
        final pseudo = userDoc['pseudo'] ?? 'Utilisateur';
        unseen.add({'pseudo': pseudo, 'chatId': chatId, 'userUid': otherUid});
      }
    }

    final ordersSnap =
        await FirebaseFirestore.instance
            .collection('orders')
            .orderBy('timestamp', descending: true)
            .limit(5)
            .get();

    List<Map<String, dynamic>> recentOrders = [];

    for (var doc in ordersSnap.docs) {
      final data = doc.data();
      final status = data['status'] ?? '';
      if (status == 'payée' || status == 'préparée') {
        recentOrders.add({...data, 'id': doc.id});
      }
    }

    setState(() {
      newMessages = unseen;
      newOrders = recentOrders;
      loading = false;
    });
  }

  Widget buildCard({
    required IconData icon,
    required String title,
    required List<Map<String, dynamic>> items,
    required Color color,
    String emptyText = 'Aucune nouveauté.',
    required void Function(Map<String, dynamic>) onTap,
  }) {
    return Card(
      elevation: 4,
      shadowColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 12),
      color: AppColors.black,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'ReginaBlack',
                    fontSize: 18,
                    color: AppColors.beige,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.beige),
                  const SizedBox(width: 6),
                  Text(emptyText, style: TextStyle(color: AppColors.beige)),
                ],
              )
            else
              ...items
                  .take(3)
                  .map(
                    (item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.fiber_manual_record,
                        size: 10,
                        color: AppColors.green,
                      ),
                      title: Text(
                        item['pseudo'] ?? item['name'],
                        style: const TextStyle(color: AppColors.beige),
                      ),
                      subtitle:
                          item['status'] != null
                              ? Text(
                                "Statut : ${item['status']}",
                                style: TextStyle(
                                  color: AppColors.beige,
                                  fontSize: 12,
                                ),
                              )
                              : null,
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppColors.beige,
                      ),
                      onTap: () => onTap(item),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Accueil Admin',
          style: TextStyle(
            fontFamily: 'ReginaBlack',
            fontSize: 22,
            color: AppColors.beige,
          ),
        ),
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
                    Text(
                      'Bonjour 👋',
                      style: TextStyle(
                        color: AppColors.beige,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      now,
                      style: TextStyle(color: AppColors.beige, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    buildCard(
                      icon: Icons.message,
                      title: 'Nouveaux messages',
                      items: newMessages,
                      color: AppColors.green,
                      onTap: (item) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => AdminChatPage(
                                  userUid: item['userUid'],
                                  pseudo: item['pseudo'],
                                ),
                          ),
                        );
                      },
                    ),
                    buildCard(
                      icon: Icons.shopping_cart,
                      title: 'Commandes récentes',
                      items: newOrders,
                      color: AppColors.green,
                      onTap: (item) async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => AdminOrderDetailsPage(orderData: item),
                          ),
                        );
                        fetchUpdates(); // 🔁
                      },
                    ),
                  ],
                ),
              ),
    );
  }
}
