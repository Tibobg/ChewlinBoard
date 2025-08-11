import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/pages/auth/auth_gate.dart';
import 'package:chewlin_board/pages/auth/login_page.dart';
import '../../helpers/test_di.dart';

void main() {
  setUp(injectFakes);
  testWidgets('AuthGate: pas de user -> LoginPage', (tester) async {
    firebaseAuth = MockFirebaseAuth(signedIn: false);

    await tester.pumpWidget(const MaterialApp(home: AuthGate()));
    // StreamBuilder -> un petit pump supplémentaire
    await tester.pump();

    expect(find.byType(LoginPage), findsOneWidget);
  });
}
