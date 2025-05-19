import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String name;
  final String email;
  final String role;

  User({required this.name, required this.email, required this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
    );
  }
}

class AuthService {
  // Replace with your actual API base URL
  final String baseUrl = 'https://xi9d.pythonanywhere.com/api';

  // Token storage key
  final String _tokenKey = 'auth_token';
  final String _userKey = 'user_data';

  // Sign up a new user
  Future<bool> signUp(String name, String email, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role, // Include role in the request
      }),
    );

    // Check if signup was successful (201 status code)
    return response.statusCode == 201;
  }

  Future<User?> signIn(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Check if the response has the expected structure
        if (responseData['user'] == null) {
          print('User data not found in response');
          return null;
        }

        // Save user data (even if no token is returned)
        final user = User.fromJson(responseData['user']);
        await _saveUserData(user);

        // If there's a token, save it (make this optional)
        if (responseData.containsKey('token')) {
          await _saveToken(responseData['token']);
        }

        return user;
      } else {
        // Handle non-200 responses
        final errorData = jsonDecode(response.body);
        print('Error during signin: ${errorData['message']}');
        return null;
      }
    } catch (e) {
      print('Exception during signin: $e');
      return null;
    }
  }
  // Check if user is already signed in
  Future<bool> isSignedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey) != null;
  }

  // Get current user data
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);

    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }

    return null;
  }

  // Sign out user
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Save authentication token
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Save user data to local storage
  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode({
      'name': user.name,
      'email': user.email,
      'role': user.role,
    }));
  }

  // Get auth token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}