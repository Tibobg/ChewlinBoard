import 'package:flutter/material.dart';
import 'package:chewlinboard/screen/animation/delayed_animation.dart';
import 'package:chewlinboard/main.dart';
import 'package:chewlinboard/screen/connection/loginPage/login_page.dart';
import 'package:chewlinboard/screen/connection/SignInPage/signin_page.dart';

class NotificationPage extends StatelessWidget {
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
            vertical: 40,
            horizontal: 30,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 120),
                  //SIGNATURE
                  DelayedAnimation(
                    delay: 5500,
                    child: Container(
                      height: 100,
                      width: 100,
                      alignment: Alignment.center,
                      child: Image.asset('images/sign_chewlin_white.png'),
                    ),
                  ),
                  //LOGO
                  const SizedBox(width: 50),
                  DelayedAnimation(
                    delay: 1500,
                    child: Container(
                      height: 80,
                      child: Image.asset(
                        'images/logo_round.png',
                      ),
                    ),
                  ),
                ],
              ),

              //BIENVENUE NAME
              const SizedBox(height: 20),
              const DelayedAnimation(
                delay: 500,
                child: SizedBox(
                  height: 50,
                  child: Text(
                    "Bienvenue Jacques Martel !",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: white,
                      fontSize: 25,
                      fontFamily: 'ReginaBlack',
                    ),
                  ),
                ),
              ),
              //MES PLANCHES PANNEL
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  backgroundColor: black,
                  padding: const EdgeInsets.all(13),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Mes planches DIY',
                      style: TextStyle(
                        color: white,
                        fontSize: 16,
                        fontFamily: 'ReginaBlack',
                      ),
                    ),
                  ],
                ),
              ),
              //CREATION PANEL
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 200.0,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: green,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Mes dernières NOTIFICATION',
                        style: TextStyle(
                          color: white,
                          fontSize: 20,
                          fontFamily: 'ReginaBlack',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              //DISPONIBILITY PANEL
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
                      'Mon calendrier de disponibilité',
                      style: TextStyle(
                        color: green,
                        fontSize: 16,
                        fontFamily: 'ReginaBlack',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
