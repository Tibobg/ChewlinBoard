import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import 'login_page.dart';
import '../../services/auth_service.dart';
import 'signup_page.dart';
import 'package:chewlin_board/core/firebase_refs.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = authService;
  bool _isLoading = false;

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();

    if (email.toLowerCase() == "chewlincorp@gmail.com") {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Nice try 😏"),
              content: const Text(
                "On ne reset pas le mot de passe du Grand Maître Chewlin",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final methods = await firebaseAuth.fetchSignInMethodsForEmail(email);

      if (methods.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Aucun compte n'est associé à cet email."),
          ),
        );
      } else {
        await _authService.sendPasswordResetEmail(email);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email de réinitialisation envoyé !')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Une erreur est survenue.')));
    } finally {
      setState(() => _isLoading = false);
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
                                fontFamily: 'ReginaBlack',
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppColors.beige,
                              ),
                            ),
                            SizedBox(height: 8),
                            ClipOval(
                              child: Image.asset(
                                'assets/images/logo-img.jpeg',
                                height: 100,
                                width: 100,
                              ),
                            ),
                            SizedBox(height: 12),
                            Image.asset(
                              'assets/images/Logo-blanc.png',
                              height: 30,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _emailController,
                        style: const TextStyle(color: AppColors.beige),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.black,
                          hintText: 'Email de récupération...',
                          hintStyle: const TextStyle(color: AppColors.beige),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: _isLoading ? null : _sendResetEmail,
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
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: AppColors.beige,
                                )
                                : const Text(
                                  'Envoyer',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppColors.beige,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),

                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignUpPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Créer un compte",
                          style: TextStyle(
                            color: AppColors.beige,
                            fontWeight: FontWeight.bold,
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
