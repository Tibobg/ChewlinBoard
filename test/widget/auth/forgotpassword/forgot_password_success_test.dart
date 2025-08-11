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
    when(
      () => stub.fetchSignInMethodsForEmail(any()),
    ).thenAnswer((_) async => ['password']);
    when(
      () => stub.sendPasswordResetEmail(email: any(named: 'email')),
    ).thenAnswer((_) async {});
    when(() => stub.signOut()).thenAnswer((_) async {}); // <-- AJOUT

    firebaseAuth = stub;
    firestore = FakeFirebaseFirestore();
    authService = AuthService(auth: stub, firestore: firestore);
  });

  testWidgets('email connu → snack OK puis nav LoginPage', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordPage()));
    await tester.enterText(find.byType(TextField).first, 'user@test.com');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Envoyer'));
    await tester.pumpAndSettle();

    // OK si tu gardes le texte exact :
    // expect(find.text('Email de réinitialisation envoyé !'), findsOneWidget);

    // Version plus robuste :
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('réinitialisation'), findsOneWidget);

    expect(find.byType(LoginPage), findsOneWidget);
  });
}
