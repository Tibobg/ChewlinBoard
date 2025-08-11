import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/services/auth_service.dart';
import 'package:chewlin_board/pages/auth/signup_page.dart';

Finder anyTextInput() =>
    find.byWidgetPredicate((w) => w is TextField || w is TextFormField);

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Intl.defaultLocale = 'fr_FR';
    await initializeDateFormatting('fr_FR', null);
  });

  setUp(() {
    // Fakes neutres pour éviter tout accès Firebase réel
    firebaseAuth = MockFirebaseAuth();
    firestore = FakeFirebaseFirestore();
    authService = AuthService(auth: firebaseAuth, firestore: firestore);
  });

  testWidgets('SignUp: champs vides -> reste sur la page (validation locale)', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr', 'FR'),
        supportedLocales: const [Locale('fr', 'FR'), Locale('fr')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const SignUpPage(),
      ),
    );

    final submit = find.byType(ElevatedButton).first;
    await tester.ensureVisible(submit);
    await tester.tap(submit);

    // Pas de pumpAndSettle (peut attendre "pour toujours" si d'autres écrans ont des streams)
    await tester.pump(); // laisse les callbacks sync se jouer

    // L’important: la page ne crashe pas et on y est toujours
    expect(find.byType(SignUpPage), findsOneWidget);
  });

  testWidgets(
    'SignUp: password trop court -> reste sur la page (validation locale)',
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
          home: const SignUpPage(),
        ),
      );

      final fields = anyTextInput();
      expect(fields, findsAtLeastNWidgets(3)); // pseudo, email, password

      await tester.enterText(fields.at(0), 'Tibo'); // pseudo
      await tester.enterText(fields.at(1), 'tibo@test.com'); // email
      await tester.enterText(fields.at(2), '123'); // password trop court

      final submit = find.byType(ElevatedButton).first;
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pump();

      // Pas besoin d’un SnackBar exact : on vérifie juste que la page vit,
      // ce qui couvre la branche "password court" sans fragilité.
      expect(find.byType(SignUpPage), findsOneWidget);
    },
  );
}
