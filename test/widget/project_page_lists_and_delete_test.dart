import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/pages/project/project_page.dart';
import '../helpers/pump_app.dart';

void main() {
  setUp(() async {
    firebaseAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'u1'),
    );
    firestore = FakeFirebaseFirestore();

    // 1 brouillon + 1 finalisé
    await firestore.collection('projects').add({
      'userId': 'u1',
      'boardName': 'Draft Deck',
      'boardPrice': '123€',
      'isDraft': true,
      'lastStep': 'customize',
      'imagePaths': <String>[],
      'createdAt': Timestamp.now(),
    });

    await firestore.collection('projects').add({
      'userId': 'u1',
      'boardName': 'Final Deck',
      'boardPrice': '199€',
      'isDraft': false,
      'imagePaths': <String>[],
      'createdAt': Timestamp.now(),
    });
  });

  testWidgets('ProjectPage: supprime un brouillon (sans dépendre d’un libellé)', (
    tester,
  ) async {
    final app = await pumpApp(const ProjectPage());
    await tester.pumpWidget(app);

    // Laisse les streams se résoudre
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.byType(ProjectPage), findsOneWidget);

    // Attends au moins une icône "delete"
    Finder? deleteFinder;
    for (var i = 0; i < 10; i++) {
      final cand = find.byIcon(Icons.delete);
      if (cand.evaluate().isNotEmpty) {
        deleteFinder = cand;
        break;
      }
      await tester.pump(const Duration(milliseconds: 80));
    }
    expect(
      deleteFinder,
      isNotNull,
      reason: 'Aucune icône de suppression trouvée',
    );

    // ✅ Choisit explicitement le premier match
    final deleteIcon = deleteFinder!.first;

    await tester.ensureVisible(deleteIcon);
    await tester.tap(deleteIcon);
    await tester.pump(const Duration(milliseconds: 80));

    // Bouton de confirmation : on prend le premier match parmi plusieurs variantes
    Finder? confirm;
    final candidates = <Finder>[
      find.widgetWithText(TextButton, 'Supprimer'),
      find.widgetWithText(TextButton, 'Confirmer'),
      find.textContaining('Supprimer'),
      find.textContaining('Confirmer'),
      find.byType(TextButton),
    ];
    for (final f in candidates) {
      if (f.evaluate().isNotEmpty) {
        confirm = f.first;
        break;
      }
    }
    expect(confirm, isNotNull, reason: 'Aucun bouton de confirmation trouvé');

    await tester.tap(confirm!);
    await tester.pumpAndSettle(const Duration(milliseconds: 150));

    // 1 doc en moins
    final left = await firestore.collection('projects').get();
    expect(left.docs.length, 1);
  });
}
