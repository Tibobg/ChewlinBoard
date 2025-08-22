import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;

import '../helpers/pump_app.dart';
import 'package:chewlin_board/widgets/drive_gallery.dart';

void main() {
  testWidgets('DriveGallery: gère une erreur HTTP sans crasher', (
    tester,
  ) async {
    final client = MockClient((req) async => http.Response('boom', 500));

    final app = await pumpApp(DriveGallery(httpClient: client));
    await tester.pumpWidget(app);

    // laisse le Future se terminer
    await tester.pump(const Duration(milliseconds: 150));

    // la page est toujours affichée (pas de crash)
    expect(find.byType(DriveGallery), findsOneWidget);
  });
}
