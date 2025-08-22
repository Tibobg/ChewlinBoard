import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import '../helpers/pump_app.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/pagesAdmin/admin_chat_page.dart';

void main() {
  setUp(() async {
    firebaseAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'admin'),
    );
    firestore = FakeFirebaseFirestore();

    // (Parent optionnel ; la page peut le créer elle-même)
    await firestore.collection('users').doc('u1').set({'pseudo': 'User 1'});
  });

  testWidgets('AdminChatPage: envoi d’un message', (tester) async {
    final app = await pumpApp(
      const AdminChatPage(userUid: 'u1', pseudo: 'User 1'),
    );
    await tester.pumpWidget(app);
    await tester.pump(const Duration(milliseconds: 80));

    final input = find.byType(TextField);
    expect(input, findsOneWidget);
    await tester.enterText(input, 'hello from admin');

    final send = find.byIcon(Icons.send);
    expect(send, findsOneWidget);
    await tester.tap(send);
    await tester.pump(const Duration(milliseconds: 120));

    // Cherche un parent avec au moins un sous-message
    final parents = await firestore.collection('messages').get();
    bool hasMessages = false;
    for (final d in parents.docs) {
      final sub =
          await firestore
              .collection('messages')
              .doc(d.id)
              .collection('messages')
              .get();
      if (sub.docs.isNotEmpty) {
        hasMessages = true;
        break;
      }
    }
    expect(hasMessages, true);
  });
}
