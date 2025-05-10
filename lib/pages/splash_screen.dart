import 'package:flutter/material.dart';
import '../theme/colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo-img.jpeg', height: 120),
              const SizedBox(height: 24),
              const Text(
                'ChewLinBoard',
                style: TextStyle(
                  fontSize: 28,
                  color: AppColors.beige,
                  fontFamily: 'ReginaBlack',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const CircularProgressIndicator(
                color: AppColors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
