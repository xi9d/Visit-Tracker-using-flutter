import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rtm/Model/Visit.dart';
import 'package:rtm/Screens/EditVisitScreen.dart';
import 'package:rtm/Model/User.dart'; // import your User model
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class VisitDetailScreen extends StatefulWidget {
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
  State<VisitDetailScreen> createState() => _VisitDetailScreenState();
}

class _VisitDetailScreenState extends State<VisitDetailScreen> {
  String? userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = await getCurrentUser();
    if (user != null) {
      setState(() {
        userRole = user.role.toLowerCase();
      });
    }
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString("user_data");

    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }

    return null;
  }
  @override
  Widget build(BuildContext context) {
    final visitDate = DateFormat('MMMM d, yyyy').format(widget.visit.visitDate);
    final visitTime = DateFormat('h:mm a').format(widget.visit.visitDate);

    List<String> activities = [];
    for (var activityId in widget.visit.activitiesDone) {
      final description = widget.activityDescriptions[activityId];
      if (description != null) {
        activities.add(description);
      }
    }

    if (userRole == null) {
      // Still loading user role
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visit Details'),
        actions: [
          if (userRole != 'manager') // Only allow non-managers to edit
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditVisitScreen(visit: widget.visit),
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
                          widget.customerName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Chip(
                          label: Text(widget.visit.status),
                          backgroundColor: widget.visit.status.toLowerCase() == 'completed'
                              ? Colors.green[100]
                              : widget.visit.status.toLowerCase() == 'cancelled'
                              ? Colors.red
                              : Colors.orange[100],
                          labelStyle: TextStyle(
                            color: widget.visit.status.toLowerCase() == 'cancelled'
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
                    _buildInfoRow(Icons.location_on, 'Location', widget.visit.location),
                    if (widget.visit.notes != null && widget.visit.notes!.isNotEmpty)
                      _buildInfoRow(Icons.notes, 'Notes', widget.visit.notes!),
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
