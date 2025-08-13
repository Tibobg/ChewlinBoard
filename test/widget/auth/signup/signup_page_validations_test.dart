import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import '../../../helpers/pump_app.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/services/auth_service.dart';
import 'package:chewlin_board/pages/auth/signup_page.dart';

Finder anyTextInput() =>
    find.byWidgetPredicate((w) => w is TextField || w is TextFormField);

void main() {
  setUp(() {
    firebaseAuth = MockFirebaseAuth();
    firestore = FakeFirebaseFirestore(); // ✅ ici
    authService = AuthService(auth: firebaseAuth, firestore: firestore);
  });

  testWidgets('SignUp: champs vides -> reste sur la page (validation locale)', (
    tester,
  ) async {
    final app = await pumpApp(const SignUpPage());
    await tester.pumpWidget(app);
    await tester.pump();

    final submit = find.byType(ElevatedButton).first;
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(SignUpPage), findsOneWidget);
  });

  testWidgets(
    'SignUp: password trop court -> reste sur la page (validation locale)',
    (tester) async {
      final app = await pumpApp(const SignUpPage());
      await tester.pumpWidget(app);
      await tester.pump();

      final fields = anyTextInput();
      expect(fields, findsAtLeastNWidgets(3)); // pseudo, email, password

      await tester.enterText(fields.at(0), 'Tibo');
      await tester.enterText(fields.at(1), 'tibo@test.com');
      await tester.enterText(fields.at(2), '123'); // trop court

      final submit = find.byType(ElevatedButton).first;
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(SignUpPage), findsOneWidget);
    },
  );
}
