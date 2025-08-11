import 'dart:io';

void main() {
  final cov = File('coverage/lcov.info');
  if (!cov.existsSync()) {
    print('❌ Lance d’abord: flutter test --coverage');
    exit(1);
  }

  final lines = cov.readAsLinesSync();
  final byFile = <String, List<String>>{};
  String? currentFile;

  for (final l in lines) {
    if (l.startsWith('SF:')) {
      currentFile = l.substring(3);
      byFile.putIfAbsent(currentFile, () => <String>[]);
      continue;
    }
    if (l.startsWith('DA:') && currentFile != null) {
      byFile[currentFile]!.add(l.substring(3)); // "line,hit"
    }
  }

  final entries = <_Entry>[];
  byFile.forEach((file, das) {
    int found = 0, hit = 0;
    final misses = <int>[];
    for (final da in das) {
      final parts = da.split(',');
      final ln = int.parse(parts[0]);
      final h = int.parse(parts[1]);
      found++;
      if (h > 0) {
        hit++;
      } else {
        misses.add(ln);
      }
    }
    entries.add(_Entry(file: file, hit: hit, found: found, misses: misses));
  });

  // Trie du pire au meilleur
  entries.sort((a, b) => a.rate.compareTo(b.rate));

  // Filtre: seulement les fichiers sous lib/
  // (normalise les chemins Windows en '/')
  final libEntries =
      entries.map((e) => e.copyWith(file: e.file.replaceAll('\\', '/'))).where((
        e,
      ) {
        final p = e.file;
        return p.startsWith('lib/') || p.contains('/lib/');
      }).toList();

  for (final e in libEntries) {
    if (e.hit == e.found) continue; // déjà 100% sur ce fichier
    final pct = (e.rate * 100).toStringAsFixed(1).padLeft(5);
    final short = e.file.replaceFirst(RegExp(r'^.*?/lib/'), 'lib/');
    print('$pct%  ${e.hit}/${e.found}  $short');

    final show = e.misses.take(12).toList();
    print(
      '      manquantes: ${show.join(', ')}${e.misses.length > show.length ? ' …' : ''}',
    );
  }

  final totalHit = libEntries.fold<int>(0, (a, b) => a + b.hit);
  final totalFound = libEntries.fold<int>(0, (a, b) => a + b.found);
  final totalPct = totalFound == 0 ? 0.0 : (100.0 * totalHit / totalFound);
  print(
    '\nTOTAL (lib/): ${totalPct.toStringAsFixed(2)}%  ($totalHit / $totalFound lignes)',
  );
}

class _Entry {
  final String file;
  final int hit;
  final int found;
  final List<int> misses;

  _Entry({
    required this.file,
    required this.hit,
    required this.found,
    required this.misses,
  });

  double get rate => found == 0 ? 1.0 : hit / found;

  _Entry copyWith({String? file, int? hit, int? found, List<int>? misses}) {
    return _Entry(
      file: file ?? this.file,
      hit: hit ?? this.hit,
      found: found ?? this.found,
      misses: misses ?? this.misses,
    );
  }
}
