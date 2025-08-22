import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../auth/login_page.dart';
import 'terms_of_use_page.dart';
import '../../theme/colors.dart';
import 'user_order_details_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? pseudo;
  String? email;
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchOrders();
  }

  Future<void> fetchUserData() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return;
    email = user.email;

    final doc = await firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      setState(() {
        pseudo = doc.data()?['pseudo'] ?? 'Utilisateur';
      });
    }
  }

  Future<void> fetchOrders() async {
    final uid = firebaseAuth.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot =
          await firestore
              .collection('orders')
              .where('userId', isEqualTo: uid)
              .orderBy('timestamp', descending: true)
              .get();

      final docs =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

      setState(() {
        orders = docs;
      });
    } catch (e) {
      print("Erreur lors de la récupération des commandes: $e");
    }
  }

  dynamic convertTimestamps(dynamic data) {
    if (data is Map) {
      return data.map((key, value) => MapEntry(key, convertTimestamps(value)));
    } else if (data is List) {
      return data.map((item) => convertTimestamps(item)).toList();
    } else if (data is Timestamp) {
      return data.toDate().toIso8601String();
    } else {
      return data;
    }
  }

  Future<void> exportUserData() async {
    final uid = firebaseAuth.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await firestore.collection('users').doc(uid).get();
    final userData = userDoc.data() ?? {};

    final projectsSnap =
        await firestore
            .collection('projects')
            .where('userId', isEqualTo: uid)
            .get();
    final projectData =
        projectsSnap.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();

    final exportData = {'utilisateur': userData, 'projets': projectData};

    final cleanedData = convertTimestamps(exportData);
    final jsonStr = const JsonEncoder.withIndent('  ').convert(cleanedData);

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filename = 'chewlinboard_export_$timestamp.json';

    final directory = Directory('/storage/emulated/0/Download');
    final file = File('${directory.path}/$filename');

    await file.writeAsString(jsonStr);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Données exportées : ${file.path}')),
      );
    }
  }

  double getProgress(String status) {
    switch (status) {
      case 'payée':
        return 0.25;
      case 'préparée':
        return 0.5;
      case 'expédiée':
        return 0.75;
      case 'livrée':
        return 1.0;
      default:
        return 0.0;
    }
  }

  Widget buildOrderCard(Map<String, dynamic> order) {
    final date = (order['timestamp'] as Timestamp?)?.toDate();
    final formattedDate =
        date != null
            ? "${date.day}/${date.month}/${date.year}"
            : "Date inconnue";
    final title = order['skateboardTitle'] ?? "Planche";
    final price = order['price'] ?? "€";
    final status = order['status'] ?? "En cours";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserOrderDetailsPage(orderData: order),
          ),
        );
      },

      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.green.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "📅 $formattedDate",
              style: const TextStyle(color: AppColors.beige),
            ),
            Text("🛹 $title", style: const TextStyle(color: AppColors.beige)),
            Text("💸 $price €", style: const TextStyle(color: AppColors.beige)),
            Text(
              "⏳ Statut : $status",
              style: const TextStyle(color: AppColors.beige),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: getProgress(status),
              minHeight: 6,
              color: AppColors.green,
              backgroundColor: Colors.white24,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        title: const Text(
          'Profil',
          style: TextStyle(fontFamily: 'ReginaBlack', color: AppColors.beige),
        ),
        centerTitle: true,
        actions: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.policy, color: AppColors.beige),
                tooltip: 'Conditions Générales d’Utilisation',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TermsOfUsePage()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.download, color: AppColors.beige),
                tooltip: 'Exporter mes données',
                onPressed: exportUserData,
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (pseudo != null || email != null) ...[
                  Text(
                    "Pseudo: $pseudo",
                    style: const TextStyle(color: AppColors.beige),
                  ),
                  Text(
                    "Email: $email",
                    style: const TextStyle(color: AppColors.beige),
                  ),
                  const SizedBox(height: 20),
                ],
                const Text(
                  '📋 Mes commandes',
                  style: TextStyle(
                    fontSize: 20,
                    color: AppColors.beige,
                    fontFamily: 'ReginaBlack',
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child:
                      orders.isEmpty
                          ? const Center(
                            child: Text(
                              'Aucune commande trouvée.',
                              style: TextStyle(color: AppColors.beige),
                            ),
                          )
                          : ListView.builder(
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              return buildOrderCard(orders[index]);
                            },
                          ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                await authService.signOut();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              child: const Text(
                'Se déconnecter',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
