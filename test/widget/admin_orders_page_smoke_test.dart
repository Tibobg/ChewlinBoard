import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/pagesAdmin/admin_orders_page.dart';
import '../helpers/pump_app.dart';
import '../helpers/mock_network_images.dart';

void main() {
  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  testWidgets('AdminOrdersPage: render with one order', (tester) async {
    // seed order + board
    await firestore.collection('skateboards').doc('sk1').set({
      'imageUrl': 'http://img',
    });
    await firestore.collection('orders').add({
      'name': 'Tibo',
      'address': '12 rue test',
      'status': 'payée',
      'price': 199.9,
      'skateboardId': 'sk1',
      'timestamp': Timestamp.now(),
    });

    await mockNetworkImagesFor(() async {
      final app = await pumpApp(const AdminOrdersPage());
      await tester.pumpWidget(app);
      await tester.pump(const Duration(milliseconds: 80));
    });

    expect(find.byType(AdminOrdersPage), findsOneWidget);
  });
}
