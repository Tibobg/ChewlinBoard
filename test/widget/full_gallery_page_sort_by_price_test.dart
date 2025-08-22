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

  testWidgets('FullGalleryPage: tri "Prix croissant"', (tester) async {
    // 2 dispo, 1 vendu (le tri price_asc filtre aux dispos)
    await firestore.collection('skateboards').add({
      'imageUrl': 'http://img1',
      'thumbUrl': 'http://img1',
      'price': '300',
      'isSold': false,
      'createdAt': DateTime.now().subtract(const Duration(days: 1)),
    });
    await firestore.collection('skateboards').add({
      'imageUrl': 'http://img2',
      'thumbUrl': 'http://img2',
      'price': '120',
      'isSold': false,
      'createdAt': DateTime.now(),
    });
    await firestore.collection('skateboards').add({
      'imageUrl': 'http://img3',
      'thumbUrl': 'http://img3',
      'price': '999',
      'isSold': true,
      'createdAt': DateTime.now(),
    });

    await mockNetworkImagesFor(() async {
      final app = await pumpApp(const FullGalleryPage());
      await tester.pumpWidget(app);
      await tester.pump(const Duration(milliseconds: 150));
    });

    expect(find.byType(FullGalleryPage), findsOneWidget);

    // Ouvre le Dropdown et sélectionne "Prix croissant"
    final dropdown = find.byType(DropdownButton<String>);
    expect(dropdown, findsOneWidget);

    await tester.tap(dropdown);
    await tester.pump(const Duration(milliseconds: 60));

    final option =
        find.text('Prix croissant').last; // libellé exact dans la page
    await tester.tap(option);
    await tester.pump(const Duration(milliseconds: 120));

    // Sanity: toujours là (pas de crash) ; la grille s’est reconstruite.
    expect(find.byType(FullGalleryPage), findsOneWidget);
  });
}
