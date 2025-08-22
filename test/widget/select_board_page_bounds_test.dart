import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';
import 'package:chewlin_board/pages/project/select_board_page.dart';

void main() {
  testWidgets('SelectBoardPage: flèches aux bornes ne crashent pas', (
    tester,
  ) async {
    final app = await pumpApp(const SelectBoardPage(disableModelViewer: true));
    await tester.pumpWidget(app);
    await tester.pump(const Duration(milliseconds: 80));

    final left = find.byIcon(Icons.arrow_back_ios);
    final right = find.byIcon(Icons.arrow_forward_ios);

    if (left.evaluate().isNotEmpty) {
      await tester.tap(left); // déjà au début
      await tester.pump(const Duration(milliseconds: 20));
    }
    if (right.evaluate().isNotEmpty) {
      // va à la fin en cliquant plusieurs fois (si dispo)
      for (var i = 0; i < 5; i++) {
        await tester.tap(right);
        await tester.pump(const Duration(milliseconds: 10));
      }
      // puis encore un coup à droite (au-delà de la fin)
      await tester.tap(right);
      await tester.pump(const Duration(milliseconds: 20));
    }

    expect(find.byType(SelectBoardPage), findsOneWidget);
  });
}
