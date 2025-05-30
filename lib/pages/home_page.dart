import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/colors.dart';
import '../widgets/drive_gallery.dart';
import '../widgets/availability_calendar.dart';
import '../widgets/app_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<String?> _getPseudo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    return doc.data()?['pseudo'];
  }

  Map<String, dynamic>? activeOrder;

  @override
  void initState() {
    super.initState();
    fetchActiveOrder();
  }

  Future<void> fetchActiveOrder() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: uid)
            .where('status', whereIn: ['payée', 'préparée', 'expédiée'])
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        activeOrder = snapshot.docs.first.data();
      });
    }
  }

  double getProgressFromStatus(String status) {
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

  Widget buildOrderTrackingBlock() {
    if (activeOrder == null) return const SizedBox.shrink();

    final title = activeOrder!['skateboardTitle'] ?? 'Votre planche';
    final status = activeOrder!['status'] ?? 'En cours';
    final timestamp = (activeOrder!['timestamp'] as Timestamp?)?.toDate();
    final formattedDate =
        timestamp != null
            ? "${timestamp.day}/${timestamp.month}/${timestamp.year}"
            : 'Date inconnue';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Suivi de votre commande",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.beige,
            fontFamily: 'ReginaBlack',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [AppColors.green, AppColors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Planche : $title',
                style: const TextStyle(color: AppColors.beige),
              ),
              Text(
                'Statut : $status',
                style: const TextStyle(color: AppColors.beige),
              ),
              Text(
                'Commande du : $formattedDate',
                style: const TextStyle(color: AppColors.beige),
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: getProgressFromStatus(status),
                backgroundColor: Colors.white24,
                color: AppColors.green,
                minHeight: 8,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SafeArea(
          child: Scrollbar(
            thumbVisibility: true,
            thickness: 4,
            radius: const Radius.circular(10),
            interactive: true,
            scrollbarOrientation: ScrollbarOrientation.right,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppHeader(),
                  const SizedBox(height: 16),
                  buildOrderTrackingBlock(),
                  FutureBuilder<String?>(
                    future: _getPseudo(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Text(
                          'Salut !',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.beige,
                            fontFamily: 'ReginaBlack',
                          ),
                        );
                      }

                      final pseudo = snapshot.data!;
                      return Text(
                        'Salut $pseudo !',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.beige,
                          fontFamily: 'ReginaBlack',
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    "Mes dernières créations",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.beige,
                      fontFamily: 'ReginaBlack',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [AppColors.green, AppColors.black],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const DriveGallery(),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Calendrier de disponibilité",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.beige,
                      fontFamily: 'ReginaBlack',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const AvailabilityCalendar(),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
