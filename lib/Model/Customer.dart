class Customer {
  final int id;
  final String name;
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  // Convert to JSON with proper null checks
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'name': name,
    };

    // Only add createdAt if it's not null
    if (createdAt != null) {
      map['created_at'] = createdAt!.toIso8601String();
    }

    return map;
  }

  // Create from JSON with enhanced parsing
  factory Customer.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;

    try {
      // Try both snake_case and camelCase variants
      final dateString = json['created_at'] ?? json['createdAt'];
      if (dateString != null) {
        parsedDate = DateTime.parse(dateString);
      }
    } catch (e) {
      print('Error parsing date: $e');
    }

    return Customer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      createdAt: parsedDate ?? DateTime.now().toUtc(),
    );
  }
}