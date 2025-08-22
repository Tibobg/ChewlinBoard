import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/pages/user/user_chat_page.dart';
import '../helpers/pump_app.dart';

void main() {
  const adminUid = 'wjGx853IYFTe2hrtNxrSvTKc23h1';

  setUp(() async {
    firebaseAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'u1'),
    );
    firestore = FakeFirebaseFirestore();

    // thread u1 <-> admin
    final chatId = 'u1_$adminUid';
    await firestore.collection('messages').doc(chatId).set({
      'participants': ['u1', adminUid],
      'updatedAt': Timestamp.now(),
    });
    await firestore.collection('users').doc(adminUid).set({'pseudo': 'Admin'});

    // message non lu envoyé par l'admin
    await firestore
        .collection('messages')
        .doc(chatId)
        .collection('messages')
        .add({
          'senderId': adminUid,
          'text': 'hello',
          'createdAt': Timestamp.now(),
          'isRead': false,
        });
  });

  testWidgets(
    'UserChatPage: ouvre le fil et marque les messages admin comme lus',
    (tester) async {
      final app = await pumpApp(const UserChatPage());
      await tester.pumpWidget(app);

      // laisse les stream/futures s’exécuter
      await tester.pump(const Duration(milliseconds: 120));

      // vérifie qu’au moins un message est maintenant isRead:true
      final parents = await firestore.collection('messages').get();
      bool hasRead = false;
      for (final p in parents.docs) {
        final sub =
            await firestore
                .collection('messages')
                .doc(p.id)
                .collection('messages')
                .get();
        for (final m in sub.docs) {
          if (m.data()['isRead'] == true) {
            hasRead = true;
            break;
          }
        }
        if (hasRead) break;
      }
      expect(hasRead, true);
    },
  );
}
