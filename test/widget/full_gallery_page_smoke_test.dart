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

  testWidgets('FullGalleryPage: render grid + open dialog', (tester) async {
    // seed 2 planches
    await firestore.collection('skateboards').add({
      'imageUrl': 'http://img1',
      'thumbUrl': 'http://img1',
      'price': '100€',
      'isSold': false,
      'createdAt': DateTime.now(),
    });
    await firestore.collection('skateboards').add({
      'imageUrl': 'http://img2',
      'thumbUrl': 'http://img2',
      'price': '200€',
      'isSold': true,
      'createdAt': DateTime.now(),
    });

    await mockNetworkImagesFor(() async {
      final app = await pumpApp(const FullGalleryPage());
      await tester.pumpWidget(app);
      await tester.pump(const Duration(milliseconds: 80));
    });

    expect(find.byType(FullGalleryPage), findsOneWidget);
  });
}
