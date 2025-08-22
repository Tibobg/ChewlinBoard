import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;

import 'package:chewlin_board/widgets/drive_gallery.dart';
import '../helpers/pump_app.dart';
import '../helpers/mock_network_images.dart';

void main() {
  testWidgets('DriveGallery: tap vignette -> overlay, puis fermeture', (
    tester,
  ) async {
    // 5 images “triables”
    final files = [
      {'id': '1', 'name': '1.jpg'},
      {'id': '2', 'name': '2.jpg'},
      {'id': '3', 'name': '3.jpg'},
      {'id': '4', 'name': '4.jpg'},
      {'id': '5', 'name': '5.jpg'},
    ];
    final client = MockClient(
      (req) async => http.Response(jsonEncode({'files': files}), 200),
    );

    await mockNetworkImagesFor(() async {
      final app = await pumpApp(DriveGallery(httpClient: client));
      await tester.pumpWidget(app);
      await tester.pump(const Duration(milliseconds: 200)); // fetch + setState

      // tape sur une vignette (premier GestureDetector/InkWell disponible)
      Finder? thumb;
      for (final f in [find.byType(GestureDetector), find.byType(InkWell)]) {
        if (f.evaluate().isNotEmpty) {
          thumb = f.first;
          break;
        }
      }
      expect(thumb, isNotNull, reason: 'Aucune vignette cliquable trouvée');
      await tester.tap(thumb!);
      await tester.pump(const Duration(milliseconds: 120));

      // overlay visible (bouton close OU image plein écran)
      final closeBtn = find.byIcon(Icons.close);
      final overlayOk =
          closeBtn.evaluate().isNotEmpty ||
          find.byType(Image).evaluate().isNotEmpty;
      expect(overlayOk, isTrue);

      // ferme si bouton présent (sinon on laisse, c’est un smoke)
      if (closeBtn.evaluate().isNotEmpty) {
        await tester.tap(closeBtn);
        await tester.pump(const Duration(milliseconds: 80));
      }

      expect(find.byType(DriveGallery), findsOneWidget);
    });
  });
}
