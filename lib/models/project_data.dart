import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectData {
  final String boardName;
  final String boardPrice;

  String? description;
  List<String>? imagePaths; // chemins vers images locales ou URLs Firebase
  Offset? imagePosition;
  double? imageScale;
  DateTime? deliveryDate;

  ProjectData({
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
  factory ProjectData.fromMap(Map<String, dynamic> map) {
    return ProjectData(
      boardName: map['boardName'] ?? '',
      boardPrice: map['boardPrice'] ?? '',
      description: map['description'],
      imagePaths: List<String>.from(map['imagePaths'] ?? []),
      imagePosition:
          map['imagePosition'] != null
              ? Offset(map['imagePosition']['dx'], map['imagePosition']['dy'])
              : null,
      imageScale: map['imageScale'],
      deliveryDate:
          map['deliveryDate'] != null
              ? DateTime.parse(map['deliveryDate'])
              : null,
    );
  }
}
