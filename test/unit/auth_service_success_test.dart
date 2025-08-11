import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:chewlin_board/services/auth_service.dart';

void main() {
  test(
    'signUp écrit le pseudo, signIn OK, resetPassword OK, signOut OK',
    () async {
      final auth = MockFirebaseAuth();
      final db = FakeFirebaseFirestore();
      final service = AuthService(auth: auth, firestore: db);

      // signUp
      final user = await service.signUp('tibo@test.com', 'pass123', 'Tibo');
      expect(user, isNotNull);

      // doc users/{uid} créé avec email+pseudo
      final snap = await db.collection('users').doc(user!.uid).get();
      expect(snap.exists, true);
      expect(snap.data()!['email'], 'tibo@test.com');
      expect(snap.data()!['pseudo'], 'Tibo');

      // signOut
      await service.signOut();
      expect(service.currentUser, isNull);

      // signIn (OK)
      final uid2 = await service.signIn('tibo@test.com', 'pass123');
      expect(uid2, isNotNull);

      // resetPassword ne jette pas
      await service.sendPasswordResetEmail('tibo@test.com');
    },
  );
}
