import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../helpers/pump_app.dart';
import '../helpers/mock_network_images.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/pagesAdmin/admin_order_details_page.dart';

void main() {
  setUp(() async {
    firebaseAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'admin'),
    );
    firestore = FakeFirebaseFirestore();
  });

  testWidgets(
    'AdminOrderDetailsPage: tap bouton “message/chat” crée/merge le thread',
    (tester) async {
      // seed user + board + order
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

      await mockNetworkImagesFor(() async {
        final app = await pumpApp(page);
        await tester.pumpWidget(app);
        await tester.pump(const Duration(milliseconds: 80));
      });

      // essaie plusieurs variantes d’icône/texte pour être robuste
      final candidates = <Finder>[
        find.byIcon(Icons.message),
        find.byIcon(Icons.chat),
        find.byIcon(Icons.forum),
        find.textContaining('Message'),
        find.textContaining('Contacter'),
        find.textContaining('Chat'),
      ];

      Finder? target;
      for (final f in candidates) {
        if (f.evaluate().isNotEmpty) {
          target = f;
          break;
        }
      }

      if (target != null) {
        await tester.ensureVisible(target);
        await tester.tap(target);
        await tester.pump(const Duration(milliseconds: 80));
      }

      // un parent de thread messages existe (ou a été mis à jour)
      final parents = await firestore.collection('messages').get();
      expect(parents.docs.isNotEmpty, true);
    },
  );
}
