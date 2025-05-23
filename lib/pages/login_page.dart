import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'signup_page.dart';
import 'forgot_password_page.dart';
import '../services/auth_service.dart';
import '../pages/auth_gate.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _obscurePassword = true;

  bool _isLoading = false;

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = await _authService.signIn(email, password);

    if (!mounted) return;

    if (user != null) {
      // ✅ On redirige vers AuthGate, qui gère la logique admin/utilisateur
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Connexion échouée.')));
    }

    setState(() => _isLoading = false);
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
                                color: AppColors.beige,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
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
                        onPressed: _isLoading ? null : _login,
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
                                  'Connexion',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.beige,
                                  ),
                                ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignUpPage(),
                              ),
                            ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.beige,
                          foregroundColor: AppColors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Pas encore de compte',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: GestureDetector(
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordPage(),
                                ),
                              ),
                          child: const Text(
                            'Mot de passe oublié ?',
                            style: TextStyle(color: AppColors.beige),
                          ),
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
