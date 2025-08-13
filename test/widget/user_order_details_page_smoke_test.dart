import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../helpers/mock_network_images.dart';
import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/pages/user/user_order_details_page.dart';
import '../helpers/pump_app.dart';

void main() {
  setUp(() async {
    firestore = FakeFirebaseFirestore();
  });

  testWidgets('UserOrderDetailsPage: se construit avec image board', (
    tester,
  ) async {
    // 1) seed d’abord
    await firestore.collection('skateboards').doc('sk1').set({
      'imageUrl': 'http://img',
    });

    // 2) prépare l’order AVANT usage
    final order = {
      'skateboardId': 'sk1',
      'name': 'Tibo',
      'address': '12 rue test',
      'price': 199.9,
      'status': 'payée',
      'timestamp': Timestamp.now(),
    };

    // 3) pump à l’intérieur du mock réseau
    await mockNetworkImagesFor(() async {
      final app = await pumpApp(UserOrderDetailsPage(orderData: order));
      await tester.pumpWidget(app);
      await tester.pump(const Duration(milliseconds: 50));
    });

    expect(find.byType(UserOrderDetailsPage), findsOneWidget);
  });
}
