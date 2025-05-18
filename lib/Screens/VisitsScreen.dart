import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:rtm/Model/Activity.dart';
import 'package:rtm/Model/Customer.dart';
import 'package:rtm/Model/Visit.dart';
import 'package:rtm/Screens/VisitDetailScreen.dart';
import 'package:rtm/Services/ApiService.dart';

class VisitsScreen extends StatefulWidget {
  const VisitsScreen({Key? key}) : super(key: key);

  @override
  _VisitsScreenState createState() => _VisitsScreenState();
}

class _VisitsScreenState extends State<VisitsScreen> {
  late Future<List<Visit>> futureVisits;
  late Future<List<Customer>> futureCustomers;
  late Future<List<Activity>> futureActivities;

  Map<int, String> customerNames = {};
  Map<String, String> activityDescriptions = {};

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    futureVisits = ApiService.getVisits();
    futureCustomers = ApiService.getCustomers();
    futureActivities = ApiService.getActivities();

    futureCustomers.then((customers) {
      for (var customer in customers) {
        customerNames[customer.id] = customer.name;
      }
    });

    futureActivities.then((activities) {
      for (var activity in activities) {
        activityDescriptions[activity.id.toString()] = activity.description;
      }
    });
  }

  String _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'green';
      case 'pending':
        return 'orange';
      case 'cancelled':
        return 'red';
      default:
        return 'blue';
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _refreshData();
        });
      },
      child: FutureBuilder<List<Visit>>(
        future: futureVisits,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No visits found'));
          } else {
            // Sort visits by date (newest first)
            final visits = snapshot.data!;
            visits.sort((a, b) => b.visitDate.compareTo(a.visitDate));

            return ListView.builder(
              itemCount: visits.length,
              itemBuilder: (context, index) {
                final visit = visits[index];
                final customerName = customerNames[visit.customerId] ?? 'Unknown Customer';

                // Format date
                final formattedDate = DateFormat('MMM d, yyyy - h:mm a').format(visit.visitDate);

                // Get activities
                List<String> activities = [];
                for (var activityId in visit.activitiesDone) {
                  final description = activityDescriptions[activityId];
                  if (description != null) {
                    activities.add(description);
                  }
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('📍 ${visit.location}'),
                        Text('🕒 $formattedDate'),
                        if (activities.isNotEmpty)
                          Text('✓ ${activities.join(", ")}'),
                        if (visit.notes != null && visit.notes!.isNotEmpty)
                          Text('📝 ${visit.notes}'),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(
                        visit.status,
                        style: TextStyle(
                          color: _getStatusColor(visit.status) == 'red' ? Colors.white : Colors.black,
                        ),
                      ),
                      backgroundColor: _getStatusColor(visit.status) == 'red'
                          ? Colors.red
                          : _getStatusColor(visit.status) == 'green'
                          ? Colors.green[100]
                          : Colors.orange[100],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VisitDetailScreen(
                            visit: visit,
                            customerName: customerName,
                            activityDescriptions: activityDescriptions,
                          ),
                        ),
                      ).then((_) {
                        setState(() {
                          _refreshData();
                        });
                      });
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
