import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core_platform_interface/test.dart' as fcore_test;

/// À appeler dans setUpAll(...) de tes tests quand tu touches Firebase.
/// (Avec les *fakes*, tu n'as pas forcément besoin du initializeApp, mais ça ne gêne pas.)
Future<void> setupFirebaseForTests() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  fcore_test.setupFirebaseCoreMocks();
  // Décommente seulement si du code testé appelle explicitement Firebase.initializeApp()
  // await Firebase.initializeApp();
}
