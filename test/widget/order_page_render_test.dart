import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/pages/project/order_page.dart';
import '../helpers/pump_app.dart';
import '../helpers/mock_network_images.dart';

void main() {
  setUp(() {
    firebaseAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(email: 'x@y.z', uid: 'u1'),
    );
    firestore = FakeFirebaseFirestore();
  });

  testWidgets('OrderPage: render form (no stripe call)', (tester) async {
    final board = {'id': 'sk1', 'imageUrl': 'http://img', 'price': '199.90'};
    await mockNetworkImagesFor(() async {
      final app = await pumpApp(OrderPage(skateboard: board));
      await tester.pumpWidget(app);
      await tester.pump(const Duration(milliseconds: 80));
    });
    expect(find.byType(OrderPage), findsOneWidget);
  });
}
