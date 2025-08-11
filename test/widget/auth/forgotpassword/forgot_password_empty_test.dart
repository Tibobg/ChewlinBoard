import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/services/auth_service.dart';
import 'package:chewlin_board/pages/auth/forgot_password_page.dart';

void main() {
  setUp(() {
    // IMPORTANT : branche les fakes AVANT pumpWidget
    firebaseAuth = MockFirebaseAuth();
    firestore = FakeFirebaseFirestore();
    authService = AuthService(auth: firebaseAuth, firestore: firestore);
  });

  testWidgets('ForgotPassword: email vide -> SnackBar erreur', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordPage()));

    // Clique sur le bouton (peu importe le libellé exact)
    final submit = find.byType(ElevatedButton).last;
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
  });
}
