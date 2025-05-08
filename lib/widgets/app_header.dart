import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AppHeader extends StatelessWidget {
  final bool showBackButton;

  const AppHeader({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        height: 50,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 🔙 Flèche retour si demandé
            if (showBackButton)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.beige),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

            // ✍️ Signature centrée
            Center(
              child: Image.asset(
                'assets/images/Logo-blanc.png',
                height: 40,
                fit: BoxFit.contain,
              ),
            ),

            // 🌀 Logo rond à droite
            Align(
              alignment: Alignment.centerRight,
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo-img.jpeg',
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
