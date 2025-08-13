import 'dart:ui'; // Offset
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/models/project_data.dart';
import 'package:chewlin_board/pages/project/customize_board_page.dart';
import '../helpers/pump_app.dart';

void main() {
  setUp(() async {
    firebaseAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'u1'),
    );
    firestore = FakeFirebaseFirestore();
  });

  testWidgets('CustomizeBoardPage: Brouillon écrit un projet (sans upload)', (
    tester,
  ) async {
    final project = ProjectData(
      boardName: 'Deck A',
      boardPrice: '199.90',
      description: null,
      imagePaths: const [], // pas d’image -> pas d’upload Storage
      imagePosition: Offset.zero,
      imageScale: 1.0,
    );

    final app = await pumpApp(CustomizeBoardPage(project: project));
    await tester.pumpWidget(app);
    await tester.pump();

    // Tap sur "Brouillon"
    await tester.tap(find.widgetWithText(ElevatedButton, 'Brouillon'));
    await tester.pump(const Duration(milliseconds: 50));

    // Un doc 'projects' a été créé/mergé
    final snap = await firestore.collection('projects').get();
    expect(snap.docs.isNotEmpty, true);
    final data = snap.docs.first.data();
    expect(data['isDraft'], true);
    expect(data['lastStep'], 'customize');
  });

  testWidgets(
    'CustomizeBoardPage: Continuer sans image/description -> SnackBar erreur',
    (tester) async {
      final project = ProjectData(
        boardName: 'Deck B',
        boardPrice: '249.90',
        description: '', // vide
        imagePaths: const [], // pas d’image
        imagePosition: Offset.zero,
        imageScale: 1.0,
      );

      final app = await pumpApp(CustomizeBoardPage(project: project));
      await tester.pumpWidget(app);
      await tester.pump();

      // Tap sur "Continuer" -> snackbar "Merci d'ajouter une image..."
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continuer'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
    },
  );
}
