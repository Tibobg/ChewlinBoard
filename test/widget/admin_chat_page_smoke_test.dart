import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/pagesAdmin/admin_chat_page.dart';
import '../helpers/pump_app.dart';

void main() {
  setUp(() async {
    firebaseAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'admin'),
    );
    firestore = FakeFirebaseFirestore();
  });

  testWidgets('AdminChatPage: se construit avec messages', (tester) async {
    // Seed: conv admin <-> u1
    final chatId = 'u1_admin';
    await firestore.collection('messages').doc(chatId).set({
      'participants': ['u1', 'admin'],
      'updatedAt': Timestamp.now(),
    });
    await firestore
        .collection('messages')
        .doc(chatId)
        .collection('messages')
        .add({
          'senderId': 'u1',
          'text': 'hello',
          'createdAt': Timestamp.now(),
          'isRead': false,
        });
    await firestore
        .collection('messages')
        .doc(chatId)
        .collection('messages')
        .add({
          'senderId': 'admin',
          'text': 'yo',
          'createdAt': Timestamp.now(),
          'isRead': true,
        });

    final app = await pumpApp(
      const AdminChatPage(userUid: 'u1', pseudo: 'User 1'),
    );
    await tester.pumpWidget(app);
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(AdminChatPage), findsOneWidget);
  });
}
