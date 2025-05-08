import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/app_header.dart';
import '../pages/select_board_page.dart';

class ProjectPage extends StatelessWidget {
  const ProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> projects = [
      {
        'name': 'Loaded Vanguard',
        'price': '170€',
        'image':
            'assets/images/skate-sample.jpg', // assure-toi que ce fichier existe !
      },
      {
        'name': 'Loaded Vanguard',
        'price': '170€',
        'image': 'assets/images/skate-sample.jpg',
      },
      {
        'name': 'Loaded Vanguard',
        'price': '170€',
        'image': 'assets/images/skate-sample.jpg',
      },
      {
        'name': 'Loaded Vanguard',
        'price': '170€',
        'image': 'assets/images/skate-sample.jpg',
      },
    ];

    return Stack(
      children: [
        // 🌿 Background
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Text(
                  '${projects.length} projets en cours',
                  style: const TextStyle(fontSize: 14, color: AppColors.beige),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors:
                                index % 2 == 0
                                    ? [AppColors.green, AppColors.black]
                                    : [AppColors.beige, AppColors.black],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          children: [
                            // 🖼️ Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                project['image']!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.error),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            // 📄 Texte
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    project['name']!,
                                    style: const TextStyle(
                                      color: AppColors.beige,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  Text(
                                    'Prix: ${project['price']}',
                                    style: const TextStyle(
                                      color: AppColors.beige,
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // 🗑️ Bouton supprimer
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: AppColors.beige,
                              ),
                              onPressed: () {
                                // logique de suppression à ajouter
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        // ➕ Bouton flottant
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
    );
  }
}
