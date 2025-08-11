import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/services/auth_service.dart';
import 'package:chewlin_board/pages/user/home_page.dart';
import '../helpers/seed.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Intl.defaultLocale = 'fr_FR';
    await initializeDateFormatting('fr_FR', null);
  });

  setUp(() async {
    firebaseAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'u1', email: 'u@u.com'),
    );
    firestore = FakeFirebaseFirestore();
    await seedForUserFlow(firestore as FakeFirebaseFirestore, uid: 'u1');
    authService = AuthService(auth: firebaseAuth, firestore: firestore);
  });

  testWidgets('HomePage: fetchActiveOrder est exécuté sans crash', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        supportedLocales: const [Locale('fr')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const Scaffold(body: HomePage()), // <-- important
      ),
    );

    // Laisse initState/frames
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // On vérifie que la page est bien affichée (pas d’exception)
    expect(find.byType(HomePage), findsOneWidget);
  });
}
