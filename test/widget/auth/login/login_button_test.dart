import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class LoginButton extends StatelessWidget {
  final Future<void> Function() onLogin;
  final bool loading;
  const LoginButton({super.key, required this.onLogin, required this.loading});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : () => onLogin(),
      child:
          loading
              ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : const Text('Se connecter'),
    );
  }
}

void main() {
  testWidgets('désactivé en loading et affiche le loader', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: LoginButton(onLogin: _noop, loading: true)),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final ElevatedButton btn = tester.widget(find.byType(ElevatedButton));
    expect(btn.onPressed, isNull);
  });
}

Future<void> _noop() async {}
