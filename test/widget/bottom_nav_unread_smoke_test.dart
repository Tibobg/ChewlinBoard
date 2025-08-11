import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/services/auth_service.dart';
import 'package:chewlin_board/navigation/bottom_nav_container.dart';
import '../helpers/seed.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  setUp(() async {
    // user connecté
    firebaseAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'u1', email: 'u@u.com'),
    );
    // DB en mémoire pré-seedée
    firestore = FakeFirebaseFirestore();
    await seedForUserFlow(firestore as FakeFirebaseFirestore, uid: 'u1');
    // Service branché sur nos fakes
    authService = AuthService(auth: firebaseAuth, firestore: firestore);
  });
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Intl.defaultLocale = 'fr_FR';
    await initializeDateFormatting('fr_FR', null);
  });

  testWidgets(
    'BottomNavContainer: le widget se construit et écoute les unread',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fr'),
          supportedLocales: const [Locale('fr')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const BottomNavContainer(),
        ),
      );

      // laisse initState/streams s’attacher et émettre
      await tester.pump(const Duration(milliseconds: 50));

      // On n’assert pas les détails d’UI → juste que ça s’affiche sans exception
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    },
  );
}
