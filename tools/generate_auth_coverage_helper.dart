import 'dart:io';
import 'package:path/path.dart' as p;

void main() async {
  const pkg = 'chewlin_board'; // <- name du pubspec

  final include = [
    Directory('lib/services'), // AuthService
    Directory('lib/pages/auth'), // login / signup / forgot / auth_gate
    File('lib/core/firebase_refs.dart'),
  ];

  final ignore = RegExp(
    r'(\.g\.dart$|\.freezed\.dart$|firebase_options\.dart$)',
  );

  final files = <String>[];
  for (final e in include) {
    if (e is File) {
      final rel = p.relative(e.path, from: 'lib').replaceAll(r'\', '/');
      if (!ignore.hasMatch(rel)) files.add(rel);
    } else if (e is Directory && e.existsSync()) {
      await for (final f in e.list(recursive: true)) {
        if (f is! File || !f.path.endsWith('.dart')) continue;
        final rel = p.relative(f.path, from: 'lib').replaceAll(r'\', '/');
        if (!ignore.hasMatch(rel)) files.add(rel);
      }
    }
  }

  files.sort();

  final buf =
      StringBuffer()
        ..writeln('// GENERATED — do not edit.')
        ..writeln('// ignore_for_file: unused_import');
  for (final rel in files) {
    buf.writeln("import 'package:$pkg/$rel';");
  }
  buf.writeln('void main() {}');

  final out = p.join('test', 'coverage_helper_test.dart');
  File(out).createSync(recursive: true);
  File(out).writeAsStringSync(buf.toString());
  print('✅ $out (auth-only) avec ${files.length} imports.');
}
