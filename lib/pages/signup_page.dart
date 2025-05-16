import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/colors.dart';
import '../navigation/bottom_nav_container.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pseudoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;

  final AuthService _authService = AuthService();

  bool _isLoading = false;

  Future<void> _signUp() async {
    setState(() => _isLoading = true);

    final user = await _authService.signUp(
      emailController.text.trim(),
      passwordController.text.trim(),
      pseudoController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomNavContainer()),
      );
    } else {
      final errorMessage =
          AuthService.lastErrorMessage ??
          "Erreur lors de la création du compte.";
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),

                      Center(
                        child: Column(
                          children: [
                            const Text(
                              'ChewLinBoard',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppColors.beige,
                                fontFamily: 'ReginaBlack',
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipOval(
                              child: Image.asset(
                                'assets/images/logo-img.jpeg',
                                height: 100,
                                width: 100,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Image.asset(
                              'assets/images/Logo-blanc.png',
                              height: 30,
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                      TextField(
                        controller: emailController,
                        style: const TextStyle(color: AppColors.beige),
                        decoration: const InputDecoration(
                          hintText: 'Email...',
                          hintStyle: TextStyle(color: AppColors.beige),
                          filled: true,
                          fillColor: AppColors.black,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: pseudoController,
                        style: const TextStyle(color: AppColors.beige),
                        decoration: const InputDecoration(
                          hintText: 'Pseudo...',
                          hintStyle: TextStyle(color: AppColors.beige),
                          filled: true,
                          fillColor: AppColors.black,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: AppColors.beige),
                        decoration: InputDecoration(
                          hintText: 'Mot de passe...',
                          hintStyle: const TextStyle(color: AppColors.beige),
                          filled: true,
                          fillColor: AppColors.black,
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.beige,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: AppColors.beige,
                                )
                                : const Text(
                                  'Créer un compte',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.beige,
                                  ),
                                ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.green,
                          backgroundColor: AppColors.beige,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "J'ai déjà un compte",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
