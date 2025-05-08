import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'login_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  const Text(
                    'ChewLinBoard',
                    style: TextStyle(
                      fontFamily: 'ReginaBlack',
                      fontSize: 28,
                      color: AppColors.beige,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Image.asset('assets/images/logo-img.jpeg', height: 100),
                  const SizedBox(height: 32),

                  const Text(
                    'Email de récupération...',
                    style: TextStyle(fontSize: 16, color: AppColors.beige),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: AppColors.beige),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.black.withOpacity(0.8),
                      hintText: 'Email de récupération...',
                      hintStyle: const TextStyle(color: AppColors.beige),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () {
                      // Envoyer la demande de réinitialisation Firebase
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
                      'Envoyer',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.beige,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const Spacer(),

                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      "J'ai déjà un compte",
                      style: TextStyle(
                        color: AppColors.beige,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
