import 'dart:io';

void main() {
  final file = File('coverage/lcov.info');
  if (!file.existsSync()) {
    print(
      '❌ Fichier coverage/lcov.info introuvable. Lance d’abord flutter test --coverage',
    );
    exit(1);
  }

  final lines = file.readAsLinesSync();
  int found = 0, hit = 0;
  for (final line in lines) {
    if (line.startsWith('DA:')) {
      found++;
      final parts = line.split(',');
      if (parts.length > 1 && parts[1] != '0') hit++;
    }
  }

  final percent = found == 0 ? 0 : (hit / found * 100);
  print('📊 Coverage: ${percent.toStringAsFixed(2)}%  ($hit / $found lignes)');
}
