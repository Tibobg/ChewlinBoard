import 'dart:io';
import 'package:path/path.dart' as p;

void main() async {
  const packageName = 'chewlin_board'; // <-- mets le name: exact de ton pubspec

  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    stderr.writeln('❌ ./lib introuvable');
    exit(1);
  }

  final ignoreRe = RegExp(
    r'(\.g\.dart$|\.freezed\.dart$|firebase_options\.dart$)',
  );
  final files = <String>[];

  await for (final ent in libDir.list(recursive: true, followLinks: false)) {
    if (ent is! File || !ent.path.endsWith('.dart')) continue;
    final rel = p
        .relative(p.normalize(ent.path), from: 'lib')
        .replaceAll(r'\', '/');
    if (!ignoreRe.hasMatch(rel)) files.add(rel);
  }

  files.sort();

  final buf =
      StringBuffer()
        ..writeln('// GENERATED — do not edit.')
        ..writeln('// ignore_for_file: unused_import');

  for (final rel in files) {
    buf.writeln("import 'package:$packageName/$rel';");
  }

  // Un main vide suffit pour que le runner soit content
  buf.writeln('void main() {}');

  final outPath = p.join('test', 'coverage_helper_test.dart');
  File(outPath).createSync(recursive: true);
  File(outPath).writeAsStringSync(buf.toString());

  print('✅ $outPath généré avec ${files.length} imports.');
}
