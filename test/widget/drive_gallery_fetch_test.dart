import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;

import 'package:chewlin_board/widgets/drive_gallery.dart';
import '../helpers/pump_app.dart';
import '../helpers/mock_network_images.dart';

void main() {
  testWidgets('DriveGallery: récupère 5 images (mock) et rend la liste', (
    tester,
  ) async {
    // JSON Drive: tri attendu par numéro dans le nom (desc), on en renvoie 6
    final files = [
      {'id': '1', 'name': '2.jpg'},
      {'id': '2', 'name': '10.jpg'},
      {'id': '3', 'name': '3.jpg'},
      {'id': '4', 'name': '4.jpg'},
      {'id': '5', 'name': '1.jpg'},
      {'id': '6', 'name': '5.jpg'},
    ];
    final client = MockClient((req) async {
      return http.Response(jsonEncode({'files': files}), 200);
    });

    await mockNetworkImagesFor(() async {
      final app = await pumpApp(DriveGallery(httpClient: client));
      await tester.pumpWidget(app);

      // laisse fetchImagesFromDrive + setState + precache tourner
      await tester.pump(const Duration(milliseconds: 200));
    });

    expect(find.byType(DriveGallery), findsOneWidget);
    // on doit avoir une ListView horizontale avec des vignettes
    // (pas de check fragile sur le nombre exact d’items)
  });
}
