import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/colors.dart';
import 'pages/auth_gate.dart';
import 'pages/customize_board_page.dart';
import 'pages/recap_board_page.dart';
import 'pages/editor_board_page.dart';
import 'models/project_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('fr_FR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chewlin Board',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.green),
        useMaterial3: true,
      ),
      routes: {
        '/customize': (context) {
          final doc =
              ModalRoute.of(context)!.settings.arguments
                  as QueryDocumentSnapshot;
          final data = doc.data() as Map<String, dynamic>;
          return CustomizeBoardPage(
            project: ProjectData.fromMap(data, id: doc.id),
          );
        },
        '/editor': (context) {
          final doc =
              ModalRoute.of(context)!.settings.arguments
                  as QueryDocumentSnapshot;
          final data = doc.data() as Map<String, dynamic>;
          return EditorBoardPage(
            project: ProjectData.fromMap(data, id: doc.id),
          );
        },
        '/recap': (context) {
          final doc =
              ModalRoute.of(context)!.settings.arguments
                  as QueryDocumentSnapshot;
          final data = doc.data() as Map<String, dynamic>;
          return RecapPage(project: ProjectData.fromMap(data, id: doc.id));
        },
      },
      home: const AuthGate(),
    );
  }
}
