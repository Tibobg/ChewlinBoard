import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:chewlin_board/services/auth_service.dart';

class MockAuth extends Mock implements FirebaseAuth {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const AuthCredential(providerId: 'x', signInMethod: 'x'),
    );
  });

  test(
    'signIn: mappe toutes les erreurs (invalid, too-many, network, invalid-credential, default, inattendue)',
    () async {
      final mock = MockAuth();
      final db = FakeFirebaseFirestore();
      final service = AuthService(auth: mock, firestore: db);

      // invalid-email
      when(
        () => mock.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(FirebaseAuthException(code: 'invalid-email', message: 'bad'));
      expect(await service.signIn('bad', 'x'), isNull);
      expect(AuthService.lastErrorMessage, "L'email est mal formaté.");

      // too-many-requests
      when(
        () => mock.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        FirebaseAuthException(code: 'too-many-requests', message: 'hold'),
      );
      await service.signIn('a@a.a', 'x');
      expect(
        AuthService.lastErrorMessage,
        "Trop de tentatives, veuillez réessayer plus tard.",
      );

      // network-request-failed
      when(
        () => mock.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        FirebaseAuthException(code: 'network-request-failed', message: 'net'),
      );
      await service.signIn('a@a.a', 'x');
      expect(AuthService.lastErrorMessage, "Problème de connexion réseau.");

      // invalid-credential
      when(
        () => mock.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        FirebaseAuthException(code: 'invalid-credential', message: 'cred'),
      );
      await service.signIn('a@a.a', 'x');
      expect(AuthService.lastErrorMessage, "Email ou mot de passe incorrect.");

      // défaut (code inconnu)
      when(
        () => mock.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(FirebaseAuthException(code: 'weird', message: 'oops'));
      await service.signIn('a@a.a', 'x');
      expect(AuthService.lastErrorMessage, "Erreur inconnue (weird) : oops");

      // exception non-Firebase -> catch général
      when(
        () => mock.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(Exception('kaboom'));
      await service.signIn('a@a.a', 'x');
      expect(
        AuthService.lastErrorMessage,
        "Erreur inattendue : Exception: kaboom",
      );

      // sendPasswordResetEmail : on simule une erreur et on s'attend à une exception
      when(
        () => mock.sendPasswordResetEmail(email: any(named: 'email')),
      ).thenThrow(FirebaseAuthException(code: 'invalid-email', message: 'bad'));

      expect(
        () => service.sendPasswordResetEmail('bad'),
        throwsA(
          isA<FirebaseAuthException>().having(
            (e) => e.code,
            'code',
            'invalid-email',
          ),
        ),
      );
    },
  );
}
