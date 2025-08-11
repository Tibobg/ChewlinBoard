import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/services/auth_service.dart';
import 'package:chewlin_board/pages/auth/login_page.dart';

void main() {
  setUp(() async {
    // Prépare une auth “propre”
    firebaseAuth = MockFirebaseAuth();
    // On crée un compte pour que signIn réussisse ensuite
    await firebaseAuth.createUserWithEmailAndPassword(
      email: 'u@u.com',
      password: 'p',
    );
    // On se déconnecte pour démarrer la page comme “déconnecté”
    await firebaseAuth.signOut();

    // Firestore sans doc users/{uid} -> “compte inexistant”
    firestore = FakeFirebaseFirestore();

    // Rebranche l’AuthService sur ces fakes
    authService = AuthService(auth: firebaseAuth, firestore: firestore);
  });

  testWidgets('compte inexistant → SnackBar + signOut', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    // Remplir email/mot de passe
    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(2));
    await tester.enterText(fields.at(0), 'u@u.com');
    await tester.enterText(fields.at(1), 'p');

    // Taper "Connexion"
    await tester.tap(find.widgetWithText(ElevatedButton, 'Connexion'));
    await tester.pumpAndSettle();

    // La page doit afficher un SnackBar et déconnecter l’utilisateur
    expect(find.byType(SnackBar), findsOneWidget);
    expect(firebaseAuth.currentUser, isNull);
  });
}
