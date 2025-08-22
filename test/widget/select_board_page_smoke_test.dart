import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chewlin_board/pages/project/select_board_page.dart';
import 'package:chewlin_board/pages/project/customize_board_page.dart';
import '../helpers/pump_app.dart';

void main() {
  testWidgets('SelectBoardPage: navigation “Valider” et flèches', (
    tester,
  ) async {
    final app = await pumpApp(const SelectBoardPage(disableModelViewer: true));
    await tester.pumpWidget(app);
    await tester.pump(const Duration(milliseconds: 80));

    expect(find.byType(SelectBoardPage), findsOneWidget);

    // Flèches gauche/droite ne crashent pas
    final left = find.byIcon(Icons.arrow_back_ios);
    final right = find.byIcon(Icons.arrow_forward_ios);
    if (left.evaluate().isNotEmpty) {
      await tester.tap(left);
      await tester.pump(const Duration(milliseconds: 20));
    }
    if (right.evaluate().isNotEmpty) {
      await tester.tap(right);
      await tester.pump(const Duration(milliseconds: 20));
    }

    // Valider -> CustomizeBoardPage
    final validate = find.widgetWithText(ElevatedButton, 'Valider');
    await tester.ensureVisible(validate);
    await tester.tap(validate);
    await tester.pumpAndSettle(const Duration(milliseconds: 120));

    expect(find.byType(CustomizeBoardPage), findsOneWidget);
  });
}
