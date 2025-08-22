import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/services/auth_service.dart';
import 'package:chewlin_board/pages/user/profile_page.dart';
import '../helpers/pump_app.dart';

class SpyAuthService extends AuthService {
  SpyAuthService({required super.auth, required super.firestore});
  bool called = false;
  @override
  Future<void> signOut() async {
    called = true; // on ne fait rien d'autre
  }
}

void main() {
  setUp(() async {
    firebaseAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'u1', email: 'x@y.z'),
    );
    firestore = FakeFirebaseFirestore();

    // remplace l'authService global par notre espion
    authService = SpyAuthService(auth: firebaseAuth, firestore: firestore);

    await firestore.collection('users').doc('u1').set({
      'pseudo': 'User One',
      'email': 'x@y.z',
    });
  });

  testWidgets('ProfilePage: tap sur logout appelle authService.signOut()', (
    tester,
  ) async {
    final app = await pumpApp(const ProfilePage());
    await tester.pumpWidget(app);
    await tester.pump(const Duration(milliseconds: 120));

    // Cherche plusieurs variantes d’UI pour le logout
    final candidates = <Finder>[
      find.byIcon(Icons.logout),
      find.byIcon(Icons.exit_to_app),
      find.byIcon(Icons.power_settings_new),
      find.textContaining('Déconnexion'),
      find.textContaining('Se déconnecter'),
      find.textContaining('Logout'),
    ];

    Finder? target;
    for (final f in candidates) {
      if (f.evaluate().isNotEmpty) {
        target = f;
        break;
      }
    }

    // S’assure qu’on a bien trouvé un truc à cliquer
    expect(
      target,
      isNotNull,
      reason: 'Aucun bouton/texte de déconnexion trouvé',
    );

    await tester.ensureVisible(target!);
    await tester.tap(target);
    await tester.pump(const Duration(milliseconds: 120));

    expect((authService as SpyAuthService).called, isTrue);
  });
}
