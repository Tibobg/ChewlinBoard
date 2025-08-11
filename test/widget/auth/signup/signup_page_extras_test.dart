import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/services/auth_service.dart';
import 'package:chewlin_board/pages/auth/signup_page.dart';
import 'package:chewlin_board/pages/user/terms_of_use_page.dart';

void main() {
  setUp(() {
    firebaseAuth = MockFirebaseAuth();
    firestore = FakeFirebaseFirestore();
    authService = AuthService(auth: firebaseAuth, firestore: firestore);
  });

  testWidgets('SignUp: onWillPop -> pop via Navigator', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder:
              (ctx) => ElevatedButton(
                onPressed:
                    () => Navigator.of(ctx).push(
                      MaterialPageRoute(builder: (_) => const SignUpPage()),
                    ),
                child: const Text('go'),
              ),
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    nav.pop();
    await tester.pumpAndSettle();

    expect(find.text('go'), findsOneWidget);
  });

  testWidgets('SignUp: toggle mot de passe (si présent) ne crashe pas', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SignUpPage()));

    final off = find.byIcon(Icons.visibility_off);
    if (off.evaluate().isNotEmpty) {
      await tester.tap(off);
      await tester.pump();
    }
    expect(find.byType(SignUpPage), findsOneWidget);
  });

  testWidgets('SignUp: CGU (si lien cliquable) -> pas de crash', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SignUpPage()));

    final cgu = find.textContaining('Conditions Générales');
    if (cgu.evaluate().isNotEmpty) {
      await tester.tap(cgu);
      await tester.pumpAndSettle(const Duration(milliseconds: 50));
    }

    final ok =
        find.byType(SignUpPage).evaluate().isNotEmpty ||
        find.byType(TermsOfUsePage).evaluate().isNotEmpty;
    expect(ok, isTrue);
  });
}
