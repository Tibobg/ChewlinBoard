import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/pages/user/user_chat_page.dart';
import '../../helpers/pump_app.dart';

void main() {
  setUp(() async {
    firebaseAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'u1'),
    );
    firestore = FakeFirebaseFirestore();
  });

  testWidgets('UserChatPage: se construit avec messages', (tester) async {
    final adminUid = 'wjGx853IYFTe2hrtNxrSvTKc23h1';
    final chatId = 'u1_$adminUid';

    await firestore.collection('messages').doc(chatId).set({
      'participants': ['u1', adminUid],
      'updatedAt': Timestamp.now(),
    });
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
    await firestore
        .collection('messages')
        .doc(chatId)
        .collection('messages')
        .add({
          'senderId': 'u1',
          'text': 'yo',
          'createdAt': Timestamp.now(),
          'isRead': true,
        });

    final app = await pumpApp(const UserChatPage());
    await tester.pumpWidget(app);
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(UserChatPage), findsOneWidget);
  });
}
