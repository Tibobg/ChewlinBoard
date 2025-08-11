import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/services/auth_service.dart';
import 'package:chewlin_board/pages/auth/forgot_password_page.dart';

class StubAuth extends Mock implements FirebaseAuth {}

void main() {
  late StubAuth stub;

  setUp(() {
    stub = StubAuth();
    when(
      () => stub.fetchSignInMethodsForEmail(any()),
    ).thenAnswer((_) async => []);
    when(() => stub.signOut()).thenAnswer((_) async {});
    firebaseAuth = stub;
    firestore = FakeFirebaseFirestore();
    authService = AuthService(auth: stub, firestore: firestore);
  });

  testWidgets('ForgotPassword: email inconnu -> SnackBar erreur', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordPage()));

    await tester.enterText(find.byType(TextField).first, 'nope@test.com');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Envoyer'));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
  });
}
