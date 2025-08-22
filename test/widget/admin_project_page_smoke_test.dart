import 'package:flutter_test/flutter_test.dart';
import 'package:chewlin_board/pagesAdmin/admin_project_page.dart';
import '../helpers/pump_app.dart';

void main() {
  testWidgets('AdminProjectPage: simple render', (tester) async {
    final app = await pumpApp(const AdminProjectPage());
    await tester.pumpWidget(app);
    await tester.pump();

    expect(find.byType(AdminProjectPage), findsOneWidget);
  });
}
