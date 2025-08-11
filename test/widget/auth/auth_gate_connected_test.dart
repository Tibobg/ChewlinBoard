import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/services/auth_service.dart';
import 'package:chewlin_board/pages/auth/auth_gate.dart';
import 'package:chewlin_board/navigation/admin_nav_container.dart';
import 'package:chewlin_board/navigation/bottom_nav_container.dart';

// On override isAdmin pour tester admin/non-admin sans custom claims
class TestAuthGate extends AuthGate {
  const TestAuthGate({required this.asAdmin, super.key});
  final bool asAdmin;
  @override
  Future<bool> isAdmin(user) async => asAdmin;
}

void main() {
  // 1) Locale/intl une seule fois pour table_calendar
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Intl.defaultLocale = 'fr_FR';
    await initializeDateFormatting('fr_FR', null);
  });

  // 2) Injection AVANT chaque test, et on RECONSTRUIT authService
  setUp(() {
    firestore = FakeFirebaseFirestore();
    firebaseAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'u1', email: 'x@y.z'),
    );
    authService = AuthService(auth: firebaseAuth, firestore: firestore);
  });

  testWidgets('connecté non-admin → BottomNavContainer', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr', 'FR'),
        supportedLocales: const [Locale('fr', 'FR'), Locale('fr')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const TestAuthGate(asAdmin: false),
      ),
    );
    await tester.pump(); // StreamBuilder
    await tester.pump(); // FutureBuilder
    expect(find.byType(BottomNavContainer), findsOneWidget);
  });

  testWidgets('connecté admin → AdminNavContainer', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr', 'FR'),
        supportedLocales: const [Locale('fr', 'FR'), Locale('fr')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const TestAuthGate(asAdmin: true),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.byType(AdminNavContainer), findsOneWidget);
  });
}
