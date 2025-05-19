import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/colors.dart';
import '../widgets/app_header.dart';
import '../pages/select_board_page.dart';

class ProjectPage extends StatelessWidget {
  const ProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.green),
            ),
          );
        }

        final userId = userSnapshot.data!.uid;

        return Scaffold(
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
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('projects')
                      .where('userId', isEqualTo: userId)
                      .orderBy('createdAt', descending: true)
                      .snapshots(includeMetadataChanges: true),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.green,
                        ),
                      );
                    }

                    final projects = snapshot.data?.docs ?? [];

                    return ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      children: [
                        const AppHeader(),
                        const SizedBox(height: 12),
                        const Text(
                          'Vos projets',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.beige,
                            fontFamily: 'ReginaBlack',
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (projects.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text(
                                'Aucun projet pour l’instant',
                                style: TextStyle(color: AppColors.beige),
                              ),
                            ),
                          ),
                        if (projects.isNotEmpty)
                          ...projects.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final name = data['boardName'] ?? 'Sans nom';
                            final price = data['boardPrice'] ?? '???';
                            final image =
                                (data['imagePaths'] != null &&
                                        data['imagePaths'].isNotEmpty)
                                    ? data['imagePaths'][0]
                                    : null;

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  colors:
                                      projects.indexOf(doc) % 2 == 0
                                          ? [AppColors.green, AppColors.black]
                                          : [AppColors.beige, AppColors.black],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child:
                                        image != null
                                            ? Image.network(
                                              image,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const Icon(
                                                    Icons.broken_image,
                                                    color: Colors.red,
                                                  ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          'Prix: $price',
                                          style: const TextStyle(
                                            color: AppColors.beige,
                                            fontSize: 14,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: AppColors.beige,
                                    ),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder:
                                            (ctx) => AlertDialog(
                                              title: const Text(
                                                "Supprimer ce projet ?",
                                              ),
                                              content: const Text(
                                                "Cette action est irréversible.",
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        ctx,
                                                        false,
                                                      ),
                                                  child: const Text("Annuler"),
                                                ),
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        ctx,
                                                        true,
                                                      ),
                                                  child: const Text(
                                                    "Supprimer",
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                      );

                                      if (confirm == true) {
                                        await FirebaseFirestore.instance
                                            .collection('projects')
                                            .doc(doc.id)
                                            .delete();

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text("Projet supprimé."),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                        const SizedBox(height: 100),
                      ],
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: FloatingActionButton(
                  backgroundColor: AppColors.green,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SelectBoardPage(),
                      ),
                    );
                  },
                  child: const Icon(Icons.add, color: AppColors.beige),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
