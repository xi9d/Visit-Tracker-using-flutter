import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rtm/Model/Activity.dart';
import 'package:rtm/Model/Visit.dart';
import 'package:rtm/Screens/ActivityDetailScreen.dart';
import 'package:rtm/Services/ApiService.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({Key? key}) : super(key: key);

  @override
  _ActivitiesScreenState createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  late Future<List<Activity>> futureActivities;
  late Future<List<Visit>> futureVisits;

  Map<String, int> activityUsageCounts = {};

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    futureActivities = ApiService.getActivities();
    futureVisits = ApiService.getVisits();

    futureVisits.then((visits) {
      // Count activities usage
      Map<String, int> counts = {};
      for (var visit in visits) {
        for (var activityId in visit.activitiesDone) {
          counts[activityId] = (counts[activityId] ?? 0) + 1;
        }
      }
      setState(() {
        activityUsageCounts = counts;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _refreshData();
        });
      },
      child: FutureBuilder<List<Activity>>(
        future: futureActivities,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No activities found'));
          } else {
            final activities = snapshot.data!;
            return ListView.builder(
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                final usageCount = activityUsageCounts[activity.id.toString()] ?? 0;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      child: Text(
                        activity.description.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      activity.description,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Used in $usageCount ${usageCount == 1 ? 'visit' : 'visits'}'),
                    trailing: const Icon(Icons.check_circle_outline),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ActivityDetailScreen(
                            activity: activity,
                            usageCount: usageCount,
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
    );
  }
}