import 'package:flutter/material.dart';
import 'package:chewlinboard/main.dart';

class Prelogin extends StatefulWidget {
  const Prelogin({super.key});

  @override
  State<Prelogin> createState() => _Prelogin();
}

class _Prelogin extends State<Prelogin> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(Duration.zero);
    final session = supabase.auth.currentSession;

    if (!mounted) return;
    if (session != null) {
      Navigator.of(context).pushReplacementNamed('/welcome');
    } else {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
