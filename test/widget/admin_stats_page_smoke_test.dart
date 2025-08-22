import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/pagesAdmin/admin_stats_page.dart';
import '../helpers/pump_app.dart';

void main() {
  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  testWidgets('AdminStatsPage: render + calcule des stats', (tester) async {
    // seed orders (prix en String/num -> code gère les deux)
    await firestore.collection('orders').add({
      'status': 'payée',
      'price': '100',
      'timestamp': DateTime.now(),
    });
    await firestore.collection('orders').add({
      'status': 'préparée',
      'price': 150.5,
      'timestamp': DateTime.now(),
    });
    await firestore.collection('orders').add({
      'status': 'livrée',
      'price': '200',
      'timestamp': DateTime.now(),
    });

    // seed inventory
    await firestore.collection('skateboards').add({'isSold': true});
    await firestore.collection('skateboards').add({'isSold': false});

    final app = await pumpApp(const AdminStatsPage());
    await tester.pumpWidget(app);
    await tester.pump(
      const Duration(milliseconds: 100),
    ); // laisse fetchStats finir

    expect(find.byType(AdminStatsPage), findsOneWidget);
    expect(find.textContaining('Commandes'), findsOneWidget); // sanity check
  });
}
