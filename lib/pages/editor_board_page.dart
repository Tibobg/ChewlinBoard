import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/app_header.dart';
import 'recap_board_page.dart';
import '../models/project_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/customize_board_page.dart';

class EditorBoardPage extends StatefulWidget {
  final ProjectData project;

  const EditorBoardPage({super.key, required this.project});

  @override
  State<EditorBoardPage> createState() => _EditorBoardPageState();
}

class _EditorBoardPageState extends State<EditorBoardPage> {
  Offset _imageOffset = const Offset(0, 0);
  double _scale = 1.0;
  final double _imageBaseScaleFactor = 0.25;

  @override
  Widget build(BuildContext context) {
    final String imagePath = widget.project.imagePaths?.first ?? '';

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Future.microtask(() {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CustomizeBoardPage(project: widget.project),
            ),
          );
        });
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
                      'Placer le design',
                      style: TextStyle(
                        color: AppColors.beige,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ReginaBlack',
                      ),
                    ),
                    const SizedBox(height: 16),

                    Expanded(
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/images/mockup-skate.png',
                              height: 400,
                            ),
                            if (imagePath.isNotEmpty)
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
                                      child: Image.network(
                                        imagePath,
                                        fit: BoxFit.cover,
                                        opacity: const AlwaysStoppedAnimation(
                                          0.85,
                                        ),
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

                    ElevatedButton(
                      onPressed: () async {
                        widget.project.imagePosition = _imageOffset;
                        widget.project.imageScale = _scale;

                        if (widget.project.projectId != null) {
                          await FirebaseFirestore.instance
                              .collection('projects')
                              .doc(widget.project.projectId)
                              .set({
                                'lastStep': 'editor',
                                'imagePosition': {
                                  'dx': _imageOffset.dx,
                                  'dy': _imageOffset.dy,
                                },
                                'imageScale': _scale,
                              }, SetOptions(merge: true));
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecapPage(project: widget.project),
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
      ),
    );
  }
}
