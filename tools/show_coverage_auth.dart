import 'dart:io';

void main() {
  final f = File('coverage/lcov.info');
  if (!f.existsSync()) {
    print('❌ Lance d’abord: flutter test --coverage');
    exit(1);
  }

  final includeAuth = RegExp(r'lib/(pages/auth/|services/auth_service\.dart)');

  final lines = f.readAsLinesSync();
  final byFile = <String, List<String>>{};
  String? cur;

  for (final l in lines) {
    if (l.startsWith('SF:')) {
      // normalise Windows -> POSIX
      cur = l.substring(3).replaceAll('\\', '/');
      continue;
    }
    if (cur != null && includeAuth.hasMatch(cur!) && l.startsWith('DA:')) {
      byFile.putIfAbsent(cur!, () => []).add(l.substring(3)); // "line,hit"
    }
  }

  if (byFile.isEmpty) {
    print(
      'ℹ️ Aucun fichier auth trouvé. Vérifie que tes tests ont bien importé lib/pages/auth/* ou services/auth_service.dart',
    );
    return;
  }

  int totalFound = 0, totalHit = 0;
  final rows = <String>[];
  final missing = <String, List<int>>{};

  byFile.forEach((file, das) {
    int found = 0, hit = 0;
    final miss = <int>[];
    for (final da in das) {
      final p = da.split(',');
      found++;
      final h = int.parse(p[1]);
      if (h > 0)
        hit++;
      else
        miss.add(int.parse(p[0]));
    }
    totalFound += found;
    totalHit += hit;
    final pct = found == 0 ? 100.0 : (100.0 * hit / found);
    final short = file.replaceFirst(RegExp(r'^.*?/lib/'), 'lib/');
    rows.add('${pct.toStringAsFixed(1).padLeft(5)}%  $hit/$found  $short');
    if (miss.isNotEmpty) missing[short] = miss;
  });

  rows.sort();
  for (final r in rows) {
    print(r);
  }
  print('\nLIGNES MANQUANTES:');
  missing.forEach((file, lines) {
    final preview = lines.take(20).join(', ');
    print(' - $file  →  $preview${lines.length > 20 ? ' …' : ''}');
  });

  final totalPct = totalFound == 0 ? 100.0 : (100.0 * totalHit / totalFound);
  print(
    '\nAUTH TOTAL: ${totalPct.toStringAsFixed(2)}%  ($totalHit / $totalFound lignes)',
  );
}
