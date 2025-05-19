class VisitStats {
  final int totalVisits;
  final int completedVisits;
  final int pendingVisits;
  final int cancelledVisits;
  final Map<String, int> visitsByCustomer;

  VisitStats({
    required this.totalVisits,
    required this.completedVisits,
    required this.pendingVisits,
    required this.cancelledVisits,
    required this.visitsByCustomer,
  });

  factory VisitStats.fromJson(Map<String, dynamic> json) {
    final Map<String, int> customerMap = {};

    final customerData = json['visits_by_customer'];
    if (customerData != null && customerData is Map) {
      customerData.forEach((key, value) {
        customerMap[key.toString()] = value is int ? value : int.tryParse(value.toString()) ?? 0;
      });
    }

    return VisitStats(
      totalVisits: json['total_visits'] ?? 0,
      completedVisits: json['completed_visits'] ?? 0,
      pendingVisits: json['pending_visits'] ?? 0,
      cancelledVisits: json['cancelled_visits'] ?? 0,
      visitsByCustomer: customerMap,
    );
  }
}
