import 'package:flutter/material.dart';
import 'package:chewlinboard/screen/animation/delayed_animation.dart';
import 'package:chewlinboard/main.dart';
import 'package:chewlinboard/screen/connection/loginPage/login_page.dart';
import 'package:chewlinboard/screen/connection/passwordPage/password_page.dart';
import 'package:chewlinboard/screen/connection/SignInPage/signin_page.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              //JAPANESE DECO
              /*const DelayedAnimation(
                delay: 500,
                child: SizedBox(
                  width: 500,
                  child: Text(
                    "チ",
                    style: TextStyle(
                      color: white,
                      fontSize: 60,
                    ),
                  ),
                ),
              ),*/
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
              //SIGNATURE
              DelayedAnimation(
                delay: 5500,
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: Image.asset('images/sign_chewlin_white.png'),
                ),
              ),
              //GOOGLE BUTTON
              const DelayedAnimation(delay: 8500, child: SizedBox(height: 20)),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  backgroundColor: black,
                  padding: const EdgeInsets.all(13),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/google.png',
                      height: 20,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Google',
                      style: TextStyle(
                        color: white,
                        fontSize: 24,
                        fontFamily: 'ReginaBlack',
                      ),
                    ),
                  ],
                ),
              ),
              //CONNEXION BUTTON
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                  );
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
                      'Connexion',
                      style: TextStyle(
                        color: white,
                        fontSize: 24,
                        fontFamily: 'ReginaBlack',
                      ),
                    ),
                  ],
                ),
              ),
              //PAS ENCORE DE COMPTE BUTTON
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignInPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  backgroundColor: white,
                  padding: const EdgeInsets.all(13),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Pas encore de compte',
                      style: TextStyle(
                        color: green,
                        fontSize: 24,
                        fontFamily: 'ReginaBlack',
                      ),
                    ),
                  ],
                ),
              ),
              //TEXT MDP OUBLIE
              DelayedAnimation(
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
            ],
          ),
        ),
      ),
    );
  }
}
