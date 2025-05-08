import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/app_header.dart';
import 'recap_board_page.dart';

class EditorBoardPage extends StatefulWidget {
  final File userImage;
  final String description;

  const EditorBoardPage({
    super.key,
    required this.userImage,
    required this.description,
  });

  @override
  State<EditorBoardPage> createState() => _EditorBoardPageState();
}

class _EditorBoardPageState extends State<EditorBoardPage> {
  Offset _imageOffset = const Offset(0, 0);
  double _scale = 1.0;
  final double _imageBaseScaleFactor = 0.25; // 🔧 Ajuste cette valeur !

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
                  const AppHeader(showBackButton: true),
                  const SizedBox(height: 16),
                  const Text(
                    'Placer le design',
                    style: TextStyle(
                      color: AppColors.beige,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ReginaBlack',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 🛹 Zone de design
                  Expanded(
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/mockup-skate.png',
                            height: 400,
                          ),
                          Transform.translate(
                            offset: _imageOffset,
                            child: Transform.scale(
                              scale: _scale * _imageBaseScaleFactor,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  setState(() {
                                    _imageOffset += details.delta;
                                  });
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    widget.userImage,
                                    fit: BoxFit.cover,
                                    opacity: const AlwaysStoppedAnimation(0.85),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Column(
                    children: [
                      const Text(
                        'Zoom',
                        style: TextStyle(
                          color: AppColors.beige,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Slider(
                        value: _scale,
                        min: 0.5,
                        max: 2.5,
                        activeColor: AppColors.green,
                        inactiveColor: AppColors.beige,
                        onChanged: (value) {
                          setState(() {
                            _scale = value;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  // ✅ Suivant
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => RecapPage(
                                userImage: widget.userImage,
                                description: widget.description,
                                imageOffset: _imageOffset,
                                imageScale: _scale,
                              ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Suivant',
                      style: TextStyle(
                        color: AppColors.beige,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
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
