import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/pages/user/success_page.dart';
import '../helpers/pump_app.dart';

void main() {
  setUp(() async {
    firebaseAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'u1', email: 'x@y.z'),
    );
    firestore = FakeFirebaseFirestore();
    await firestore.collection('skateboards').doc('sk1').set({'isSold': false});
  });

  testWidgets('SuccessPage: achat galerie -> écrit order + message', (
    tester,
  ) async {
    final w = SuccessPage(
      skateboardId: 'sk1',
      buyerName: 'Tibo',
      buyerEmail: 'x@y.z',
      buyerPhone: '0600000000',
      buyerAddress: '12 rue des tests',
      price: 199.90,
      isProjectOrder: false,
    );

    final app = await pumpApp(w);
    await tester.pumpWidget(app);
    // laisse initState/_handleAfterPayment s’exécuter
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(SuccessPage), findsOneWidget);

    final orders = await firestore.collection('orders').get();
    expect(orders.docs.length, 1);

    final msgsParent = await firestore.collection('messages').get();
    expect(msgsParent.docs.length, 1);
  });
}
