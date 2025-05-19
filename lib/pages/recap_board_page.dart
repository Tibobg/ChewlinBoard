import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../navigation/bottom_nav_container.dart';
import '../theme/colors.dart';
import '../widgets/app_header.dart';
import '../models/project_data.dart';

class RecapPage extends StatelessWidget {
  final ProjectData project;

  const RecapPage({super.key, required this.project});

  Future<void> _saveProjectToFirestore(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Utilisateur non connecté.")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('projects')
          .add(project.toMap(user.uid));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Commande confirmée et enregistrée !")),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => BottomNavContainer(initialIndex: 2)),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur : $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = project.imagePaths?.first;
    final imageOffset = project.imagePosition ?? Offset.zero;
    final imageScale = project.imageScale ?? 1.0;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const AppHeader(showBackButton: true),
                    const SizedBox(height: 16),
                    const Text(
                      'Récapitulatif',
                      style: TextStyle(
                        color: AppColors.beige,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ReginaBlack',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/mockup-skate.png',
                                  fit: BoxFit.contain,
                                ),
                                if (imagePath != null)
                                  Transform.translate(
                                    offset: imageOffset,
                                    child: Transform.scale(
                                      scale: imageScale,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          imagePath,
                                          height: 200,
                                          opacity: const AlwaysStoppedAnimation(
                                            0.85,
                                          ),
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.broken_image,
                                                    color: Colors.red,
                                                  ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.black.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Planche : ${project.boardName}",
                                      style: const TextStyle(
                                        color: AppColors.beige,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Prix : ${project.boardPrice}",
                                      style: const TextStyle(
                                        color: AppColors.beige,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      "Description :",
                                      style: TextStyle(
                                        color: AppColors.beige,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      project.description ?? '',
                                      style: const TextStyle(
                                        color: AppColors.beige,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _saveProjectToFirestore(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 14,
                        ),
                      ),
                      child: const Text(
                        'Confirmer',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.beige,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
