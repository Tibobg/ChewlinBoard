import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/services/auth_service.dart';
import 'package:chewlin_board/pages/auth/forgot_password_page.dart';
import 'package:chewlin_board/pages/auth/login_page.dart';

class StubAuth extends Mock implements FirebaseAuth {}

void main() {
  late StubAuth stub;

  setUp(() {
    stub = StubAuth();
    // L’email existe → on passe le check "methods"
    when(
      () => stub.fetchSignInMethodsForEmail(any()),
    ).thenAnswer((_) async => ['password']);
    // Erreur réseau lors de l’envoi
    when(
      () => stub.sendPasswordResetEmail(email: any(named: 'email')),
    ).thenThrow(
      FirebaseAuthException(code: 'network-request-failed', message: 'offline'),
    );
    // Certaines pages appellent signOut en init
    when(() => stub.signOut()).thenAnswer((_) async {});

    firebaseAuth = stub;
    firestore = FakeFirebaseFirestore();
    authService = AuthService(auth: stub, firestore: firestore);
  });

  testWidgets('erreur réseau → SnackBar d’erreur, pas de nav', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordPage()));

    await tester.enterText(find.byType(TextField).first, 'user@test.com');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Envoyer'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget); // erreur signalée
    expect(find.byType(LoginPage), findsNothing); // pas de nav sur erreur
  });
}
