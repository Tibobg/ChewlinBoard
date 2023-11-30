import 'package:chewlinboard/main.dart';
import 'package:chewlinboard/screen/connection/passwordPage/password_page.dart';
import 'package:chewlinboard/screen/application/homePage/home_page.dart';
import 'package:flutter/material.dart';
import 'package:chewlinboard/screen/animation/delayed_animation.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:chewlinboard/auth.dart';

class LoginPage extends StatelessWidget {
  //DESIGN FORM CONNEXION
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
  //VISIBILITE MDP
  //var _passwordVisible = true;

  LoginPage({Key? key}) : super(key: key);
  final _formMailKey = GlobalKey<FormState>();
  final _formPasswordKey = GlobalKey<FormState>();
  //final User? user = Auth().currentUser;

  Future<void> signOut() async {
    //await Auth().signOut();
  }

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
              //SIGNATURE
              DelayedAnimation(
                delay: 5500,
                child: SizedBox(
                  height: 150,
                  width: 150,
                  child: Image.asset('images/sign_chewlin_white.png'),
                ),
              ),

              //FORM LOGIN

              //EMAIL
              DelayedAnimation(
                delay: 5500,
                child: Form(
                  key: _formMailKey,
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isNotEmpty) {
                        return null;
                      } else {
                        return 'Nécessite votre mail...';
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
              //PASSWORD

              const SizedBox(height: 20),
              DelayedAnimation(
                delay: 5500,
                child: Form(
                  key: _formPasswordKey,
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isNotEmpty) {
                        return null;
                      } else {
                        return 'Nécessite votre mot de passe...';
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
                  onPressed: () {
                    if (!_formMailKey.currentState!.validate()) {
                      return;
                    }
                    if (!_formPasswordKey.currentState!.validate()) {
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
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
            ],
          ),
        ),
      ),
    );
  }
}
