import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:chewlin_board/services/auth_service.dart';

class MockAuth extends Mock implements FirebaseAuth {}

void main() {
  test('signUp: email-in-use, invalid-email, weak-password, défaut', () async {
    final mock = MockAuth();
    final db = FakeFirebaseFirestore();
    final service = AuthService(auth: mock, firestore: db);

    // email-already-in-use
    when(
      () => mock.createUserWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(
      FirebaseAuthException(code: 'email-already-in-use', message: 'x'),
    );
    expect(await service.signUp('dup@test.com', 'x', 'dup'), isNull);
    expect(AuthService.lastErrorMessage, 'Cet email est déjà utilisé.');

    // invalid-email
    when(
      () => mock.createUserWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(FirebaseAuthException(code: 'invalid-email', message: 'x'));
    await service.signUp('bad', 'x', 'p');
    expect(AuthService.lastErrorMessage, 'Email invalide.');

    // weak-password
    when(
      () => mock.createUserWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(FirebaseAuthException(code: 'weak-password', message: 'x'));
    await service.signUp('ok@test.com', '1', 'p');
    expect(AuthService.lastErrorMessage, 'Le mot de passe est trop faible.');

    // défaut -> reprend e.message
    when(
      () => mock.createUserWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(FirebaseAuthException(code: 'random', message: 'oops'));
    await service.signUp('ok@test.com', 'pass', 'p');
    expect(AuthService.lastErrorMessage, 'oops');

    // signOut qui jette -> couvre le catch de signOut
    when(() => mock.signOut()).thenThrow(Exception('boom'));
    await service.signOut(); // ne jette pas, catch interne
  });
}
