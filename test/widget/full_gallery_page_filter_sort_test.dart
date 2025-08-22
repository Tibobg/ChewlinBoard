import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/pages/user/full_gallery_page.dart';
import '../helpers/pump_app.dart';
import '../helpers/mock_network_images.dart';

void main() {
  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  testWidgets('FullGalleryPage: render + change tri/filtre (smoke)', (
    tester,
  ) async {
    // seed galerie avec états/pri(x) variés
    await firestore.collection('skateboards').add({
      'imageUrl': 'http://img1',
      'thumbUrl': 'http://img1',
      'price': '100',
      'isSold': false,
      'createdAt': DateTime.now().subtract(const Duration(days: 1)),
    });
    await firestore.collection('skateboards').add({
      'imageUrl': 'http://img2',
      'thumbUrl': 'http://img2',
      'price': '250',
      'isSold': true,
      'createdAt': DateTime.now(),
    });
    await firestore.collection('skateboards').add({
      'imageUrl': 'http://img3',
      'thumbUrl': 'http://img3',
      'price': '150',
      'isSold': false,
      'createdAt': DateTime.now().subtract(const Duration(days: 2)),
    });

    await mockNetworkImagesFor(() async {
      final app = await pumpApp(const FullGalleryPage());
      await tester.pumpWidget(app);
      await tester.pump(const Duration(milliseconds: 120));
    });

    expect(find.byType(FullGalleryPage), findsOneWidget);

    // essaie d’ouvrir un tri/filtre s’il existe (Dropdown, PopupMenu, Chips…)
    Finder? control;
    final dropdown = find.byType(DropdownButton);
    final popup = find.byType(PopupMenuButton);
    final chips = find.byType(ChoiceChip);
    if (dropdown.evaluate().isNotEmpty)
      control = dropdown.first;
    else if (popup.evaluate().isNotEmpty)
      control = popup.first;

    if (control != null) {
      await tester.ensureVisible(control);
      await tester.tap(control);
      await tester.pump(const Duration(milliseconds: 60));
      // choisis un item quelconque si des options apparaissent
      final anyItem = find.byType(PopupMenuItem).first;
      if (anyItem.evaluate().isNotEmpty) {
        await tester.tap(anyItem);
        await tester.pump(const Duration(milliseconds: 80));
      } else {
        // parfois DropdownMenuItem est dans l’arbre
        final dItem = find.byType(DropdownMenuItem).last;
        if (dItem.evaluate().isNotEmpty) {
          await tester.tap(dItem);
          await tester.pump(const Duration(milliseconds: 80));
        }
      }
    } else if (chips.evaluate().isNotEmpty) {
      // toggle un chip
      await tester.tap(chips.first);
      await tester.pump(const Duration(milliseconds: 80));
    }

    // Sanity: l’écran est toujours présent (pas de crash)
    expect(find.byType(FullGalleryPage), findsOneWidget);
  });
}
