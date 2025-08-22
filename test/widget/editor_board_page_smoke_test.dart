// test/widget/editor_board_page_smoke_test.dart
import 'dart:ui'; // Offset
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import '../helpers/pump_app.dart';
import '../helpers/mock_network_images.dart'; // <— pour mocker Image.network

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

  testWidgets('EditorBoardPage: simple render (smoke)', (tester) async {
    final project = ProjectData(
      projectId: 'p1',
      boardName: 'Deck Editor',
      boardPrice: '199.90',
      description: 'desc',
      imagePaths: const ['http://img'], // ✅ au moins une image
      imagePosition: Offset.zero,
      imageScale: 1.0,
    );

    await mockNetworkImagesFor(() async {
      // ✅ mock réseau pour Image.network
      final app = await pumpApp(EditorBoardPage(project: project));
      await tester.pumpWidget(app);
      await tester.pump(const Duration(milliseconds: 80));
    });

    expect(find.byType(EditorBoardPage), findsOneWidget);
  });
}
