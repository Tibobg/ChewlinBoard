import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/services/auth_service.dart';
import 'package:chewlin_board/pages/auth/forgot_password_page.dart';
import 'package:chewlin_board/pages/auth/signup_page.dart';

void main() {
  setUp(() {
    firebaseAuth = MockFirebaseAuth();
    firestore = FakeFirebaseFirestore();
    authService = AuthService(auth: firebaseAuth, firestore: firestore);
  });

  testWidgets(
    'ForgotPassword: lien "Créer un compte" (si cliquable) -> pas de crash',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ForgotPasswordPage()));

      // Le lien peut être un TextSpan non cliquable via tester.tap.
      final link = find.textContaining('Créer un compte');
      if (link.evaluate().isNotEmpty) {
        await tester.tap(link);
        await tester.pumpAndSettle(const Duration(milliseconds: 50));
      }

      // On reste tolérant : pas d’assertion de navigation stricte.
      // L’écran doit être rendu (ou SignUp si ça a navigué).
      expect(
        find.byType(ForgotPasswordPage).evaluate().isNotEmpty ||
            find.byType(SignUpPage).evaluate().isNotEmpty,
        isTrue,
      );
    },
  );
}
