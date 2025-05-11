import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/colors.dart';
import '../widgets/drive_gallery.dart';
import '../widgets/availability_calendar.dart';
import '../widgets/app_header.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🎨 Fond personnalisé
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
            trackVisibility: false,
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

                  // 👋 Texte personnalisé
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

                  // Bloc 1 — Galerie
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

                  // Bloc 2 — Calendrier
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

                  // Bloc 3 — Suivi
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
                    height: 80,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [AppColors.green, AppColors.black],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Text(
                      "Fonctionnalité à venir",
                      style: TextStyle(
                        color: AppColors.beige,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
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
