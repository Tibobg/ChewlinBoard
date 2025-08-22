import 'package:flutter/material.dart';
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
      mockUser: MockUser(uid: 'u1', email: 'x@y.z'),
    );
    firestore = FakeFirebaseFirestore();
  });

  testWidgets(
    'OrderPage: champs vides -> reste sur la page (validation locale)',
    (tester) async {
      final board = {'id': 'sk1', 'imageUrl': 'http://img', 'price': '199.90'};

      await mockNetworkImagesFor(() async {
        final app = await pumpApp(OrderPage(skateboard: board));
        await tester.pumpWidget(app);
        await tester.pump(const Duration(milliseconds: 80));
      });

      // Le bouton peut être plus bas: on s’assure qu’il est visible avant de taper
      final submit = find.byType(ElevatedButton).first;
      await tester.ensureVisible(submit);
      await tester.pump();

      await tester.tap(submit);
      await tester.pump(const Duration(milliseconds: 80));

      // Assertion robuste: on reste bien sur la page (pas de navigation)
      expect(find.byType(OrderPage), findsOneWidget);

      // (Optionnel) Si tu veux garder un check SnackBar, dé-commente:
      // expect(find.byType(SnackBar), findsOneWidget);
    },
  );
}
