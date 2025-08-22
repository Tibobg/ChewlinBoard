import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../helpers/mock_network_images.dart';
import '../helpers/pump_app.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/pages/user/profile_page.dart';

void main() {
  setUp(() async {
    firebaseAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'u1', email: 'x@y.z'),
    );
    firestore = FakeFirebaseFirestore();

    // seed minimal user
    await firestore.collection('users').doc('u1').set({
      'pseudo': 'User One',
      'email': 'x@y.z',
    });

    // seed un board + une commande
    await firestore.collection('skateboards').doc('sk1').set({
      'imageUrl': 'http://img',
    });
    await firestore.collection('orders').add({
      'userId': 'u1',
      'skateboardId': 'sk1',
      'name': 'Tibo',
      'address': '12 rue test',
      'price': 199.9,
      'status': 'payée',
      'timestamp': Timestamp.now(),
    });

    // seed un projet
    await firestore.collection('projects').add({
      'ownerId': 'u1',
      'createdAt': Timestamp.now(),
      'status': 'draft',
      'imagePaths': [],
    });
  });

  testWidgets('ProfilePage: se construit et charge listes', (tester) async {
    await mockNetworkImagesFor(() async {
      final app = await pumpApp(const ProfilePage());
      await tester.pumpWidget(app);
      await tester.pump(
        const Duration(milliseconds: 120),
      ); // laisse streams se mettre à jour
    });

    expect(find.byType(ProfilePage), findsOneWidget);
  });
}
