import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/services/order_service.dart';

void main() {
  setUp(() async {
    firebaseAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'u1', email: 'x@y.z'),
    );
    firestore = FakeFirebaseFirestore();
  });

  test('saveOrder écrit la commande et marque la planche vendue', () async {
    await firestore.collection('skateboards').doc('sk1').set({'isSold': false});

    await OrderService.saveOrder(
      skateboardId: 'sk1',
      buyerName: 'Tibo',
      buyerEmail: 't@t.com',
      buyerPhone: '0600000000',
      buyerAddress: '12 rue des tests',
      price: 199.90,
    );

    final orders = await firestore.collection('orders').get();
    expect(orders.docs.length, 1);
    expect(orders.docs.first.data()['status'], 'payée');
    expect(orders.docs.first.data()['userId'], 'u1');

    final board = await firestore.collection('skateboards').doc('sk1').get();
    expect(board.data()?['isSold'], true);
  });
}
