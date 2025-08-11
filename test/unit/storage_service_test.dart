// test/unit/storage_service_test.dart
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';

class StorageService {
  StorageService(this.storage);
  final MockFirebaseStorage storage;

  Future<String> uploadBytes(String path, Uint8List bytes) async {
    final ref = storage.ref(path);
    await ref.putData(bytes);
    return await ref.getDownloadURL();
  }

  Future<String> getUrl(String path) async =>
      storage.ref(path).getDownloadURL();
}

void main() {
  test('uploadBytes renvoie une URL et getUrl fonctionne', () async {
    final s = StorageService(MockFirebaseStorage());
    final url1 = await s.uploadBytes(
      'skateboards/1.png',
      Uint8List.fromList(List.filled(10, 1)),
    );
    expect(url1, isNotEmpty);

    final url2 = await s.getUrl('skateboards/1.png');
    expect(url2, isNotEmpty);
  });
}
