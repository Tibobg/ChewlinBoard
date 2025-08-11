import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/services/auth_service.dart';
import 'package:chewlin_board/pages/auth/login_page.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Intl.defaultLocale = 'fr_FR';
    await initializeDateFormatting('fr_FR', null);
  });

  setUp(() async {
    // Auth prête avec un compte réel dans le mock
    firebaseAuth = MockFirebaseAuth();
    final cred = await firebaseAuth.createUserWithEmailAndPassword(
      email: 'u@u.com',
      password: 'p',
    );

    // Firestore avec doc users/{uid} -> branche "succès"
    firestore = FakeFirebaseFirestore();
    await firestore.collection('users').doc(cred.user!.uid).set({
      'email': 'u@u.com',
      'pseudo': 'Tibo',
    });

    // Déconnecte avant d’afficher la page
    await firebaseAuth.signOut();

    // Rebranche le service sur nos fakes
    authService = AuthService(auth: firebaseAuth, firestore: firestore);
  });

  testWidgets(
    'LoginPage: login OK (user doc présent) → pas de SnackBar d’erreur',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fr', 'FR'),
          supportedLocales: const [Locale('fr', 'FR'), Locale('fr')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const LoginPage(),
        ),
      );

      // Remplir les champs
      final fields = find.byType(TextField);
      expect(fields, findsNWidgets(2));
      await tester.enterText(fields.at(0), 'u@u.com');
      await tester.enterText(fields.at(1), 'p');

      // Soumettre
      await tester.tap(find.widgetWithText(ElevatedButton, 'Connexion'));

      // ⚠️ Pas de pumpAndSettle ici (risque d’attendre infiniment).
      // On fait quelques pumps bornés pour laisser les futures se résoudre.
      await tester.pump(); // premier frame
      await tester.pump(const Duration(milliseconds: 50)); // asynchrones courts

      // Pas d’erreur signalée
      expect(find.byType(SnackBar), findsNothing);
      // Et l’utilisateur est bien connecté
      expect(firebaseAuth.currentUser, isNotNull);
    },
  );
}
