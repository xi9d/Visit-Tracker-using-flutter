import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rtm/Model/Customer.dart';
import 'package:rtm/Model/Visit.dart';
import 'package:rtm/Screens/CustomerDetailScreen.dart';
import 'package:rtm/Services/ApiService.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({Key? key}) : super(key: key);

  @override
  _CustomersScreenState createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  late Future<List<Customer>> futureCustomers;
  late Future<List<Visit>> futureVisits;

  Map<int, int> customerVisitCounts = {};

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    futureCustomers = ApiService.getCustomers();
    futureVisits = ApiService.getVisits();

    futureVisits.then((visits) {
      // Count visits per customer
      Map<int, int> counts = {};
      for (var visit in visits) {
        counts[visit.customerId] = (counts[visit.customerId] ?? 0) + 1;
      }
      setState(() {
        customerVisitCounts = counts;
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
      child: FutureBuilder<List<Customer>>(
        future: futureCustomers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No customers found'));
          } else {
            final customers = snapshot.data!;
            return ListView.builder(
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final customer = customers[index];
                final visitCount = customerVisitCounts[customer.id] ?? 0;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        customer.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      customer.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('$visitCount ${visitCount == 1 ? 'visit' : 'visits'}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerDetailScreen(
                            customer: customer,
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