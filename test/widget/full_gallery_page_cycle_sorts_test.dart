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

  testWidgets('FullGallery: cycle sur plusieurs options de tri sans crash', (
    tester,
  ) async {
    // seed
    for (final data in [
      {
        'imageUrl': 'http://1',
        'thumbUrl': 'http://1',
        'price': '100',
        'isSold': false,
        'createdAt': DateTime(2030, 1, 1),
      },
      {
        'imageUrl': 'http://2',
        'thumbUrl': 'http://2',
        'price': '250',
        'isSold': true,
        'createdAt': DateTime(2030, 1, 2),
      },
      {
        'imageUrl': 'http://3',
        'thumbUrl': 'http://3',
        'price': '150',
        'isSold': false,
        'createdAt': DateTime(2030, 1, 3),
      },
    ]) {
      await firestore.collection('skateboards').add(data);
    }

    await mockNetworkImagesFor(() async {
      final app = await pumpApp(const FullGalleryPage());
      await tester.pumpWidget(app);
      await tester.pump(const Duration(milliseconds: 150));
    });

    // ouvre le contrôleur (Dropdown ou PopupMenu) et sélectionne plusieurs items
    Finder? control;
    if (find.byType(DropdownButton).evaluate().isNotEmpty) {
      control = find.byType(DropdownButton).first;
    } else if (find.byType(PopupMenuButton).evaluate().isNotEmpty) {
      control = find.byType(PopupMenuButton).first;
    }

    if (control != null) {
      await tester.ensureVisible(control);
      await tester.tap(control);
      await tester.pump(const Duration(milliseconds: 80));

      // tape jusqu’à 3 options différentes, selon ce qui est rendu
      final options = [
        find.text('Plus récent'),
        find.text('Plus ancien'),
        find.text('Prix croissant'),
        find.text('Prix décroissant'),
        find.byType(PopupMenuItem),
        find.byType(DropdownMenuItem),
      ];

      var taps = 0;
      for (final f in options) {
        if (f.evaluate().isNotEmpty) {
          await tester.tap(f.first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 120));
          taps++;
          if (taps >= 3) break;
          // rouvre si nécessaire
          await tester.tap(control);
          await tester.pump(const Duration(milliseconds: 60));
        }
      }
    }

    expect(find.byType(FullGalleryPage), findsOneWidget);
  });
}
