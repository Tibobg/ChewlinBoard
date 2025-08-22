import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/pagesAdmin/admin_inventory_page.dart';
import '../helpers/pump_app.dart';
import '../helpers/mock_network_images.dart';

void main() {
  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  testWidgets('AdminInventoryPage: render list', (tester) async {
    await firestore.collection('skateboards').add({
      'name': 'Deck 1',
      'price': '100',
      'isSold': false,
      'imageUrl': 'http://img',
      'createdAt': DateTime.now(),
    });

    await mockNetworkImagesFor(() async {
      final app = await pumpApp(const AdminInventoryPage());
      await tester.pumpWidget(app);
      await tester.pump(const Duration(milliseconds: 80));
    });

    expect(find.byType(AdminInventoryPage), findsOneWidget);
  });
}
