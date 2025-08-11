import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/pages/auth/login_page.dart';
import 'package:chewlin_board/pages/auth/signup_page.dart';
import 'package:chewlin_board/pages/auth/forgot_password_page.dart';
import '../../../helpers/test_di.dart';

void main() {
  setUp(injectFakes);
  setUp(() {
    // Branche le mock sur le shim avant chaque test
    firebaseAuth = MockFirebaseAuth();
  });

  testWidgets('LoginPage: bouton "Pas encore de compte" → SignUpPage', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    await tester.tap(
      find.widgetWithText(ElevatedButton, 'Pas encore de compte'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SignUpPage), findsOneWidget);
  });

  testWidgets('LoginPage: lien "Mot de passe oublié ?" → ForgotPasswordPage', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    await tester.tap(find.text('Mot de passe oublié ?'));
    await tester.pumpAndSettle();

    expect(find.byType(ForgotPasswordPage), findsOneWidget);
  });

  testWidgets('LoginPage: champs vides → SnackBar', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    await tester.tap(find.widgetWithText(ElevatedButton, 'Connexion'));
    await tester.pumpAndSettle();

    expect(find.text('Veuillez remplir tous les champs'), findsOneWidget);
  });
}
