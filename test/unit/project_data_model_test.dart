import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:chewlin_board/models/project_data.dart';

void main() {
  test('toMap inclut ownerId et les champs principaux', () {
    final p = ProjectData(
      projectId: 'p1',
      boardName: 'Deck',
      boardPrice: '199.90',
      description: 'desc',
      imagePaths: const ['a', 'b'],
      imagePosition: const Offset(1, 2),
      imageScale: 1.5,
    );

    final m = p.toMap('u1');
    expect(m['userId'], 'u1');
    expect(m['boardName'], 'Deck');
    expect(m['boardPrice'], '199.90');
    expect(m['description'], 'desc');
    expect(m['imagePaths'], ['a', 'b']);
    expect(m['imagePosition'], {'dx': 1.0, 'dy': 2.0});
    expect(m['imageScale'], 1.5);
    // on ne teste pas d'autres clés éventuelles (createdAt, lastStep, etc.)
  });

  test('fromMap reconstruit ProjectData avec champs optionnels', () {
    final map = {
      'boardName': 'X',
      'boardPrice': '123',
      'description': null,
      'imagePaths': <String>[],
      'imagePosition': {'dx': 0.0, 'dy': 0.0},
      'imageScale': 1.0,
      // 'deliveryDate': '2030-01-01', // si présent, le modèle le parse
    };

    // ✅ ton modèle attend uniquement la map (pas l’ID en 1er argument)
    final p = ProjectData.fromMap(map);

    // l’ID n’est pas passé via fromMap(map) → reste null (on ne l’assert pas)
    expect(p.boardName, 'X');
    expect(p.boardPrice, '123');
    expect(p.description, isNull);
    expect(p.imagePaths, isEmpty);
    expect(p.imagePosition, const Offset(0, 0));
    expect(p.imageScale, 1.0);
  });
}
