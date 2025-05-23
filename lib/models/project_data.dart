import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectData {
  String? projectId;
  final String boardName;
  final String boardPrice;

  String? description;
  List<String>? imagePaths; // chemins vers images locales ou URLs Firebase
  Offset? imagePosition;
  double? imageScale;
  DateTime? deliveryDate;

  ProjectData({
    this.projectId,
    required this.boardName,
    required this.boardPrice,
    this.description,
    this.imagePaths,
    this.imagePosition,
    this.imageScale,
    this.deliveryDate,
  });

  // Pour sauvegarder dans Firestore
  Map<String, dynamic> toMap(String userId) {
    return {
      'userId': userId,
      'boardName': boardName,
      'boardPrice': boardPrice,
      'description': description,
      'imagePaths': imagePaths,
      'imagePosition':
          imagePosition != null
              ? {'dx': imagePosition!.dx, 'dy': imagePosition!.dy}
              : null,
      'imageScale': imageScale,
      'deliveryDate': deliveryDate?.toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(), // 🔥 TIMESTAMP SERVEUR
    };
  }

  // Pour récupérer les données depuis Firestore (optionnel)
  factory ProjectData.fromMap(Map<String, dynamic> map, {String? id}) {
    Offset? position;
    try {
      if (map['imagePosition'] != null &&
          map['imagePosition']['dx'] != null &&
          map['imagePosition']['dy'] != null) {
        position = Offset(
          (map['imagePosition']['dx'] as num).toDouble(),
          (map['imagePosition']['dy'] as num).toDouble(),
        );
      }
    } catch (_) {}

    return ProjectData(
      projectId: id,
      boardName: map['boardName'] ?? '',
      boardPrice: map['boardPrice'] ?? '',
      description: map['description'],
      imagePaths: List<String>.from(map['imagePaths'] ?? []),
      imagePosition: position,
      imageScale:
          map['imageScale'] != null
              ? (map['imageScale'] as num).toDouble()
              : null,
      deliveryDate:
          map['deliveryDate'] != null
              ? DateTime.tryParse(map['deliveryDate'])
              : null,
    );
  }
}
