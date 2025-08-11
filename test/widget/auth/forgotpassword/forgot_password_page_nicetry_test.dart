import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chewlin_board/pages/auth/forgot_password_page.dart';
import '../../../helpers/test_di.dart';

void main() {
  setUp(injectFakes);
  testWidgets('ForgotPasswordPage: Nice try bloque le reset admin', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordPage()));

    // Saisir l'email protégé
    await tester.enterText(
      find.byType(TextField).first,
      'chewlincorp@gmail.com',
    );

    // Cliquer sur "Envoyer"
    await tester.tap(find.widgetWithText(ElevatedButton, 'Envoyer'));
    await tester.pumpAndSettle();

    // L'AlertDialog "Nice try 😏" doit apparaître
    expect(find.text('Nice try 😏'), findsOneWidget);
    expect(
      find.text("On ne reset pas le mot de passe du Grand Maître Chewlin"),
      findsOneWidget,
    );
  });
}
