import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rtm/Model/Activity.dart';
import 'package:rtm/Model/Customer.dart';
import 'package:rtm/Model/Visit.dart';
import 'package:rtm/Services/ApiService.dart';
import 'package:intl/intl.dart';
class EditVisitScreen extends StatefulWidget {
  final Visit visit;

  const EditVisitScreen({Key? key, required this.visit}) : super(key: key);

  @override
  _EditVisitScreenState createState() => _EditVisitScreenState();
}

class _EditVisitScreenState extends State<EditVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  late Future<List<Customer>> futureCustomers;
  late Future<List<Activity>> futureActivities;
  late int selectedCustomerId;
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  late String location;
  late String status;
  late String notes;
  late List<String> selectedActivities;
  List<Customer> customers = [];
  List<Activity> activities = [];
  final List<String> statusOptions = ['Pending', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    // Initialize form values with visit data
    selectedCustomerId = widget.visit.customerId;
    selectedDate = widget.visit.visitDate;
    selectedTime = TimeOfDay(
      hour: widget.visit.visitDate.hour,
      minute: widget.visit.visitDate.minute,
    );
    location = widget.visit.location;
    status = widget.visit.status;
    notes = widget.visit.notes ?? '';
    selectedActivities = List<String>.from(widget.visit.activitiesDone);

    // Fetch data
    futureCustomers = ApiService.getCustomers();
    futureActivities = ApiService.getActivities();

    futureCustomers.then((value) {
      setState(() {
        customers = value;
      });
    });

    futureActivities.then((value) {
      setState(() {
        activities = value;
      });
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _toggleActivity(String activityId) {
    setState(() {
      if (selectedActivities.contains(activityId)) {
        selectedActivities.remove(activityId);
      } else {
        selectedActivities.add(activityId);
      }
    });
  }

  Future<void> _submitForm() async {
    Future<void> _submitForm() async {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();

        try {
          // Combine date and time
          final visitDate = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );

          // Create updated visit object
          final updatedVisit = Visit(
            id: widget.visit.id,
            customerId: selectedCustomerId,
            visitDate: visitDate,
            location: location,
            status: status,
            notes: notes.isEmpty ? null : notes,
            activitiesDone: selectedActivities,
            createdAt: widget.visit.createdAt,
          );

          // Print the data being sent for debugging
          print('Sending update: ${updatedVisit.toJson()}');

          final response = await ApiService.updateVisit(
              widget.visit.id, updatedVisit);
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Visit updated successfully')),
          );
        } catch (e) {
          print('Error details: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating visit: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Visit'),
      ),
      body: FutureBuilder(
        future: Future.wait([futureCustomers, futureActivities]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer dropdown
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Customer',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedCustomerId,
                      items: customers.map((Customer customer) {
                        return DropdownMenuItem<int>(
                          value: customer.id,
                          child: Text(customer.name),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedCustomerId = newValue!;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a customer';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Date picker
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          DateFormat('MMMM d, yyyy').format(selectedDate),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Time picker
                    InkWell(
                      onTap: () => _selectTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(
                          selectedTime.format(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Location field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: location,
                      onSaved: (value) {
                        location = value ?? '';
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Status dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      value: status,
                      items: statusOptions.map((String status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          status = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Notes field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                        hintText: 'Optional',
                      ),
                      initialValue: notes,
                      maxLines: 3,
                      onSaved: (value) {
                        notes = value ?? '';
                      },
                    ),
                    const SizedBox(height: 24),

                    // Activities checklist
                    const Text(
                      'Activities',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: activities.length,
                        itemBuilder: (context, index) {
                          final activity = activities[index];
                          return CheckboxListTile(
                            title: Text(activity.description),
                            value: selectedActivities.contains(
                                activity.id.toString()),
                            onChanged: (bool? value) {
                              _toggleActivity(activity.id.toString());
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Update Visit'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
