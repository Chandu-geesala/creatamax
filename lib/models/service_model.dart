class ServiceModel {
  final String id;
  final String serviceName;
  final String description;
  final String category;
  final String subCategory;
  final double price;
  final int duration;
  final String? imageUrl;
  final String startTime;
  final String endTime;

  ServiceModel({
    required this.id,
    required this.serviceName,
    required this.description,
    required this.category,
    required this.subCategory,
    required this.price,
    required this.duration,
    this.imageUrl,
    required this.startTime,
    required this.endTime,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id'] ?? json['id'] ?? '',
      serviceName: json['serviceName'] ?? '',
      description: json['description'] ?? '',
      category: (json['category'] is Map)
          ? json['category']['name'] ?? ''
          : json['category'] ?? '',
      subCategory: (json['subCategory'] is Map)
          ? json['subCategory']['name'] ?? ''
          : json['subCategory'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0,
      duration: int.tryParse(json['duration'].toString()) ?? 0,
      imageUrl: json['image'],
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
    );
  }
}
