import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rtm/Model/Activity.dart';
import 'package:rtm/Model/Customer.dart';
import 'package:rtm/Model/RepPerformance.dart';
import 'package:rtm/Model/Visit.dart';
import 'package:rtm/Model/VisitStats.dart';
import 'package:rtm/Services/auth_service.dart';

class ApiService {
  static const String baseUrl = 'https://xi9d.pythonanywhere.com/api';

  // Helper method to get headers with auth token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get all customers
  static Future<List<Customer>> getCustomers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/customers'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Customer.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load customers');
    }
  }

  static Future<Customer> addCustomer(Customer customer) async {
    try {

      final response = await http.post(
        Uri.parse('$baseUrl/customers'),
        headers: await _getHeaders(),
        body: jsonEncode(customer.toJson()),
      );

      if (response.statusCode == 201) {
        return Customer.fromJson(json.decode(response.body));
      } else {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['message'] ??
            errorBody['error'] ??
            'Failed to create customer (Status: ${response.statusCode})';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Failed to create customer: ${e.toString()}');
    }
  }

  // Get all activities
  static Future<List<Activity>> getActivities() async {
    final response = await http.get(
      Uri.parse('$baseUrl/activities'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Activity.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load activities');
    }
  }

  // Get all visits
  static Future<List<Visit>> getVisits() async {
    final response = await http.get(
      Uri.parse('$baseUrl/visits'),
      headers: await _getHeaders(),
    );

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
      headers: await _getHeaders(),
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
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/visits/$id'),
        headers: await _getHeaders(),
        body: jsonEncode(visit.toJson()),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return Visit.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to update visit');
      }
    } catch (e) {
      throw Exception('Update failed: $e');
    }
  }

  // Get rep performance data
  static Future<List<RepPerformance>> fetchRepPerformance() async {
    final response = await http.get(
      Uri.parse('$baseUrl/rep-performance'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => RepPerformance.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load rep performance data');
    }
  }

  // Get visit statistics
  Future<VisitStats> fetchVisitStats() async {
    final url = Uri.parse('$baseUrl/visits/stats'); // Replace with actual URL

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return VisitStats.fromJson(data);
    } else {
      throw Exception('Failed to load visit statistics');
    }
  }
}


