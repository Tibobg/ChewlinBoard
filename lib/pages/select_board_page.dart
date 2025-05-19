import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../theme/colors.dart';
import '../widgets/app_header.dart';
import 'customize_board_page.dart';
import '../models/project_data.dart'; // à créer si pas encore fait

class SelectBoardPage extends StatefulWidget {
  const SelectBoardPage({super.key});

  @override
  State<SelectBoardPage> createState() => _SelectBoardPageState();
}

class _SelectBoardPageState extends State<SelectBoardPage> {
  int _currentIndex = 0;

  final List<Map<String, String>> _boards = [
    {
      'name': 'Landyachtz Board',
      'model': 'assets/models/skateboard.glb',
      'price': '90€',
    },
    {'name': 'ST1', 'model': 'assets/models/ST1.glb', 'price': '110€'},
  ];

  void _changeBoard(int direction) {
    setState(() {
      _currentIndex = (_currentIndex + direction) % _boards.length;
      if (_currentIndex < 0) _currentIndex = _boards.length - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final board = _boards[_currentIndex];

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
                      board['name']!,
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
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 40),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.beige.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: ModelViewer(
                                    key: ValueKey(board['model']),
                                    src: board['model']!,
                                    alt: board['name']!,
                                    autoRotate: true,
                                    cameraControls: false,
                                    disableZoom: true,
                                    interactionPrompt: InteractionPrompt.none,
                                    cameraOrbit: '0deg 90deg 100%',
                                    backgroundColor: Colors.transparent,
                                  ),
                                ),
                                Positioned(
                                  bottom: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade700,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      board['price']!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: AppColors.beige,
                              ),
                              onPressed: () => _changeBoard(-1),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                                color: AppColors.beige,
                              ),
                              onPressed: () => _changeBoard(1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final project = ProjectData(
                          boardName: board['name']!,
                          boardPrice: board['price']!,
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => CustomizeBoardPage(project: project),
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
      ),
    );
  }
}
