class Shortcut {
  final int? id;
  final String name;
  final String url;
  final bool isDefault;
  final int categoryId;
  final String categoryName;

  const Shortcut({
    this.id,
    required this.name,
    required this.url,
    this.isDefault = false,
    required this.categoryId,
    required this.categoryName,
  });

  factory Shortcut.fromMap(Map<String, dynamic> map) {
    return Shortcut(
      id: map['id'] as int?,
      name: map['name'] as String,
      url: map['url'] as String,
      isDefault: (map['is_default'] as int) == 1,
      categoryId: map['category_id'] as int,
      categoryName: map['category_name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'is_default': isDefault ? 1 : 0,
      'category_id': categoryId,
      'category_name': categoryName,
    };
  }

  Shortcut copyWith({
    int? id,
    String? name,
    String? url,
    bool? isDefault,
    int? categoryId,
    String? categoryName,
  }) {
    return Shortcut(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      isDefault: isDefault ?? this.isDefault,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
    );
  }

  @override
  String toString() {
    return 'Shortcut(id: $id, name: $name, url: $url, isDefault: $isDefault, categoryId: $categoryId, categoryName: $categoryName)';
  }
}