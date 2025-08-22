import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import '../helpers/pump_app.dart';
import '../helpers/mock_network_images.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/pages/user/success_page.dart';

void main() {
  setUp(() async {
    firebaseAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'u1', email: 'x@y.z'),
    );
    firestore = FakeFirebaseFirestore();

    await firestore.collection('skateboards').doc('sk_ok').set({
      'imageUrl': 'http://img',
      'isSold': false,
    });
  });

  testWidgets('SuccessPage (board): écrit order + message système', (
    tester,
  ) async {
    final page = SuccessPage(
      isProjectOrder: false,
      skateboardId: 'sk_ok',
      buyerName: 'Tibo',
      buyerEmail: 'x@y.z',
      buyerPhone: '0600000000',
      buyerAddress: '12 rue des tests',
      price: 199.9,
    );

    await mockNetworkImagesFor(() async {
      final app = await pumpApp(page);
      await tester.pumpWidget(app);
      await tester.pump(const Duration(milliseconds: 80));
    });

    final orders = await firestore.collection('orders').get();
    expect(orders.docs.isNotEmpty, true);

    final parents = await firestore.collection('messages').get();
    expect(parents.docs.isNotEmpty, true);
  });
}
