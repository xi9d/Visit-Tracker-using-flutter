import 'dart:convert';
import 'package:http/http.dart' as http; // Add this import for HTTP requests
import 'package:rtm/Model/Activity.dart';
import 'package:rtm/Model/Customer.dart';
import 'package:rtm/Model/Visit.dart';

class ApiService {
  // Use your actual API base URL here
  static const String baseUrl = 'https://xi9d.pythonanywhere.com/api';

  // Get all customers
  static Future<List<Customer>> getCustomers() async {
    final response = await http.get(Uri.parse('$baseUrl/customers'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Customer.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load customers');
    }
  }

  // Get all activities
  static Future<List<Activity>> getActivities() async {
    final response = await http.get(Uri.parse('$baseUrl/activities'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Activity.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load activities');
    }
  }

  // Get all visits
  static Future<List<Visit>> getVisits() async {
    final response = await http.get(Uri.parse('$baseUrl/visits'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Visit.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load visits');
    }
  }

  // Add a new visit
  static Future<Visit> addVisit(Visit visit) async {
    final response = await http.post(
      Uri.parse('$baseUrl/visits'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(visit.toJson()),
    );

    if (response.statusCode == 201) {
      return Visit.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create visit');
    }
  }

  // Update a visit
  static Future<Visit> updateVisit(int id, Visit visit) async {
    final response = await http.put(
      Uri.parse('$baseUrl/visits/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(visit.toJson()),
    );

    if (response.statusCode == 200) {
      return Visit.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update visit');
    }
  }
}