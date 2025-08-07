class Category {
  final int? id;
  final String name;
  final DateTime? createdAt;

  const Category({
    this.id,
    required this.name,
    this.createdAt,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      createdAt: map['created_at'] != null 
        ? DateTime.parse(map['created_at'] as String)
        : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Category copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, createdAt: $createdAt)';
  }
} 