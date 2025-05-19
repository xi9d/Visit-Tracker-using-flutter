class RepPerformance {
  final String id;
  final String name;
  final String email;
  final int totalVisits;
  final int completedVisits;
  final int pendingVisits;
  final int cancelledVisits;
  final double completionRate;

  RepPerformance({
    required this.id,
    required this.name,
    required this.email,
    required this.totalVisits,
    required this.completedVisits,
    required this.pendingVisits,
    required this.cancelledVisits,
    required this.completionRate,
  });

  factory RepPerformance.fromJson(Map<String, dynamic> json) {
    return RepPerformance(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      totalVisits: json['total_visits'] as int,
      completedVisits: json['completed_visits'] as int,
      pendingVisits: json['pending_visits'] as int,
      cancelledVisits: json['cancelled_visits'] as int,
      completionRate: json['completion_rate'] as double,
    );
  }
}