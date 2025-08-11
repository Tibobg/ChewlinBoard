import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  final FirebaseFirestore db;
  final FirebaseAuth auth;

  UserRepository({required this.db, required this.auth});

  Future<Map<String, dynamic>?> getMe() async {
    final u = auth.currentUser;
    if (u == null) return null;
    final doc = await db.collection('users').doc(u.uid).get();
    return doc.data();
  }

  Future<void> upsertMe(Map<String, dynamic> data) async {
    final u = auth.currentUser;
    if (u == null) throw StateError('no-auth');
    await db.collection('users').doc(u.uid).set(data, SetOptions(merge: true));
  }
}
