// test/unit/orders_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// === À ADAPTER avec ton vrai repository ===
class OrdersRepository {
  OrdersRepository({required this.db, required this.auth});
  final FakeFirebaseFirestore db;
  final MockFirebaseAuth auth;

  Future<Map<String, dynamic>?> getOrder(String id) async {
    final snap = await db.collection('orders').doc(id).get();
    return snap.data();
  }

  Future<List<Map<String, dynamic>>> listOrdersForUser(String userId) async {
    final qs =
        await db.collection('orders').where('buyerId', isEqualTo: userId).get();
    return qs.docs.map((d) => d.data()).toList();
  }

  Future<void> updateStatus(String id, String status) async {
    final u = auth.currentUser;
    if (u == null) throw StateError('no-auth');
    await db.collection('orders').doc(id).set({
      'status': status,
    }, SetOptions(merge: true));
  }
}

void main() {
  test('getOrder retourne null si inexistant', () async {
    final repo = OrdersRepository(
      db: FakeFirebaseFirestore(),
      auth: MockFirebaseAuth(),
    );
    expect(await repo.getOrder('missing'), isNull);
  });

  test(
    'listOrdersForUser retourne uniquement les commandes de l’utilisateur',
    () async {
      final db = FakeFirebaseFirestore();
      await db.collection('orders').doc('o1').set({
        'buyerId': 'u1',
        'status': 'paid',
      });
      await db.collection('orders').doc('o2').set({
        'buyerId': 'u2',
        'status': 'paid',
      });
      final repo = OrdersRepository(db: db, auth: MockFirebaseAuth());
      final list = await repo.listOrdersForUser('u1');
      expect(list.length, 1);
      expect(list.first['status'], 'paid');
    },
  );

  test('updateStatus merge et jette si non auth', () async {
    final db = FakeFirebaseFirestore();
    await db.collection('orders').doc('o3').set({
      'buyerId': 'u1',
      'status': 'created',
    });

    final auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'admin'),
    );
    final repo = OrdersRepository(db: db, auth: auth);
    await repo.updateStatus('o3', 'paid');

    final snap = await db.collection('orders').doc('o3').get();
    expect(snap.data()!['status'], 'paid');

    final repoNoAuth = OrdersRepository(db: db, auth: MockFirebaseAuth());
    expect(() => repoNoAuth.updateStatus('o3', 'canceled'), throwsStateError);
  });
}
