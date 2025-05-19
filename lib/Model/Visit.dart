class Visit {
  final int id;
  final int customerId;
  final DateTime visitDate;
  final String location;
  final String status;
  final String? notes;
  final List<String> activitiesDone;
  final DateTime createdAt;

  Visit({
    required this.id,
    required this.customerId,
    required this.visitDate,
    required this.location,
    required this.status,
    this.notes,
    required this.activitiesDone,
    required this.createdAt,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'],
      customerId: json['customer_id'],
      visitDate: DateTime.parse(json['visit_date']),
      location: json['location'],
      status: json['status'],
      notes: json['notes'],
      activitiesDone: List<String>.from(json['activities_done']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'visit_date': visitDate.toIso8601String(),
      'location': location,
      'status': status,
      'notes': notes,
      'activities_done': activitiesDone,
      'created_at': createdAt.toIso8601String(),
    };
  }
}