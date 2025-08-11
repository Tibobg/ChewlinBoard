// test/unit/chat_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

class ChatService {
  ChatService(this.db);
  final FakeFirebaseFirestore db;

  Future<void> sendSystemMessage(String threadId, String text) async {
    await db.collection('chats').doc(threadId).collection('messages').add({
      'from': 'system',
      'text': text,
      'ts': DateTime.now().toUtc(),
    });
  }
}

void main() {
  test('sendSystemMessage écrit un message system', () async {
    final db = FakeFirebaseFirestore();
    final svc = ChatService(db);
    await svc.sendSystemMessage('t1', 'Order confirmed');

    final qs =
        await db.collection('chats').doc('t1').collection('messages').get();
    expect(qs.docs.length, 1);
    final msg = qs.docs.first.data();
    expect(msg['from'], 'system');
    expect(msg['text'], 'Order confirmed');
    expect(msg['ts'], isNotNull);
  });
}
