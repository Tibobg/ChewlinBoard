import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

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
    // seed minimal si la page écoute des projets
    await firestore.collection('projects').add({
      'ownerId': 'u1',
      'status': 'draft',
      'imagePaths': [],
      'createdAt': DateTime.now(),
    });
  });

  testWidgets('ProjectPage: simple render (smoke)', (tester) async {
    final app = await pumpApp(const ProjectPage());
    await tester.pumpWidget(app);
    await tester.pump(const Duration(milliseconds: 80));

    expect(find.byType(ProjectPage), findsOneWidget);
  });
}
