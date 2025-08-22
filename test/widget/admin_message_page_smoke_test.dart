import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/pagesAdmin/admin_message_page.dart';
import '../helpers/pump_app.dart';

void main() {
  setUp(() async {
    firebaseAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'admin'),
    );
    firestore = FakeFirebaseFirestore();

    // parent thread
    await firestore.collection('messages').doc('u1_admin').set({
      'participants': ['u1', 'admin'],
      'lastMessage': 'hello',
      'updatedAt': Timestamp.now(),
    });

    // user doc (sans photoUrl -> pas d’image réseau)
    await firestore.collection('users').doc('u1').set({'pseudo': 'User 1'});

    // 1 message non lu coté user -> badge
    await firestore
        .collection('messages')
        .doc('u1_admin')
        .collection('messages')
        .add({
          'senderId': 'u1',
          'text': 'ping',
          'createdAt': Timestamp.now(),
          'isRead': false,
        });
  });

  testWidgets('AdminMessagePage: affiche la liste des discussions', (
    tester,
  ) async {
    final app = await pumpApp(const AdminMessagePage());
    await tester.pumpWidget(app);

    // Laisse StreamBuilder/FutureBuilder s’exécuter complètement
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    // L’écran est bien là
    expect(find.byType(AdminMessagePage), findsOneWidget);
    expect(find.textContaining('Discussions'), findsOneWidget);

    // Au moins une conversation rendue
    expect(find.byType(ListTile), findsAtLeastNWidgets(1));

    // Le dernier message "hello" (sous-titre) est souvent visible
    // (si jamais ça varie, on peut supprimer cette ligne)
    expect(find.textContaining('hello'), findsWidgets);
  });
}
