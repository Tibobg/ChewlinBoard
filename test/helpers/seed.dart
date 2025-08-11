import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedForUserFlow(
  FakeFirebaseFirestore db, {
  required String uid,
  String pseudo = 'Tibo',
}) async {
  await db.collection('users').doc(uid).set({
    'pseudo': pseudo,
    'email': 'u@u.com',
  });

  await db.collection('orders').add({
    'userId': uid,
    'status': 'payée',
    'timestamp': Timestamp.now(),
  });

  // conversation + message non lu venant d’un autre user
  final conv = await db.collection('messages').add({
    'participants': [uid, 'other'],
  });
  await db.collection('messages').doc(conv.id).collection('messages').add({
    'senderId': 'other',
    'isRead': false,
    'text': 'hello',
    'timestamp': Timestamp.now(),
  });
}

Future<void> seedForAdminFlow(
  FakeFirebaseFirestore db, {
  required String adminUid,
}) async {
  await db.collection('users').doc('u2').set({
    'pseudo': 'User 2',
    'email': 'u2@test.com',
  });

  // conversation avec non-lu venant de u2
  final conv1 = await db.collection('messages').add({
    'participants': [adminUid, 'u2'],
  });
  await db.collection('messages').doc(conv1.id).collection('messages').add({
    'senderId': 'u2',
    'isRead': false,
    'text': 'yo',
    'timestamp': Timestamp.now(),
  });

  for (var i = 0; i < 3; i++) {
    await db.collection('orders').add({
      'userId': 'u$i',
      'status': 'payée',
      'timestamp': Timestamp.now(),
      'name': 'Planche #$i',
    });
  }
}
