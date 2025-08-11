import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/services/auth_service.dart';
import 'package:chewlin_board/pages/auth/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Petit stub qui force l'échec de signIn
class StubAuthService extends AuthService {
  StubAuthService()
    : super(auth: MockFirebaseAuth(), firestore: FakeFirebaseFirestore());

  @override
  Future<User?> signIn(String email, String password) async {
    // On force l'échec et on renseigne le message d'erreur attendu par ta page
    AuthService.lastErrorMessage = 'Email ou mot de passe incorrect.';
    return null;
  }
}

void main() {
  setUp(() {
    // Branche nos fakes
    firebaseAuth = MockFirebaseAuth();
    firestore = FakeFirebaseFirestore();
    authService = StubAuthService();
  });

  testWidgets('LoginPage: signIn échoue -> SnackBar affiché', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'u@u.com');
    await tester.enterText(fields.at(1), 'bad');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Connexion'));
    await tester.pump();

    // On ne dépend pas du texte exact
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
