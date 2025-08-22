import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/pages/user/message_page.dart';
import '../helpers/pump_app.dart';

void main() {
  setUp(() async {
    firebaseAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'u1', email: 'x@y.z'),
    );
    firestore = FakeFirebaseFirestore();
  });

  testWidgets('MessagePage: simple render', (tester) async {
    final app = await pumpApp(const MessagePage());
    await tester.pumpWidget(app);
    await tester.pump(
      const Duration(milliseconds: 80),
    ); // laisse initState/streams tourner

    expect(find.byType(MessagePage), findsOneWidget);
  });
}
