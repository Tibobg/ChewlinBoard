import 'package:chewlinboard/screen/animation/navbar.dart';
import 'package:chewlinboard/screen/application/homePage/home_page.dart';
import 'package:chewlinboard/screen/connection/loginPage/login_page.dart';
import 'package:chewlinboard/screen/connection/signInPage/signin_page.dart';
import 'package:chewlinboard/screen/animation/navbar.dart';
import 'package:flutter/material.dart';
import 'package:chewlinboard/screen/connection/welcomePage/welcome_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const black = Color(0xFF1C1C1C);
const green = Color(0xFF23714D);
const white = Color(0xFFF1CCBA);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://bceslyhbgazrjzqlkksw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJjZXNseWhiZ2F6cmp6cWxra3N3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDAwNDI2MTAsImV4cCI6MjAxNTYxODYxMH0.LSSlVch-wFap07KsVr8VQjrosLoR-_cwXifmNsOCq0g',
    authFlowType: AuthFlowType.pkce,
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chewlin board',
      debugShowCheckedModeBanner: false,
      initialRoute: client.auth.currentSession != null ? '/' : null,
      routes: {
        '/': (context) => WelcomePage(),
        '/login': (context) => LoginPage(),
        '/signin': (context) => const SignInPage(),
        '/home': (context) => HomePage(),
        '/navbar': (context) => const Navbar(),
      },
    );
  }
}
