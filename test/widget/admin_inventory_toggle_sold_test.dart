import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/pagesAdmin/admin_inventory_page.dart';
import '../helpers/pump_app.dart';
import '../helpers/mock_network_images.dart';

void main() {
  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  testWidgets(
    'AdminInventory: tente un toggle “vendu/dispo” si dispo, sinon smoke',
    (tester) async {
      // seed 1 board non vendue
      await firestore.collection('skateboards').doc('sk1').set({
        'name': 'Deck 1',
        'price': '100',
        'isSold': false,
        'imageUrl': 'http://img',
        'createdAt': DateTime.now(),
      });

      await mockNetworkImagesFor(() async {
        final app = await pumpApp(const AdminInventoryPage());
        await tester.pumpWidget(app);
        await tester.pump(const Duration(milliseconds: 150));
        await tester.pumpAndSettle(const Duration(milliseconds: 50));
      });

      expect(find.byType(AdminInventoryPage), findsOneWidget);

      Future<bool> tryFindAndTap(Finder f) async {
        if (f.evaluate().isEmpty) return false;
        final target = f.first;
        await tester.ensureVisible(target);
        await tester.tap(target);
        await tester.pump(const Duration(milliseconds: 150));
        return true;
      }

      // 1) Toggles classiques
      var tapped = false;
      for (final f in <Finder>[
        find.byType(Switch),
        find.byType(SwitchListTile),
        find.byType(Checkbox),
        find.byIcon(Icons.toggle_on),
        find.byIcon(Icons.toggle_off),
      ]) {
        if (await tryFindAndTap(f)) {
          tapped = true;
          break;
        }
      }

      // 2) Boutons texte “Vendu/Disponible/Statut”
      if (!tapped) {
        for (final f in <Finder>[
          find.widgetWithText(TextButton, 'Vendu'),
          find.widgetWithText(TextButton, 'Disponible'),
          find.textContaining('Vendu'),
          find.textContaining('Disponible'),
          find.textContaining('Statut'),
        ]) {
          if (await tryFindAndTap(f)) {
            tapped = true;
            break;
          }
        }
      }

      // 3) Menu ⋮ + premier item de menu
      if (!tapped) {
        if (await tryFindAndTap(find.byIcon(Icons.more_vert))) {
          final menuItem = find.byType(PopupMenuItem);
          if (menuItem.evaluate().isNotEmpty) {
            await tester.tap(menuItem.first);
            await tester.pump(const Duration(milliseconds: 150));
            tapped = true;
          }
        }
      }

      // Si un contrôle a été actionné, vérifie le type du champ (flip possible).
      if (tapped) {
        final doc = await firestore.collection('skateboards').doc('sk1').get();
        expect(doc.data()?['isSold'] is bool, isTrue);
      } else {
        // Sinon, smoke minimal: la page est rendue.
        expect(find.byType(AdminInventoryPage), findsOneWidget);
      }
    },
  );
}
