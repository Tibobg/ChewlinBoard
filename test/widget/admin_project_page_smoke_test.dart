import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/pages/user/success_page.dart';
import '../helpers/pump_app.dart';
import '../helpers/mock_network_images.dart';

void main() {
  setUp(() async {
    firebaseAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'u1', email: 'x@y.z'),
    );
    firestore = FakeFirebaseFirestore();
    await firestore.collection('skateboards').doc('sk1').set({'isSold': false});
  });

  testWidgets('SuccessPage (galerie): écrit order + message', (tester) async {
    final page = SuccessPage(
      skateboardId: 'sk1',
      buyerName: 'Tibo',
      buyerEmail: 'x@y.z',
      buyerPhone: '0600000000',
      buyerAddress: '12 rue des tests',
      price: 199.90,
      isProjectOrder: false,
    );

    await mockNetworkImagesFor(() async {
      final app = await pumpApp(page);
      await tester.pumpWidget(app);
      await tester.pump(const Duration(milliseconds: 50));
    });

    final orders = await firestore.collection('orders').get();
    expect(orders.docs.length, 1);

    final msgs = await firestore.collection('messages').get();
    expect(msgs.docs.isNotEmpty, true);
  });
}
