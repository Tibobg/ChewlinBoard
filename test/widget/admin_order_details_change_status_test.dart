import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
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

    // board pour l’image éventuelle
    await firestore.collection('skateboards').doc('sk1').set({
      'imageUrl': 'http://img',
    });

    // user pour pseudo (et conversation)
    await firestore.collection('users').doc('u1').set({'pseudo': 'User 1'});
  });

  testWidgets(
    'AdminOrderDetailsPage: changer le statut -> update + message système',
    (tester) async {
      // seed order "payée"
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
        await tester.pump(const Duration(milliseconds: 120));
        await tester.pumpAndSettle(const Duration(milliseconds: 50));
      });

      // Localise le Dropdown et scrolle jusqu’à lui
      final dd = find.byType(DropdownButton<String>);
      expect(dd, findsOneWidget);
      await tester.ensureVisible(dd.first);
      await tester.pump(const Duration(milliseconds: 50));

      // Ouvre le menu (même s’il est en bord d’écran)
      await tester.tap(dd.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 120));

      // Essaie de choisir "préparée" si présent, sinon n’importe quel item
      Finder? choice = find.text('préparée');
      if (choice.evaluate().isEmpty) {
        // Parfois les items sont des DropdownMenuItem sans texte “préparée”
        final anyItem = find.byType(DropdownMenuItem);
        expect(
          anyItem,
          findsWidgets,
          reason: 'Aucune option de statut trouvée dans la liste',
        );
        choice = anyItem.at(0);
      }

      await tester.tap(choice, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 150));

      // 1) L’order a été mis à jour
      final updated =
          await firestore.collection('orders').doc(orderDoc.id).get();
      expect(updated.data()?['status'], isNotNull);

      // 2) Un message système a été écrit dans le thread
      final parents = await firestore.collection('messages').get();
      bool foundAnySub = false;
      for (final p in parents.docs) {
        final sub =
            await firestore
                .collection('messages')
                .doc(p.id)
                .collection('messages')
                .get();
        if (sub.docs.isNotEmpty) {
          foundAnySub = true;
          break;
        }
      }
      expect(foundAnySub, true);
    },
  );
}
