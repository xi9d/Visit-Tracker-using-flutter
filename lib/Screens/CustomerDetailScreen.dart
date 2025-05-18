import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:rtm/Model/Activity.dart';
import 'package:rtm/Model/Customer.dart';
import 'package:rtm/Model/Visit.dart';
import 'package:rtm/Screens/AddVisitScreen.dart';
import 'package:rtm/Screens/VisitDetailScreen.dart';
import 'package:rtm/Services/ApiService.dart';

class CustomerDetailScreen extends StatefulWidget {
  final Customer  customer;

  const CustomerDetailScreen({
    Key? key,
    required this.customer,
  }) : super(key: key);

  @override
  _CustomerDetailScreenState createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  late Future<List<Visit>> customerVisits;
  late Future<List<Activity>> futureActivities;

  Map<String, String> activityDescriptions = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    customerVisits = ApiService.getVisits().then((visits) {
      // Filter visits for this customer
      return visits.where((visit) => visit.customerId == widget.customer.id).toList();
    });

    futureActivities = ApiService.getActivities();

    futureActivities.then((activities) {
      for (var activity in activities) {
        activityDescriptions[activity.id.toString()] = activity.description;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddVisitScreen(),
                ),
              ).then((_) {
                setState(() {
                  _loadData();
                });
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Customer info card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      widget.customer.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.blue,
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
                          widget.customer.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Customer since ${DateFormat('MMMM yyyy').format(widget.customer.createdAt)}',
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

          // Visit history title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Visit History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FutureBuilder<List<Visit>>(
                  future: customerVisits,
                  builder: (context, snapshot) {
                    final count = snapshot.hasData ? snapshot.data!.length : 0;
                    return Text(
                      '$count ${count == 1 ? 'visit' : 'visits'}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Visits list
          Expanded(
            child: FutureBuilder<List<Visit>>(
              future: customerVisits,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No visits found for this customer'));
                } else {
                  // Sort visits by date (newest first)
                  final visits = snapshot.data!;
                  visits.sort((a, b) => b.visitDate.compareTo(a.visitDate));

                  return ListView.builder(
                    itemCount: visits.length,
                    itemBuilder: (context, index) {
                      final visit = visits[index];
                      final formattedDate = DateFormat('MMM d, yyyy').format(visit.visitDate);

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
                          title: Text(formattedDate),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('📍 ${visit.location}'),
                              if (activities.isNotEmpty)
                                Text('✓ ${activities.join(", ")}'),
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
                                  customerName: widget.customer.name,
                                  activityDescriptions: activityDescriptions,
                                ),
                              ),
                            ).then((_) {
                              setState(() {
                                _loadData();
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddVisitScreen(),
            ),
          ).then((_) {
            setState(() {
              _loadData();
            });
          });
        },
        child: const Icon(Icons.add),
        tooltip: 'Add new visit',
      ),
    );
  }
}
