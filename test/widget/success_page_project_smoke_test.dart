import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/pages/user/success_page.dart';
import '../helpers/pump_app.dart';
import '../helpers/mock_network_images.dart'; // mockNetworkImagesFor

void main() {
  setUp(() async {
    firebaseAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'u1', email: 'x@y.z'),
    );
    firestore = FakeFirebaseFirestore();

    // Doc projet minimal (ajuste si ta page lit d'autres champs)
    await firestore.collection('projects').doc('p1').set({
      'ownerId': 'u1',
      'createdAt': Timestamp.now(),
      'status': 'draft',
      'imagePaths': [],
    });

    // Doc planche factice (requis car SuccessPage demande toujours skateboardId)
    await firestore.collection('skateboards').doc('sk_dummy').set({
      'isSold': false,
      'imageUrl': 'http://img', // au cas où un Image.network est construit
    });
  });

  testWidgets('SuccessPage (projet): écrit order + message système', (
    tester,
  ) async {
    final page = SuccessPage(
      isProjectOrder: true,
      projectId: 'p1',
      skateboardId: 'sk_dummy', // <-- requis par le constructeur
      buyerName: 'Tibo',
      buyerEmail: 'x@y.z',
      buyerPhone: '0600000000',
      buyerAddress: '12 rue des tests',
      price: 249.90,
    );

    await mockNetworkImagesFor(() async {
      final app = await pumpApp(page);
      await tester.pumpWidget(app);
      await tester.pump(
        const Duration(milliseconds: 80),
      ); // laisse initState tourner
    });

    final orders = await firestore.collection('orders').get();
    expect(orders.docs.isNotEmpty, true);

    final parents = await firestore.collection('messages').get();
    expect(parents.docs.isNotEmpty, true);

    expect(find.byType(SuccessPage), findsOneWidget);
  });
}
