import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/pages/user/user_order_details_page.dart';

import '../helpers/pump_app.dart';
import '../helpers/mock_network_images.dart';

void main() {
  setUp(() async {
    firebaseAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'u1'),
    );
    firestore = FakeFirebaseFirestore();

    // board associée à la commande
    await firestore.collection('skateboards').doc('sk1').set({
      'imageUrl': 'http://img', // Image.network -> mock nécessaire
    });
  });

  testWidgets('UserOrderDetailsPage: affiche les infos et charge la board', (
    tester,
  ) async {
    final orderData = {
      'userId': 'u1',
      'skateboardId': 'sk1',
      'name': 'Tibo',
      'address': '12 rue test',
      'price': 199.9,
      'status': 'payée',
      'timestamp': Timestamp.now(),
    };

    await mockNetworkImagesFor(() async {
      final app = await pumpApp(UserOrderDetailsPage(orderData: orderData));
      await tester.pumpWidget(app);
      await tester.pump(
        const Duration(milliseconds: 150),
      ); // fetchBoard + build
    });

    expect(find.byType(UserOrderDetailsPage), findsOneWidget);

    // Sanity checks robustes (pas de libellés fragiles)
    expect(find.textContaining('Statut'), findsWidgets); // "Statut : payée"
    expect(find.byType(Image), findsWidgets); // image board mockée
  });
}
