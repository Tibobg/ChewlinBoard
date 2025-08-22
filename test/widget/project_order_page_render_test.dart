import 'package:flutter_test/flutter_test.dart';
import 'package:chewlin_board/models/project_data.dart';
import 'package:chewlin_board/pages/project/project_order_page.dart';
import '../helpers/pump_app.dart';
import '../helpers/mock_network_images.dart'; // re-export de mockNetworkImagesFor

void main() {
  testWidgets('ProjectOrderPage: render (no http call)', (tester) async {
    final project = ProjectData(
      boardName: 'Deck Custom',
      boardPrice: '249.90',
      description: 'test',
      imagePaths: const ['http://img'], // ✅ au moins une image
    );

    await mockNetworkImagesFor(() async {
      final app = await pumpApp(
        ProjectOrderPage(
          projectData: project,
          deliveryDate: DateTime(2030, 1, 1),
        ),
      );
      await tester.pumpWidget(app);
      await tester.pump(const Duration(milliseconds: 80));
    });

    expect(find.byType(ProjectOrderPage), findsOneWidget);
  });
}
