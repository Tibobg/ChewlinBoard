import 'dart:async';
import 'package:chewlinboard/main.dart';
import 'package:chewlinboard/screen/connection/passwordPage/password_page.dart';
import 'package:flutter/material.dart';
import 'package:chewlinboard/screen/animation/delayed_animation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final client = Supabase.instance.client;

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;
  late final StreamSubscription<AuthState> _authSubscription;
  Future<String?> userLogin({
    required final String email,
    required final String username,
    required final String password,
  }) async {
    final response = await client.auth.signInWithOtp(
      email: email,
      username: username,
      password: password,
    );
    /*final user = response.user;
    return user?.name;*/
  }

  @override
  void initState() {
    super.initState();
    supabase.auth.onAuthStateChange.listen((event) {
      final session = event;
      session;
      if (session != null) {
        Navigator.of(context).pushReplacementNamed('/HomePage');
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _authSubscription.cancel();
    super.dispose();
  }

  //DESIGN FORM
  final decoratedForm = InputDecoration(
    filled: true,
    fillColor: black,
    border: const OutlineInputBorder(),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: green, width: 2.0),
      borderRadius: BorderRadius.circular(30.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: green, width: 2.0),
      borderRadius: BorderRadius.circular(30.0),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
      borderRadius: BorderRadius.circular(30.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
      borderRadius: BorderRadius.circular(30.0),
    ),
    labelStyle: const TextStyle(
      color: white,
      fontFamily: 'ReginaBlack',
    ),
    labelText: "Email...",
    prefixIcon: const Icon(
      Icons.email,
      color: white,
    ),
  );

  //DESIGN TEXT FORM
  final decoratedTextForm = TextFormField(
    validator: (value) {
      if (value!.isNotEmpty) {
        return null;
      } else {
        return 'Add Text...';
      }
    },
    cursorColor: white,
    style: const TextStyle(
      color: white,
      fontSize: 16,
      fontFamily: 'ReginaBlack',
    ),
    keyboardType: TextInputType.emailAddress,
  );

  final _formMailKey = GlobalKey<FormState>();

  final _formPseudoKey = GlobalKey<FormState>();

  final _formPasswordKey = GlobalKey<FormState>();

  Future<void> signOut() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      //FLECHE RETOUR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: white,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        //BACKGROUND IMAGE
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/leaf_bg.jpg'),
            fit: BoxFit.fitHeight,
          ),
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(
            vertical: 60,
            horizontal: 30,
          ),
          child: Column(
            children: [
              //TITRE
              const DelayedAnimation(
                delay: 500,
                child: SizedBox(
                  height: 50,
                  child: Text(
                    "ChewLinBoard",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: white,
                      fontSize: 36,
                      fontFamily: 'ReginaBlack',
                    ),
                  ),
                ),
              ),
              //LOGO
              DelayedAnimation(
                delay: 1500,
                child: SizedBox(
                  height: 200,
                  child: Image.asset('images/logo_round.png'),
                ),
              ),

              //FORM LOGIN

              //EMAIL
              const SizedBox(height: 20),
              DelayedAnimation(
                delay: 5500,
                child: Form(
                  key: _formMailKey,
                  child: TextFormField(
                    controller: _emailController,
                    validator: (value) {
                      if (value!.isNotEmpty) {
                        return null;
                      } else {
                        return 'Nécessite un mail...';
                      }
                    },
                    cursorColor: white,
                    style: const TextStyle(
                      color: white,
                      fontSize: 16,
                      fontFamily: 'ReginaBlack',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    decoration: decoratedForm,
                  ),
                ),
              ),
              //PSEUDO
              const SizedBox(height: 20),
              DelayedAnimation(
                delay: 5500,
                child: Form(
                  key: _formPseudoKey,
                  child: TextFormField(
                    controller: _usernameController,
                    validator: (value) {
                      if (value!.isNotEmpty) {
                        return null;
                      } else {
                        return 'Nécessite un pseudo...';
                      }
                    },
                    cursorColor: white,
                    style: const TextStyle(
                      color: white,
                      fontSize: 16,
                      fontFamily: 'ReginaBlack',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    decoration: decoratedForm.copyWith(
                      labelText: "Pseudo...",
                      prefixIcon: const Icon(
                        Icons.account_circle_rounded,
                        color: white,
                      ),
                    ),
                  ),
                ),
              ),
              //PASSWORD
              const SizedBox(height: 20),
              DelayedAnimation(
                delay: 5500,
                child: Form(
                  key: _formPasswordKey,
                  child: TextFormField(
                    controller: _passwordController,
                    validator: (value) {
                      if (value!.isNotEmpty) {
                        return null;
                      } else {
                        return 'Nécessite un mot de passe...';
                      }
                    },
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    cursorColor: white,
                    style: const TextStyle(
                      color: white,
                      fontSize: 16,
                      fontFamily: 'ReginaBlack',
                    ),
                    decoration: decoratedForm.copyWith(
                      labelText: "Mot de passe...",
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: white,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.visibility,
                          color: white,
                        ),
                        onPressed: () {
                          /*
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });*/
                        },
                      ),
                    ),
                  ),
                ),
              ),
              //BUTTON CONFIRMER
              const SizedBox(height: 40),
              DelayedAnimation(
                delay: 5500,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final email = _emailController.text.trim();
                      /*final username = _usernameController.text.trim();
                      final password = _passwordController.text.trim();*/
                      await supabase.auth.signInWithOtp(
                          email: email,
                          /*username: username,
                          password: password,*/
                          emailRedirectTo:
                              'io.supabase.flutterquickstart://login-callback/');

                      if (!_formMailKey.currentState!.validate()) {
                        return;
                      }
                      if (!_formPasswordKey.currentState!.validate()) {
                        return;
                      }
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Check your inbox')));
                      }
                    } on AuthException catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error.message),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Error occured, please retry.'),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: green,
                    padding: const EdgeInsets.all(13),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Confirmer',
                        style: TextStyle(
                          color: white,
                          fontSize: 24,
                          fontFamily: 'ReginaBlack',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              //TEXT MDP OUBLIE
              DelayedAnimation(
                delay: 5500,
                child: DelayedAnimation(
                  delay: 500,
                  child: Container(
                    height: 50,
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      child: const Text(
                        "Mot de passe oublié?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: white,
                          fontSize: 16,
                          fontFamily: 'ReginaBlack',
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PasswordPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              //SIGNATURE
              DelayedAnimation(
                delay: 5500,
                child: Container(
                  alignment: Alignment.bottomLeft,
                  height: 80,
                  width: 80,
                  child: Image.asset('images/sign_chewlin_white.png'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
