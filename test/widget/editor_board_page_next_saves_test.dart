import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import '../helpers/pump_app.dart';
import '../helpers/mock_network_images.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/models/project_data.dart';
import 'package:chewlin_board/pages/project/editor_board_page.dart';

void main() {
  setUp(() async {
    firebaseAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'u1'),
    );
    firestore = FakeFirebaseFirestore();
  });

  testWidgets('EditorBoardPage: “suivant/continuer” écrit lastStep: editor', (
    tester,
  ) async {
    final project = ProjectData(
      projectId: 'p1',
      boardName: 'Deck Editor',
      boardPrice: '199.90',
      description: 'desc',
      imagePaths: const ['http://img'], // Image.network => mock
      imagePosition: Offset.zero,
      imageScale: 1.0,
    );

    await mockNetworkImagesFor(() async {
      final app = await pumpApp(EditorBoardPage(project: project));
      await tester.pumpWidget(app);
      await tester.pump(const Duration(milliseconds: 120));

      // trouve un bouton “suivant/continuer/next” ou, à défaut, le 1er ElevatedButton
      Finder? nextBtn;
      final candidates = <Finder>[
        find.widgetWithText(ElevatedButton, 'Suivant'),
        find.widgetWithText(ElevatedButton, 'Continuer'),
        find.widgetWithText(ElevatedButton, 'Next'),
      ];
      for (final c in candidates) {
        if (c.evaluate().isNotEmpty) {
          nextBtn = c;
          break;
        }
      }
      nextBtn ??= find.byType(ElevatedButton).first;

      await tester.ensureVisible(nextBtn);
      await tester.tap(nextBtn);
      await tester.pump(const Duration(milliseconds: 120));
    });

    final doc = await firestore.collection('projects').doc('p1').get();
    expect(doc.exists, true);
    expect(doc.data()?['lastStep'], 'editor');
  });
}
