import 'dart:ui'; // Offset
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import '../helpers/mock_network_images.dart'; // re-export de mockNetworkImagesFor
import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/models/project_data.dart';
import 'package:chewlin_board/pages/project/recap_board_page.dart';
import '../helpers/pump_app.dart';

void main() {
  setUp(() async {
    firebaseAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'u1'),
    );
    firestore = FakeFirebaseFirestore();
  });

  testWidgets('RecapPage: rendu + Brouillon écrit un projet', (tester) async {
    final project = ProjectData(
      boardName: 'Deck C',
      boardPrice: '299.00',
      description: 'Texte de test',
      imagePaths: const ['http://img'], // Image.network -> on mock le HTTP
      imagePosition: const Offset(10, 10),
      imageScale: 1.0,
    );

    await mockNetworkImagesFor(() async {
      final app = await pumpApp(RecapPage(project: project));
      await tester.pumpWidget(app);
      await tester.pump(const Duration(milliseconds: 50));

      // Tap "Brouillon"
      await tester.tap(find.widgetWithText(ElevatedButton, 'Brouillon'));
      await tester.pump(const Duration(milliseconds: 50));
    });

    final snap = await firestore.collection('projects').get();
    expect(snap.docs.isNotEmpty, true);
    final data = snap.docs.first.data();
    expect(data['isDraft'], true);
    expect(data['lastStep'], 'recap');
  });
}
