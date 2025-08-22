import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/services/order_service.dart';

void main() {
  setUp(() async {
    firebaseAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'u1', email: 'x@y.z'),
    );
    firestore = FakeFirebaseFirestore();

    // planche dispo
    await firestore.collection('skateboards').doc('sk1').set({
      'isSold': false,
      'imageUrl': 'http://img',
    });
  });

  test(
    'OrderService.saveOrder: crée la commande et marque la board vendue',
    () async {
      await OrderService.saveOrder(
        skateboardId: 'sk1',
        buyerName: 'Tibo',
        buyerEmail: 'x@y.z',
        buyerPhone: '0600000000',
        buyerAddress: '12 rue test',
        price: 199.9,
      );

      // 1) un doc dans orders
      final orders = await firestore.collection('orders').get();
      expect(orders.docs.length, 1);
      final data = orders.docs.first.data();
      expect(data['userId'], 'u1');
      expect(data['skateboardId'], 'sk1');
      expect(data['status'], 'payée');
      expect(data['price'], 199.9);

      // 2) board marquée vendue
      final sk = await firestore.collection('skateboards').doc('sk1').get();
      expect(sk.data()?['isSold'], true);
    },
  );
}
