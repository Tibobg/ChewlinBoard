import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/app_header.dart';

class RecapPage extends StatelessWidget {
  final File userImage;
  final String description;
  final Offset imageOffset;
  final double imageScale;

  const RecapPage({
    super.key,
    required this.userImage,
    required this.description,
    this.imageOffset = Offset.zero,
    this.imageScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            //Fond feuillage
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
                          //Mockup + image superposée
                          Expanded(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/mockup-skate.png',
                                  fit: BoxFit.contain,
                                ),
                                Transform.translate(
                                  offset: imageOffset,
                                  child: Transform.scale(
                                    scale: imageScale,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        userImage,
                                        height: 200,
                                        opacity: const AlwaysStoppedAnimation(
                                          0.85,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          //Description à droite
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.black.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: SingleChildScrollView(
                                child: Text(
                                  description,
                                  style: const TextStyle(
                                    color: AppColors.beige,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Commande confirmée !")),
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
