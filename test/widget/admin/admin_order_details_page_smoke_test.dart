import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../helpers/mock_network_images.dart'; // re-export de mockNetworkImagesFor
import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/pagesAdmin/admin_order_details_page.dart';
import '../../helpers/pump_app.dart';

void main() {
  setUp(() async {
    firebaseAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'admin'),
    );
    firestore = FakeFirebaseFirestore();
  });

  testWidgets('AdminOrderDetailsPage: render (smoke)', (tester) async {
    // 1) seed d’abord
    await firestore.collection('users').doc('u1').set({'pseudo': 'User 1'});
    await firestore.collection('skateboards').doc('sk1').set({
      'imageUrl': 'http://img',
    });
    final orderDoc = await firestore.collection('orders').add({
      'userId': 'u1',
      'skateboardId': 'sk1',
      'name': 'Tibo',
      'address': '12 rue test',
      'price': 199.9,
      'status': 'payée',
      'timestamp': Timestamp.now(),
    });

    // 2) construit la page avec l’ID déjà connu
    final page = AdminOrderDetailsPage(
      orderData: {
        'id': orderDoc.id,
        'userId': 'u1',
        'skateboardId': 'sk1',
        'name': 'Tibo',
        'address': '12 rue test',
        'price': 199.9,
        'status': 'payée',
        'timestamp': Timestamp.now(),
      },
    );

    // 3) pump à l’intérieur du mock réseau
    await mockNetworkImagesFor(() async {
      final app = await pumpApp(page);
      await tester.pumpWidget(app);
      await tester.pump(const Duration(milliseconds: 50));
    });

    expect(find.byType(AdminOrderDetailsPage), findsOneWidget);
  });
}
