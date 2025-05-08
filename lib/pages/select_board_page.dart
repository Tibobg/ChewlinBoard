import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../theme/colors.dart';
import '../widgets/app_header.dart';
import 'customize_board_page.dart';

class SelectBoardPage extends StatefulWidget {
  const SelectBoardPage({super.key});

  @override
  State<SelectBoardPage> createState() => _SelectBoardPageState();
}

class _SelectBoardPageState extends State<SelectBoardPage> {
  int _currentIndex = 0;

  final List<Map<String, String>> _boards = [
    {'name': 'Landyachtz Board', 'model': 'assets/models/skateboard.glb'},
    // Tu peux ajouter d'autres boards ici
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 🌿 Fond feuillage
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
                  const AppHeader(showBackButton: true), // ✅ Utilisation ici
                  const SizedBox(height: 16),
                  const Text(
                    'Les planches',
                    style: TextStyle(
                      color: AppColors.beige,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ReginaBlack',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _boards[_currentIndex]['name']!,
                    style: const TextStyle(
                      color: AppColors.beige,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 🛹 Carte contenant le modèle 3D
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.beige.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: ModelViewer(
                              src: 'assets/models/skateboard.glb',
                              alt: "Skateboard 3D",
                              autoRotate: true,
                              cameraControls: false,
                              disableZoom: true,
                              interactionPrompt: InteractionPrompt.none,
                              cameraOrbit: '0deg 90deg 100%',
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: AppColors.beige,
                            ),
                            onPressed: () {
                              // navigation modèle précédent
                            },
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.beige,
                            ),
                            onPressed: () {
                              // navigation modèle suivant
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => CustomizeBoardPage(
                                boardName: _boards[_currentIndex]['name']!,
                              ),
                        ),
                      );
                    },

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
                      'Valider',
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
    );
  }
}
