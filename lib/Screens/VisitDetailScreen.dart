import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:rtm/Model/Visit.dart';
import 'package:rtm/Screens/EditVisitScreen.dart';

class VisitDetailScreen extends StatelessWidget {
  final Visit visit;
  final String customerName;
  final Map<String, String> activityDescriptions;

  const VisitDetailScreen({
    Key? key,
    required this.visit,
    required this.customerName,
    required this.activityDescriptions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format dates
    final visitDate = DateFormat('MMMM d, yyyy').format(visit.visitDate);
    final visitTime = DateFormat('h:mm a').format(visit.visitDate);

    // Get activities
    List<String> activities = [];
    for (var activityId in visit.activitiesDone) {
      final description = activityDescriptions[activityId];
      if (description != null) {
        activities.add(description);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Visit Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditVisitScreen(visit: visit),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          customerName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Chip(
                          label: Text(visit.status),
                          backgroundColor: visit.status.toLowerCase() == 'completed'
                              ? Colors.green[100]
                              : visit.status.toLowerCase() == 'cancelled'
                              ? Colors.red
                              : Colors.orange[100],
                          labelStyle: TextStyle(
                            color: visit.status.toLowerCase() == 'cancelled'
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.calendar_today, 'Date', visitDate),
                    _buildInfoRow(Icons.access_time, 'Time', visitTime),
                    _buildInfoRow(Icons.location_on, 'Location', visit.location),
                    if (visit.notes != null && visit.notes!.isNotEmpty)
                      _buildInfoRow(Icons.notes, 'Notes', visit.notes!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (activities.isNotEmpty) ...[
              const Text(
                'Activities Performed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activities.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.check_circle, color: Colors.green),
                      title: Text(activities[index]),
                    );
                  },
                ),
              ),
            ] else ...[
              const Text(
                'No Activities Recorded',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}