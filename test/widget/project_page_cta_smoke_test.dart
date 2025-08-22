import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import '../helpers/pump_app.dart';
import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/pages/project/project_page.dart';

void main() {
  setUp(() async {
    firebaseAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'u1'),
    );
    firestore = FakeFirebaseFirestore();
  });

  testWidgets('ProjectPage: simple render (no navigation)', (tester) async {
    final app = await pumpApp(const ProjectPage());
    await tester.pumpWidget(app);
    await tester.pump(const Duration(milliseconds: 120));

    // Juste un smoke test : la page se construit sans crasher.
    expect(find.byType(ProjectPage), findsOneWidget);
  });
}
