class CategoryModel {
  final String id;
  final String name;
  final String description;

  CategoryModel({
    required this.id,
    required this.name,
    this.description = '',
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class SubCategoryModel {
  final String id;
  final String name;
  final String? icon;

  SubCategoryModel({
    required this.id,
    required this.name,
    this.icon,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'],
    );
  }
}
