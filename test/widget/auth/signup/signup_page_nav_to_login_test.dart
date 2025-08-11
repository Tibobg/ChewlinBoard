// test/widget/signup_page_nav_to_login_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/services/auth_service.dart';
import 'package:chewlin_board/pages/auth/login_page.dart';
import 'package:chewlin_board/pages/auth/signup_page.dart';

void main() {
  setUp(() {
    firebaseAuth = MockFirebaseAuth();
    firestore = FakeFirebaseFirestore();
    authService = AuthService(auth: firebaseAuth, firestore: firestore);
  });

  testWidgets('SignUp: "J\'ai déjà un compte" → revient sur LoginPage', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/signup',
        routes: {
          '/': (_) => const LoginPage(),
          '/signup': (_) => const SignUpPage(),
        },
      ),
    );

    final backBtn = find.widgetWithText(TextButton, "J'ai déjà un compte");
    await tester.ensureVisible(backBtn);

    // 3) Tap + settle
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });
}
