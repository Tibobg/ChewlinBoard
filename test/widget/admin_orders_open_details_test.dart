import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/pagesAdmin/admin_orders_page.dart';
import 'package:chewlin_board/pagesAdmin/admin_order_details_page.dart';
import '../helpers/pump_app.dart';
import '../helpers/mock_network_images.dart';

void main() {
  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  testWidgets('AdminOrdersPage: tap sur un item ouvre AdminOrderDetailsPage', (
    tester,
  ) async {
    // seed board + order
    await firestore.collection('skateboards').doc('sk1').set({
      'imageUrl': 'http://img',
    });
    await firestore.collection('orders').add({
      'name': 'Tibo',
      'address': '12 rue test',
      'status': 'payée',
      'price': 199.9,
      'skateboardId': 'sk1',
      'timestamp': Timestamp.now(),
    });

    await mockNetworkImagesFor(() async {
      final app = await pumpApp(const AdminOrdersPage());
      await tester.pumpWidget(app);
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pumpAndSettle(const Duration(milliseconds: 50));
    });

    // Attendre qu’au moins un candidat apparaisse
    Future<Finder?> waitForAnyItem() async {
      for (var i = 0; i < 10; i++) {
        final text = find.textContaining('Tibo');
        if (text.evaluate().isNotEmpty) return text;
        final tile = find.byType(ListTile);
        if (tile.evaluate().isNotEmpty) return tile;
        final ink = find.byType(InkWell);
        if (ink.evaluate().isNotEmpty) return ink;
        await tester.pump(const Duration(milliseconds: 80));
      }
      return null;
    }

    final candidate = await waitForAnyItem();
    expect(candidate, isNotNull, reason: 'Aucun item de commande rendu');

    // Si c’est un texte, remonte à un parent cliquable si possible
    Finder target = candidate!;
    if (find.byType(ListTile).evaluate().isEmpty) {
      final inkParent = find.ancestor(
        of: target,
        matching: find.byType(InkWell),
      );
      if (inkParent.evaluate().isNotEmpty) target = inkParent;
      final gdParent = find.ancestor(
        of: target,
        matching: find.byType(GestureDetector),
      );
      if (gdParent.evaluate().isNotEmpty) target = gdParent;
    }

    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pumpAndSettle(const Duration(milliseconds: 120));

    expect(find.byType(AdminOrderDetailsPage), findsOneWidget);
  });
}
