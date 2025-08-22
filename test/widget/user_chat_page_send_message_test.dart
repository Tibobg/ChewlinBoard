import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/pages/user/user_chat_page.dart';
import '../helpers/pump_app.dart';

void main() {
  setUp(() async {
    firebaseAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'u1'),
    );
    firestore = FakeFirebaseFirestore();

    // seed fil de discussion u1 <-> admin
    const adminUid = 'wjGx853IYFTe2hrtNxrSvTKc23h1';
    final chatId = 'u1_$adminUid';

    await firestore.collection('messages').doc(chatId).set({
      'participants': ['u1', adminUid],
      'updatedAt': Timestamp.now(),
    });

    // au moins un doc user admin (si la page lit le pseudo)
    await firestore.collection('users').doc(adminUid).set({'pseudo': 'Admin'});
  });

  testWidgets('UserChatPage: envoi d’un message', (tester) async {
    final app = await pumpApp(const UserChatPage());
    await tester.pumpWidget(app);
    await tester.pump(const Duration(milliseconds: 60));

    // Entre un texte et appuie sur l’icône d’envoi
    final input = find.byType(TextField);
    expect(input, findsOneWidget);
    await tester.enterText(input, 'hello world');

    final send = find.byIcon(Icons.send);
    expect(send, findsOneWidget);
    await tester.tap(send);
    await tester.pump(const Duration(milliseconds: 60));

    // Vérifie qu’un message a été ajouté quelque part
    final msgsParents = await firestore.collection('messages').get();
    expect(msgsParents.docs.isNotEmpty, true);
    // Et qu’au moins un sous-message existe
    final parentId = msgsParents.docs.first.id;
    final sub =
        await firestore
            .collection('messages')
            .doc(parentId)
            .collection('messages')
            .get();
    expect(sub.docs.isNotEmpty, true);
  });
}
