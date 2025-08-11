import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart'; // ^3.0.2
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart'; // ^0.14.2
import '../helpers/firebase_test_setup.dart';
import 'package:chewlin_board/repositories/user_repository.dart';

void main() {
  setUpAll(setupFirebaseForTests);

  test('getMe retourne null si non connecté', () async {
    final repo = UserRepository(
      db: FakeFirebaseFirestore(),
      auth: MockFirebaseAuth(), // pas connecté
    );
    expect(await repo.getMe(), isNull);
  });

  test('getMe retourne les données quand connecté', () async {
    final db = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'u1'),
    );
    await db.collection('users').doc('u1').set({'name': 'Tibo'});

    final repo = UserRepository(db: db, auth: auth);
    final me = await repo.getMe();
    expect(me, isNotNull);
    expect(me!['name'], 'Tibo');
  });

  test('upsertMe merge les données et jette si non auth', () async {
    final db = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'u2'),
    );
    final repo = UserRepository(db: db, auth: auth);

    await repo.upsertMe({'role': 'user'});
    final snap = await db.collection('users').doc('u2').get();
    expect(snap.data()!['role'], 'user');

    final repoNoAuth = UserRepository(db: db, auth: MockFirebaseAuth());
    expect(() => repoNoAuth.upsertMe({}), throwsStateError);
  });
}
