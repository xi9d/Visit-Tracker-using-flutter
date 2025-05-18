import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:rtm/Model/Activity.dart';
import 'package:rtm/Model/Customer.dart';
import 'package:rtm/Model/Visit.dart';
import 'package:rtm/Screens/VisitDetailScreen.dart';
import 'package:rtm/Services/ApiService.dart';

class ActivityDetailScreen extends StatefulWidget {
  final Activity activity;
  final int usageCount;

  const ActivityDetailScreen({
    Key? key,
    required this.activity,
    required this.usageCount,
  }) : super(key: key);

  @override
  _ActivityDetailScreenState createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  late Future<List<Visit>> activityVisits;
  late Future<List<Customer>> futureCustomers;

  Map<int, String> customerNames = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    activityVisits = ApiService.getVisits().then((visits) {
      // Filter visits that include this activity
      return visits
          .where((visit) => visit.activitiesDone.contains(widget.activity.id.toString()))
          .toList();
    });

    futureCustomers = ApiService.getCustomers();

    futureCustomers.then((customers) {
      for (var customer in customers) {
        customerNames[customer.id] = customer.name;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity.description),
      ),
      body: Column(
        children: [
          // Activity info card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.green.shade100,
                    child: Text(
                      widget.activity.description.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.activity.description,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Used in ${widget.usageCount} ${widget.usageCount == 1 ? 'visit' : 'visits'}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Related visits title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Related Visits',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Visits list
          Expanded(
            child: FutureBuilder<List<Visit>>(
              future: activityVisits,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No visits found with this activity'));
                } else {
                  // Sort visits by date (newest first)
                  final visits = snapshot.data!;
                  visits.sort((a, b) => b.visitDate.compareTo(a.visitDate));

                  return ListView.builder(
                    itemCount: visits.length,
                    itemBuilder: (context, index) {
                      final visit = visits[index];
                      final formattedDate = DateFormat('MMM d, yyyy').format(visit.visitDate);
                      final customerName = customerNames[visit.customerId] ?? 'Unknown Customer';

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(customerName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('📅 $formattedDate'),
                              Text('📍 ${visit.location}'),
                            ],
                          ),
                          trailing: Chip(
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VisitDetailScreen(
                                  visit: visit,
                                  customerName: customerName,
                                  activityDescriptions: {widget.activity.id.toString(): widget.activity.description},
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
