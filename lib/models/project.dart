class Project {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final DateTime createdAt;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.createdAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    imagePath: json['imagePath'],
    createdAt: DateTime.parse(json['createdAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'imagePath': imagePath,
    'createdAt': createdAt.toIso8601String(),
  };
}
