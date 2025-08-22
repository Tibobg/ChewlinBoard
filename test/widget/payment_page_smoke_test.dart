import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;

import 'package:chewlin_board/models/project_data.dart';
import 'package:chewlin_board/pages/project/delivery_date_page.dart';
import '../helpers/pump_app.dart';

void main() {
  testWidgets('PaymentPage: charge agenda (mock) puis SnackBar si pas de date', (
    tester,
  ) async {
    final client = MockClient((req) async {
      // Réponse JSON minimale Google Calendar
      return http.Response(
        '{"items":[{"start":{"date":"2030-02-01"},"end":{"date":"2030-02-03"}}]}',
        200,
      );
    });

    final project = ProjectData(
      boardName: 'Deck',
      boardPrice: '199.9',
      imagePaths: const [],
    );

    final app = await pumpApp(
      PaymentPage(project: project, httpClient: client),
    );
    await tester.pumpWidget(app);

    // chargement -> fin
    await tester.pump(const Duration(milliseconds: 200));

    // Appuie sur "Payer maintenant" sans date -> SnackBar
    await tester.tap(find.widgetWithText(ElevatedButton, 'Payer maintenant'));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(SnackBar), findsOneWidget);
  });
}
